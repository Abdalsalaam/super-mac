import Foundation
import AppKit
import CryptoKit
import Darwin

// MARK: - Basics

func fmt(_ bytes: Int64) -> String {
    let f = ByteCountFormatter()
    f.countStyle = .file
    return f.string(fromByteCount: bytes)
}

func relativeDate(_ d: Date?) -> String {
    guard let d else { return "Never" }
    let f = RelativeDateTimeFormatter()
    f.unitsStyle = .short
    return f.localizedString(for: d, relativeTo: Date())
}

let homeURL = FileManager.default.homeDirectoryForCurrentUser
let homePath = homeURL.standardizedFileURL.path
func home(_ p: String) -> URL { homeURL.appending(path: p) }
func tilde(_ url: URL) -> String { url.path.replacingOccurrences(of: homePath, with: "~") }

/// A file or folder the user can choose to act on.
struct FileItem: Identifiable, Hashable, Sendable {
    let id = UUID()
    let url: URL
    let size: Int64
    var selected = true
    var note: String = ""
    var date: Date? = nil
}

enum FS {
    static let fm = FileManager.default
    static let sizeKeys: Set<URLResourceKey> = [.isDirectoryKey, .isSymbolicLinkKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey]

    static func size(of url: URL) -> Int64 {
        guard let v = try? url.resourceValues(forKeys: sizeKeys) else { return 0 }
        if v.isSymbolicLink == true { return 0 }
        if v.isDirectory != true { return Int64(v.totalFileAllocatedSize ?? v.fileAllocatedSize ?? 0) }
        var total: Int64 = 0
        if let e = fm.enumerator(at: url, includingPropertiesForKeys: Array(sizeKeys), options: [], errorHandler: { _, _ in true }) {
            for case let f as URL in e {
                if let r = try? f.resourceValues(forKeys: sizeKeys), r.isDirectory != true, r.isSymbolicLink != true {
                    total += Int64(r.totalFileAllocatedSize ?? r.fileAllocatedSize ?? 0)
                }
            }
        }
        return total
    }

    static func children(_ url: URL) -> [URL] {
        (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.contentModificationDateKey], options: [])) ?? []
    }

    static func exists(_ url: URL) -> Bool { fm.fileExists(atPath: url.path) }

    static func modified(_ url: URL) -> Date? {
        (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }

    /// Move to Trash (reversible). Returns the URLs that failed.
    static func trash(_ urls: [URL]) -> [URL] {
        var failed: [URL] = []
        for u in urls {
            do { try fm.trashItem(at: u, resultingItemURL: nil) } catch { failed.append(u) }
        }
        return failed
    }

    static func sha256(_ url: URL) -> String? {
        guard let h = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { try? h.close() }
        var hasher = SHA256()
        while let chunk = try? h.read(upToCount: 1 << 20), !chunk.isEmpty { hasher.update(data: chunk) }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    static func canReadProtected() -> Bool {
        (try? fm.contentsOfDirectory(atPath: home("Library/Safari").path)) != nil
    }
}

// MARK: - Shell helpers

@discardableResult
func shell(_ launchPath: String, _ args: [String]) -> String {
    let p = Process()
    p.executableURL = URL(fileURLWithPath: launchPath)
    p.arguments = args
    let pipe = Pipe()
    p.standardOutput = pipe
    p.standardError = Pipe()
    do { try p.run() } catch { return "" }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    return String(data: data, encoding: .utf8) ?? ""
}

/// Runs commands as administrator. macOS shows its own password dialog — Super Mac never sees the password.
@MainActor
func runAsAdmin(_ command: String) -> Bool {
    let escaped = command.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
    let script = NSAppleScript(source: "do shell script \"\(escaped)\" with administrator privileges")
    var err: NSDictionary?
    script?.executeAndReturnError(&err)
    return err == nil
}

func shellQuote(_ s: String) -> String { "'" + s.replacingOccurrences(of: "'", with: "'\\''") + "'" }

// MARK: - Live system stats

struct DiskInfo { var free: Int64 = 0; var total: Int64 = 0
    var usedFraction: Double { total > 0 ? Double(total - free) / Double(total) : 0 } }

enum SysInfo {
    static func disk() -> DiskInfo {
        let keys: Set<URLResourceKey> = [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey]
        guard let v = try? URL(fileURLWithPath: "/").resourceValues(forKeys: keys) else { return DiskInfo() }
        return DiskInfo(free: v.volumeAvailableCapacityForImportantUsage ?? 0, total: Int64(v.volumeTotalCapacity ?? 0))
    }

    static func cpuTicks() -> (busy: UInt64, total: UInt64) {
        var info = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride)
        let r = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard r == KERN_SUCCESS else { return (0, 0) }
        let u = UInt64(info.cpu_ticks.0), s = UInt64(info.cpu_ticks.1), i = UInt64(info.cpu_ticks.2), n = UInt64(info.cpu_ticks.3)
        return (u + s + n, u + s + i + n)
    }

    static func memoryUsed() -> UInt64 {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        let r = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard r == KERN_SUCCESS else { return 0 }
        let page = UInt64(vm_kernel_page_size)
        let app = UInt64(stats.internal_page_count) - UInt64(stats.purgeable_count)
        return (app + UInt64(stats.wire_count) + UInt64(stats.compressor_page_count)) * page
    }

    static var memoryTotal: UInt64 { ProcessInfo.processInfo.physicalMemory }
}

@MainActor
final class LiveStats: ObservableObject {
    @Published var cpu: Double = 0
    @Published var memUsed: UInt64 = 0
    @Published var memTotal: UInt64 = SysInfo.memoryTotal
    @Published var disk = SysInfo.disk()
    private var last = SysInfo.cpuTicks()
    private var timer: Timer?

    var memFraction: Double { memTotal > 0 ? Double(memUsed) / Double(memTotal) : 0 }

    init() {
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func tick() {
        let now = SysInfo.cpuTicks()
        let dt = Double(now.total &- last.total), db = Double(now.busy &- last.busy)
        if dt > 0 { cpu = db / dt }
        last = now
        memUsed = SysInfo.memoryUsed()
        disk = SysInfo.disk()
    }
}
