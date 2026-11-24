import AppKit
import SwiftUI

let outDir = CommandLine.arguments[1]
let res = CommandLine.arguments[2]

@MainActor func snap(_ win: NSWindow, _ name: String) {
    let v = win.contentView!
    v.layoutSubtreeIfNeeded(); v.display()
    // Own-window capture keeps real blur and Liquid Glass
    if let cg = CGWindowListCreateImage(.null, .optionIncludingWindow, CGWindowID(win.windowNumber), [.boundsIgnoreFraming, .bestResolution]) {
        try? NSBitmapImageRep(cgImage: cg).representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "\(outDir)/\(name).png"))
        print("saved", name, cg.width, cg.height)
    } else { print("capture failed", name) }
}
@MainActor func wait(_ s: Double) async { try? await Task.sleep(for: .seconds(s)) }

@main enum Snap { static func main() {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    for n in ["smart_care","cleanup","protection","performance","applications","clutter","space_lens","app_icon","automation","settings","developer",
              "brand_facebook","brand_instagram","brand_linkedin","brand_github"] {
        ArtCache.images[n] = NSImage(contentsOfFile: res + "/" + n + ".png")
    }
    let only = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : "all"
    if only == "whatsnew" { UserDefaults.standard.removeObject(forKey: "seenWhatsNew") }
    else { UserDefaults.standard.set(AppInfo.version, forKey: "seenWhatsNew") }
    let state = AppState()
    let win = NSWindow(contentRect: NSRect(x: 80, y: 80, width: 1160, height: 760), styleMask: [.titled, .fullSizeContentView], backing: .buffered, defer: false)
    win.titlebarAppearsTransparent = true
    win.appearance = NSAppearance(named: .darkAqua)
    win.contentView = NSHostingView(rootView: RootView(s: state).preferredColorScheme(.dark))
    win.orderFrontRegardless()
    Task { @MainActor in
        await wait(1.5)
        if only == "whatsnew" { await wait(1.5); snap(win, "whatsnew"); app.terminate(nil) }
        if only == "all" || only == "pages" {
            state.page = .about; await wait(2.6); snap(win, "about")
            state.page = nil; state.module = .smartCare; await wait(1.5); snap(win, "idle_smartCare")
            state.showPalette = true; await wait(1.0); snap(win, "palette"); state.showPalette = false
            for t in SettingsTab.allCases { state.page = .settings; state.settingsTab = t; await wait(1.4); snap(win, "settings_\(t.rawValue)") }
        }
        if only == "all" {
            state.page = nil
            state.module = .applications; await wait(1.2); snap(win, "idle_applications")
            for mod in Module.allCases { state.module = mod; await wait(1.5); snap(win, "idle_\(mod.rawValue)") }
            state.module = .smartCare; state.smart.scan(state); await wait(2.5); snap(win, "smart_scanning")
            while state.smart.phase != .results { await wait(0.5) }
            await wait(1.5); snap(win, "smart_results")
            state.module = .cleanup; await wait(1.2); snap(win, "cleanup_results")
            state.module = .applications; await wait(1.5); snap(win, "apps_results")
            state.module = .spaceLens; state.lens.open(homeURL)
            while state.lens.loading { await wait(0.5) }
            await wait(1); snap(win, "lens_map")
        }
        app.terminate(nil)
    }
    app.run()
}}
