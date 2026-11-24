import SwiftUI
import AppKit

// MARK: - Shared pieces

/// 3D glass art for pages that aren't modules (falls back to an SF Symbol tile).
struct PageArt: View {
    let name: String
    let symbol: String
    let colors: [Color]
    var size: CGFloat
    var body: some View {
        if let img = ArtCache.image(name) {
            Image(nsImage: img).resizable().interpolation(.high).scaledToFit().frame(width: size, height: size)
        } else {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Image(systemName: symbol).font(.system(size: size * 0.42, weight: .semibold)).foregroundStyle(.white))
                .frame(width: size * 0.8, height: size * 0.8).frame(width: size, height: size)
        }
    }
}

struct IconTile: View {
    let symbol: String
    let colors: [Color]
    var size: CGFloat = 30
    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .center)))
            .overlay(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).strokeBorder(.white.opacity(0.25), lineWidth: 0.8))
            .overlay(Image(systemName: symbol).font(.system(size: size * 0.48, weight: .semibold)).foregroundStyle(.white))
            .frame(width: size, height: size)
            .shadow(color: colors[0].opacity(0.4), radius: 6, y: 2)
    }
}

struct SettingRow<Control: View>: View {
    let symbol: String
    let colors: [Color]
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var control: Control
    var body: some View {
        HStack(spacing: 14) {
            IconTile(symbol: symbol, colors: colors)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 13.5, weight: .semibold))
                if let subtitle {
                    Text(subtitle).font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.55)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 16)
            control
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

struct SettingCard<Content: View>: View {
    var title: String? = nil
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title.uppercased()).font(.system(size: 10.5, weight: .semibold)).kerning(1.4)
                    .foregroundStyle(.white.opacity(0.45)).padding(.leading, 6)
            }
            VStack(spacing: 0) {
                _VariadicView.Tree(DividedLayout()) { content }
            }
            .glass(18)
        }
    }
}

/// Puts a hairline between rows.
struct DividedLayout: _VariadicView_MultiViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id
        ForEach(children) { child in
            child
            if child.id != last { Rectangle().fill(.white.opacity(0.07)).frame(height: 1).padding(.leading, 60) }
        }
    }
}

struct GlassToggle: View {
    @Binding var isOn: Bool
    var tint: Color = .violet
    var body: some View {
        Toggle("", isOn: $isOn).labelsHidden().toggleStyle(.switch).tint(tint).controlSize(.small)
    }
}

/// Compact glass menu picker.
struct GlassMenu<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let label: (T) -> String
    var body: some View {
        Menu {
            ForEach(options, id: \.self) { o in
                Button { selection = o } label: {
                    if o == selection { Label(label(o), systemImage: "checkmark") } else { Text(label(o)) }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(label(selection)).font(.system(size: 12.5, weight: .semibold))
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .bold)).opacity(0.6)
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .glassCapsule()
        }
        .menuStyle(.button).buttonStyle(.plain).fixedSize()
    }
}

// MARK: - Settings

enum SettingsTab: String, CaseIterable, Identifiable {
    case automation, general, cleanup, exclusions, history
    var id: String { rawValue }
    var title: String {
        switch self {
        case .automation: "Automation"
        case .general: "General"
        case .cleanup: "Cleanup"
        case .exclusions: "Ignore List"
        case .history: "History"
        }
    }
    var symbol: String {
        switch self {
        case .automation: "clock.arrow.2.circlepath"
        case .general: "gearshape.fill"
        case .cleanup: "bubbles.and.sparkles.fill"
        case .exclusions: "eye.slash.fill"
        case .history: "chart.bar.fill"
        }
    }
}

struct SettingsScreen: View {
    @Bindable var s: AppState
    @Namespace private var ns

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                PageArt(name: "settings", symbol: "gearshape.fill", colors: [.lilac, .violet], size: 62)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings").font(.system(size: 30, weight: .bold)).tracking(-0.6)
                    Text("Make Super Mac work the way you like — and on its own.")
                        .font(.system(size: 13)).foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
            }
            tabs
            ScrollView {
                Group {
                    switch s.settingsTab {
                    case .automation: AutomationPane()
                    case .general: GeneralPane()
                    case .cleanup: CleanupPane()
                    case .exclusions: ExclusionsPane()
                    case .history: HistoryPane()
                    }
                }
                .padding(.bottom, 30)
                .id(s.settingsTab)
                .transition(.opacity.combined(with: .offset(y: 8)))
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 40).padding(.top, 14)
        .frame(maxWidth: 820)
        .frame(maxWidth: .infinity)
    }

    var tabs: some View {
        HStack(spacing: 4) {
            ForEach(SettingsTab.allCases) { t in
                let sel = s.settingsTab == t
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) { s.settingsTab = t } } label: {
                    Label(t.title, systemImage: t.symbol)
                        .font(.system(size: 12.5, weight: sel ? .bold : .medium))
                        .foregroundStyle(.white.opacity(sel ? 1 : 0.65))
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background {
                            if sel {
                                Capsule().fill(LinearGradient(colors: [.violet.opacity(0.55), .pinkish.opacity(0.35)], startPoint: .leading, endPoint: .trailing))
                                    .overlay(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                                    .matchedGeometryEffect(id: "tab", in: ns)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .glassCapsule(interactive: false)
    }
}

// MARK: Automation

struct AutomationPane: View {
    @Bindable var p = Prefs.shared
    let auto = Automation.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            hero
            SettingCard(title: "Scheduled care") {
                SettingRow(symbol: "calendar.badge.clock", colors: [.sky, .violet], title: "Scan automatically",
                           subtitle: "Super Mac checks for junk in the background.") {
                    GlassMenu(options: Frequency.allCases, selection: $p.autoScan) { $0.title }
                }
                if p.autoScan != .off {
                    SettingRow(symbol: "clock.fill", colors: [.aqua, .sky], title: "Preferred time",
                               subtitle: "If your Mac is asleep then, it runs as soon as it wakes.") {
                        GlassMenu(options: Array(0..<24), selection: $p.autoHour) { hourLabel($0) }
                    }
                    SettingRow(symbol: "wand.and.stars", colors: [.mint, .teal], title: "Clean automatically",
                               subtitle: "Removes only caches, logs, temp files and saved app states. Never your files or the Trash.") {
                        GlassToggle(isOn: $p.autoClean, tint: .mint)
                    }
                    if p.autoClean {
                        SettingRow(symbol: "gauge.with.dots.needle.33percent", colors: [.teal, .mint], title: "Only when there's at least",
                                   subtitle: "Skips tiny cleanups so apps keep their warm caches.") {
                            GlassMenu(options: [100, 250, 500, 1024, 2048, 5120], selection: $p.autoCleanMinMB) { fmt(Int64($0) << 20) }
                        }
                    }
                }
            }
            SettingCard(title: "Smart alerts") {
                SettingRow(symbol: "externaldrive.fill.badge.exclamationmark", colors: [.amber, .coral], title: "Low disk space",
                           subtitle: "Notify me when free space drops below a limit.") {
                    HStack(spacing: 10) {
                        if p.lowDiskAlert { GlassMenu(options: [5, 10, 15, 20, 30, 50], selection: $p.lowDiskGB) { "\($0) GB" } }
                        GlassToggle(isOn: $p.lowDiskAlert, tint: .amber)
                    }
                }
                SettingRow(symbol: "trash.fill", colors: [.pinkish, .rose], title: "Full Trash",
                           subtitle: "Remind me when the Trash is holding a lot of space.") {
                    HStack(spacing: 10) {
                        if p.trashAlert { GlassMenu(options: [1, 2, 5, 10, 20], selection: $p.trashGB) { "\($0) GB" } }
                        GlassToggle(isOn: $p.trashAlert, tint: .pinkish)
                    }
                }
                SettingRow(symbol: "arrow.down.circle.fill", colors: [.sky, .aqua], title: "Big Downloads folder",
                           subtitle: "Nudge me when Downloads grows past a limit.") {
                    HStack(spacing: 10) {
                        if p.downloadsAlert { GlassMenu(options: [5, 10, 20, 50], selection: $p.downloadsGB) { "\($0) GB" } }
                        GlassToggle(isOn: $p.downloadsAlert, tint: .sky)
                    }
                }
                SettingRow(symbol: "memorychip.fill", colors: [.violet, .pinkish], title: "Memory pressure",
                           subtitle: "Tell me when memory is over 92% used.") {
                    GlassToggle(isOn: $p.memoryAlert)
                }
            }
            Label("Automation runs while Super Mac is open. Closing the window keeps it alive in the menu bar — turn on Launch at login in General so it's always on.",
                  systemImage: "info.circle.fill")
                .font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.5)).padding(.horizontal, 6)
        }
        .onChange(of: p.autoScan) { _, v in if v != .off { Notifier.requestAccess() } }
        .onChange(of: p.lowDiskAlert) { _, v in if v { Notifier.requestAccess() } }
    }

    var hero: some View {
        HStack(spacing: 22) {
            PageArt(name: "automation", symbol: "clock.arrow.2.circlepath", colors: [.sky, .violet], size: 110)
                .shadow(color: .sky.opacity(0.4), radius: 24)
            VStack(alignment: .leading, spacing: 6) {
                Text(p.autoScan == .off ? "Automation is off" : "On autopilot")
                    .font(.system(size: 22, weight: .bold)).tracking(-0.4)
                Group {
                    if let next = p.nextAutoRun {
                        Text("Next check \(next.formatted(.relative(presentation: .named))) · \(next.formatted(date: .abbreviated, time: .shortened))")
                    } else {
                        Text("Pick a schedule and Super Mac will keep your Mac tidy without you thinking about it.")
                    }
                }
                .font(.system(size: 13)).foregroundStyle(.white.opacity(0.65))
                if let r = auto.lastResult {
                    Label(r, systemImage: "checkmark.seal.fill").font(.system(size: 12, weight: .medium)).foregroundStyle(Color.mint)
                } else if let last = p.lastAutoRun {
                    Text("Last automatic run \(relativeDate(last))").font(.system(size: 12)).foregroundStyle(.white.opacity(0.45))
                }
                HStack(spacing: 10) {
                    Button {
                        Task { await auto.runNow(automatic: false, forceClean: false) }
                    } label: {
                        HStack(spacing: 8) {
                            if auto.running { ProgressView().controlSize(.small).tint(.white) }
                            Text(auto.running ? "Checking…" : "Check now")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle(colors: [.sky, .violet]))
                    .disabled(auto.running)
                    Button("Quick Clean") { Task { await auto.runNow(automatic: false, forceClean: true) } }
                        .buttonStyle(GhostButtonStyle()).disabled(auto.running)
                }
                .padding(.top, 6)
            }
            Spacer()
        }
        .padding(22)
        .glass(22, tint: .sky)
    }

    func hourLabel(_ h: Int) -> String {
        var c = DateComponents(); c.hour = h; c.minute = 0
        return (Calendar.current.date(from: c) ?? Date()).formatted(date: .omitted, time: .shortened)
    }
}

// MARK: General

struct GeneralPane: View {
    @Bindable var p = Prefs.shared
    @State private var loginError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingCard(title: "Startup") {
                SettingRow(symbol: "power", colors: [.mint, .teal], title: "Launch at login",
                           subtitle: loginError ?? "Start quietly in the menu bar when you log in.") {
                    GlassToggle(isOn: Binding(get: { p.launchAtLogin }, set: { loginError = p.setLaunchAtLogin($0) }), tint: .mint)
                }
                SettingRow(symbol: "dock.rectangle", colors: [.sky, .aqua], title: "Show in Dock",
                           subtitle: "Turn off to keep Super Mac in the menu bar only.") {
                    GlassToggle(isOn: $p.showInDock, tint: .sky)
                }
            }
            SettingCard(title: "Menu bar") {
                SettingRow(symbol: "menubar.rectangle", colors: [.violet, .lilac], title: "Show free space in the menu bar",
                           subtitle: "See how much room you have left at a glance.") {
                    GlassToggle(isOn: $p.menuBarFreeSpace)
                }
            }
            SettingCard(title: "Look & feel") {
                SettingRow(symbol: "sparkles", colors: [.pinkish, .violet], title: "Reduce motion",
                           subtitle: "Freeze the animated background to save a little battery.") {
                    GlassToggle(isOn: $p.reduceMotion, tint: .pinkish)
                }
            }
            SettingCard(title: "Permissions") {
                SettingRow(symbol: "bell.badge.fill", colors: [.coral, .rose], title: "Notifications",
                           subtitle: "Needed for automation results and smart alerts.") {
                    Button("Allow") { Notifier.requestAccess(); openPrefs("com.apple.Notifications-Settings.extension") }
                        .buttonStyle(GhostButtonStyle())
                }
                SettingRow(symbol: "lock.shield.fill", colors: [.amber, .coral], title: "Full Disk Access",
                           subtitle: FS.canReadProtected() ? "Granted — Protection can scan Safari and the Trash." : "Optional. Lets Protection scan Safari data and the Trash.") {
                    Button(FS.canReadProtected() ? "Granted" : "Open Settings") { openPrefs("com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles") }
                        .buttonStyle(GhostButtonStyle()).disabled(FS.canReadProtected())
                }
            }
        }
    }

    func openPrefs(_ pane: String) {
        if let u = URL(string: "x-apple.systempreferences:\(pane)") { NSWorkspace.shared.open(u) }
    }
}

// MARK: Cleanup

struct CleanupPane: View {
    @Bindable var p = Prefs.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SettingCard(title: "What Cleanup looks for") {
                ForEach(JunkKind.allCases) { k in
                    SettingRow(symbol: k.symbol, colors: k.colors, title: k.title, subtitle: k.subtitle) {
                        GlassToggle(isOn: Binding(get: { p.isEnabled(k) }, set: { p.setEnabled(k, $0) }), tint: k.colors[0])
                    }
                }
            }
            SettingCard(title: "Safety") {
                SettingRow(symbol: "clock.arrow.circlepath", colors: [.amber, .rose], title: "Temporary files older than",
                           subtitle: "Newer temp files may still be in use, so they're left alone.") {
                    GlassMenu(options: [1, 3, 7, 14], selection: $p.tempAgeDays) { $0 == 1 ? "1 day" : "\($0) days" }
                }
            }
            Label("Super Mac never touches system files, running apps' caches or anything in your Ignore List. Files from Clutter, Applications and Space Lens go to the Trash first.",
                  systemImage: "checkmark.shield.fill")
                .font(.system(size: 11.5)).foregroundStyle(.white.opacity(0.5)).padding(.horizontal, 6)
        }
    }
}

// MARK: Ignore list

struct ExclusionsPane: View {
    @Bindable var p = Prefs.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ignore List").font(.system(size: 17, weight: .bold))
                    Text("Folders and files here are skipped by Cleanup, My Clutter and the app uninstaller.")
                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                Button { p.addExclusion() } label: { Label("Add…", systemImage: "plus") }
                    .buttonStyle(PrimaryButtonStyle(colors: [.violet, .pinkish]))
            }
            if p.excluded.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "eye.slash.circle.fill").font(.system(size: 40)).foregroundStyle(.white.opacity(0.35))
                    Text("Nothing ignored yet").font(.system(size: 14, weight: .semibold))
                    Text("Add a project folder, a game's cache or anything you want Super Mac to leave alone.")
                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.5)).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(36).glass(18)
            } else {
                SettingCard {
                    ForEach(p.excluded, id: \.self) { path in
                        HStack(spacing: 12) {
                            Image(nsImage: fileIcon(URL(fileURLWithPath: path))).resizable().frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(URL(fileURLWithPath: path).lastPathComponent).font(.system(size: 13, weight: .semibold))
                                Text(tilde(URL(fileURLWithPath: path))).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                                    .lineLimit(1).truncationMode(.middle)
                            }
                            Spacer()
                            Button { withAnimation { p.excluded.removeAll { $0 == path } } } label: {
                                Image(systemName: "minus.circle.fill").font(.system(size: 16)).foregroundStyle(.white.opacity(0.6))
                            }
                            .buttonStyle(.plain).help("Stop ignoring")
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }
                }
            }
        }
    }
}

// MARK: History

struct HistoryPane: View {
    let h = History.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                stat("Freed all-time", h.totalFreed > 0 ? fmt(h.totalFreed) : "0 MB", [.mint, .teal], "arrow.down.circle.fill")
                stat("Cleanups", "\(h.cleans)", [.violet, .pinkish], "sparkles")
                stat("On autopilot", "\(h.entries.filter(\.automatic).count)", [.sky, .aqua], "clock.arrow.2.circlepath")
            }
            chart
            forecast
            if h.entries.isEmpty {
                Text("Your cleanups will show up here.").font(.system(size: 13)).foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity).padding(30).glass(18)
            } else {
                SettingCard(title: "Recent") {
                    ForEach(h.entries.prefix(25)) { e in
                        HStack(spacing: 12) {
                            IconTile(symbol: e.automatic ? "clock.arrow.2.circlepath" : "hand.tap.fill",
                                     colors: e.automatic ? [.sky, .aqua] : [.violet, .pinkish], size: 26)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(e.title).font(.system(size: 13, weight: .semibold))
                                Text(e.date.formatted(date: .abbreviated, time: .shortened)).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                            }
                            Spacer()
                            Text(fmt(e.bytes)).font(.system(size: 13, weight: .bold)).monospacedDigit()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 9)
                    }
                }
                Button("Clear history") { withAnimation { h.clear() } }.buttonStyle(GhostButtonStyle())
            }
        }
    }

    func stat(_ t: String, _ v: String, _ c: [Color], _ sym: String) -> some View {
        HStack(spacing: 12) {
            IconTile(symbol: sym, colors: c, size: 34)
            VStack(alignment: .leading, spacing: 1) {
                Text(v).font(.system(size: 20, weight: .bold)).contentTransition(.numericText())
                Text(t).font(.system(size: 11)).foregroundStyle(.white.opacity(0.55))
            }
            Spacer(minLength: 0)
        }
        .padding(14).frame(maxWidth: .infinity).glass(16)
    }

    var forecast: some View {
        let f = DiskForecast.shared
        return HStack(spacing: 14) {
            IconTile(symbol: "chart.line.downtrend.xyaxis", colors: f.daysLeft.map { $0 < 60 ? [.amber, .coral] : [.aqua, .sky] } ?? [.aqua, .sky], size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text("Disk forecast").font(.system(size: 13.5, weight: .semibold))
                Text(f.summary).font(.system(size: 12)).foregroundStyle(.white.opacity(0.6)).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            if let d = f.daysLeft, d <= 365 {
                VStack(spacing: 0) {
                    Text("\(d)").font(.system(size: 24, weight: .heavy))
                    Text("days left").font(.system(size: 10)).foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(16).glass(18)
    }

    var chart: some View {
        let days = h.daily(14)
        let peak = max(days.map(\.1).max() ?? 1, 1)
        return VStack(alignment: .leading, spacing: 10) {
            Text("LAST 14 DAYS").font(.system(size: 10.5, weight: .semibold)).kerning(1.4).foregroundStyle(.white.opacity(0.45))
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(days, id: \.0) { d in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(d.1 > 0 ? AnyShapeStyle(LinearGradient(colors: [.pinkish, .violet], startPoint: .top, endPoint: .bottom))
                                          : AnyShapeStyle(Color.white.opacity(0.07)))
                            .frame(height: max(6, 90 * CGFloat(Double(d.1) / Double(peak))))
                            .help(d.1 > 0 ? fmt(d.1) : "Nothing cleaned")
                        Text(d.0.formatted(.dateTime.day())).font(.system(size: 9.5)).foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 112, alignment: .bottom)
        }
        .padding(18).glass(18)
    }
}

// MARK: - About

struct Social: Identifiable {
    let id: String
    let name: String
    let handle: String
    let url: URL
    let colors: [Color]
    let glyph: String?      // bundled white PNG
    let symbol: String?     // SF Symbol fallback
}

enum Developer {
    static let name = "Amir Mohamed"
    static let email = "amirmhmdart@gmail.com"
    static let links: [Social] = [
        Social(id: "facebook", name: "Facebook", handle: "AmirMohamedArtX", url: URL(string: "https://www.facebook.com/AmirMohamedArtX/")!,
               colors: [Color(hex: 0x3B8BFF), Color(hex: 0x0A5BD3)], glyph: "brand_facebook", symbol: nil),
        Social(id: "instagram", name: "Instagram", handle: "@amirmhmdart", url: URL(string: "https://www.instagram.com/amirmhmdart/")!,
               colors: [Color(hex: 0xFEDA75), Color(hex: 0xFA7E1E), Color(hex: 0xD62976), Color(hex: 0x962FBF), Color(hex: 0x4F5BD5)],
               glyph: "brand_instagram", symbol: nil),
        Social(id: "linkedin", name: "LinkedIn", handle: "in/amirmhmdart", url: URL(string: "https://www.linkedin.com/in/amirmhmdart/")!,
               colors: [Color(hex: 0x2D8CFF), Color(hex: 0x0A66C2)], glyph: "brand_linkedin", symbol: nil),
        Social(id: "github", name: "GitHub", handle: "amirmhmdart", url: URL(string: "https://github.com/amirmhmdart")!,
               colors: [Color(hex: 0x57606A), Color(hex: 0x1F2328)], glyph: "brand_github", symbol: nil),
        Social(id: "email", name: "Email", handle: email, url: URL(string: "mailto:\(email)?subject=Super%20Mac")!,
               colors: [Color(hex: 0xFF6B5E), Color(hex: 0xD93025)], glyph: nil, symbol: "envelope.fill"),
    ]
}

/// Social link as a Liquid Glass capsule — same family as the feature pills on every module page.
struct BrandCapsule: View {
    let social: Social
    @State private var hover = false

    var body: some View {
        Button { NSWorkspace.shared.open(social.url) } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle().fill(LinearGradient(colors: social.colors, startPoint: social.colors.count > 2 ? .bottomLeading : .top,
                                                 endPoint: social.colors.count > 2 ? .topTrailing : .bottom))
                    Circle().fill(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center))
                    Circle().strokeBorder(.white.opacity(0.35), lineWidth: 0.7)
                    if let g = social.glyph, let img = ArtCache.image(g) {
                        Image(nsImage: img).resizable().interpolation(.high).scaledToFit().frame(width: 12, height: 12)
                    } else {
                        Image(systemName: social.symbol ?? "link").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                    }
                }
                .frame(width: 24, height: 24)
                .shadow(color: social.colors[social.colors.count / 2].opacity(hover ? 0.9 : 0.4), radius: hover ? 10 : 4)
                Text(social.name).font(.system(size: 13, weight: .medium))
                if hover {
                    Image(systemName: "arrow.up.right").font(.system(size: 9, weight: .bold)).opacity(0.6)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.leading, 6).padding(.trailing, 14).padding(.vertical, 6)
            .glassCapsule()
            .scaleEffect(hover ? 1.05 : 1)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .onHover { h in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { hover = h }
            if h { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
        .help(social.handle)
    }
}

struct AboutScreen: View {
    @State private var updater = Updater()
    @State private var appeared = false
    @State private var float = false
    @State private var spin = false
    @State private var copied = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 6)
            portrait
                .scaleEffect(appeared ? 1 : 0.85).opacity(appeared ? 1 : 0)
            VStack(spacing: 12) {
                Text("THE MAKER")
                    .font(.system(size: 11, weight: .semibold)).kerning(2.2)
                    .foregroundStyle(.white.opacity(0.5))
                Text(Developer.name)
                    .font(.display(38, .bold)).tracking(-0.8)
                Text("Designer & developer. I made Super Mac because keeping your Mac clean shouldn't need a subscription. Ideas, bugs, or just hi — my inbox is open.")
                    .font(.system(size: 15)).foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center).frame(maxWidth: 520)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)

            HStack(spacing: 10) {
                ForEach(Array(Developer.links.enumerated()), id: \.1.id) { i, l in
                    BrandCapsule(social: l)
                        .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(i) * 0.07), value: appeared)
                }
            }
            .padding(.top, 22)

            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(Developer.email, forType: .string)
                withAnimation(.spring(response: 0.3)) { copied = true }
                Task { try? await Task.sleep(for: .seconds(1.6)); withAnimation { copied = false } }
            } label: {
                HStack(spacing: 6) {
                    Text(Developer.email)
                    Image(systemName: copied ? "checkmark" : "doc.on.doc").font(.system(size: 10, weight: .semibold))
                        .contentTransition(.symbolEffect(.replace))
                }
                .font(.system(size: 12)).foregroundStyle(.white.opacity(copied ? 0.9 : 0.45))
            }
            .buttonStyle(.plain).padding(.top, 14).help("Copy email")
            .opacity(appeared ? 1 : 0)

            Spacer(minLength: 10)
            appStrip
                .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 16)
                .padding(.horizontal, 32).padding(.bottom, 22)
        }
        .padding(.horizontal, 40)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) { appeared = true }
            withAnimation(.easeInOut(duration: 3.2).repeatForever()) { float = true }
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) { spin = true }
        }
    }

    /// The developer photo treated like the 3D glass art: floating, glowing, with a glass rim.
    var portrait: some View {
        let ring = AngularGradient(colors: [.violet, .pinkish, .amber, .aqua, .violet], center: .center)
        return ZStack {
            Ellipse().fill(Color.violet.opacity(0.55))
                .frame(width: 210, height: 110).blur(radius: 60).offset(y: 50)
                .opacity(float ? 0.9 : 0.6)
            Circle().fill(ring).frame(width: 176, height: 176).blur(radius: 26).opacity(0.55)
                .rotationEffect(.degrees(spin ? 360 : 0))
            Circle().strokeBorder(ring, lineWidth: 2.5).frame(width: 178, height: 178)
                .rotationEffect(.degrees(spin ? 360 : 0))
            Group {
                if let img = ArtCache.image("developer") {
                    Image(nsImage: img).resizable().interpolation(.high).scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill").resizable().foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(width: 164, height: 164)
            .clipShape(Circle())
            .overlay(Circle().fill(LinearGradient(colors: [.white.opacity(0.28), .clear], startPoint: .top, endPoint: .center)))
            .overlay(Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.08)], startPoint: .top, endPoint: .bottom), lineWidth: 1.5))
            .shadow(color: .black.opacity(0.45), radius: 30, y: 24)
        }
        .offset(y: float ? -6 : 6)
        .frame(height: 230)
    }

    var appStrip: some View {
        HStack(spacing: 14) {
            if let icon = ArtCache.image("app_icon") {
                Image(nsImage: icon).resizable().interpolation(.high).frame(width: 40, height: 40)
                    .shadow(color: .violet.opacity(0.5), radius: 8)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Super Mac").font(.system(size: 14, weight: .bold))
                    Text(AppInfo.label.uppercased())
                        .font(.system(size: 9, weight: .heavy)).kerning(1)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(LinearGradient(colors: [.violet, .pinkish], startPoint: .leading, endPoint: .trailing), in: Capsule())
                }
                Text("Free · private · open source · © 2026 \(Developer.name)")
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
            updateButton
            Button { NSWorkspace.shared.open(AppInfo.repoURL) } label: {
                Label("GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
            }
            .buttonStyle(GhostButtonStyle())
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: 760)
        .glass(20)
    }

    @ViewBuilder var updateButton: some View {
        switch updater.state {
        case .available(let tag):
            Button { NSWorkspace.shared.open(AppInfo.releasesURL) } label: { Label("Get \(tag)", systemImage: "arrow.down.circle.fill") }
                .buttonStyle(PrimaryButtonStyle(colors: [.mint, .teal]))
        case .checking:
            Button {} label: { HStack(spacing: 8) { ProgressView().controlSize(.small).tint(.white); Text("Checking…") } }
                .buttonStyle(GhostButtonStyle()).disabled(true)
        case .upToDate:
            Button { updater.check() } label: { Label("Up to date", systemImage: "checkmark.circle.fill") }
                .buttonStyle(GhostButtonStyle())
        case .failed:
            Button { updater.check() } label: { Label("Retry update check", systemImage: "arrow.clockwise") }
                .buttonStyle(GhostButtonStyle())
        case .idle:
            Button { updater.check() } label: { Label("Check for updates", systemImage: "arrow.triangle.2.circlepath") }
                .buttonStyle(GhostButtonStyle())
        }
    }
}


// MARK: - Autopilot chip (Smart Care home)

struct AutopilotChip: View {
    let s: AppState
    @State private var hover = false
    var body: some View {
        let p = Prefs.shared, h = History.shared
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { s.settingsTab = .automation; s.page = .settings }
        } label: {
            HStack(spacing: 10) {
                Circle().fill(p.autoScan == .off ? Color.white.opacity(0.35) : Color.mint).frame(width: 7, height: 7)
                    .shadow(color: p.autoScan == .off ? .clear : .mint, radius: 4)
                Text(p.autoScan == .off ? "Autopilot is off" : "Autopilot: \(p.autoScan.title.lowercased())")
                    .font(.system(size: 12, weight: .semibold))
                if h.totalFreed > 0 {
                    Text("·").opacity(0.4)
                    Text("\(fmt(h.totalFreed)) freed so far").font(.system(size: 12)).foregroundStyle(.white.opacity(0.6))
                }
                Text(p.autoScan == .off ? "Set up" : "Edit").font(.system(size: 12, weight: .bold)).foregroundStyle(Color.lilac)
                Image(systemName: "chevron.right").font(.system(size: 9, weight: .bold)).foregroundStyle(Color.lilac)
                    .offset(x: hover ? 2 : 0)
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .glassCapsule()
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.3)) { hover = h } }
    }
}

// MARK: - Mac Health badge (Smart Care home)

struct HealthBadge: View {
    let s: AppState
    var body: some View {
        let r = HealthReport.compute(s)
        HStack(spacing: 10) {
            ZStack {
                Ring(value: Double(r.score) / 100, colors: r.colors, lineWidth: 5).frame(width: 34, height: 34)
                Text("\(r.score)").font(.system(size: 11, weight: .heavy)).contentTransition(.numericText())
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("Mac Health").font(.system(size: 12, weight: .bold))
                Text(r.label).font(.system(size: 10, weight: .semibold)).foregroundStyle(r.colors[0])
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 9).glass(14, tint: r.colors[0])
        .fixedSize()
        .help(r.notes.isEmpty ? "Everything looks great." : r.notes.joined(separator: "\n"))
        .animation(.smooth, value: r.score)
    }
}

// MARK: - Command palette (⌘K)

struct PaletteItem: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let colors: [Color]
    let run: @MainActor () -> Void
}

struct CommandPalette: View {
    @Bindable var s: AppState
    @State private var query = ""
    @State private var index = 0
    @FocusState private var focused: Bool

    var items: [PaletteItem] {
        let go: (Module) -> PaletteItem = { m in
            PaletteItem(id: m.rawValue, title: m.title, subtitle: m.headline, symbol: m.symbol, colors: m.colors) { s.module = m; s.page = nil }
        }
        let settings: (SettingsTab, String) -> PaletteItem = { t, sub in
            PaletteItem(id: "settings." + t.rawValue, title: t.title, subtitle: sub, symbol: t.symbol, colors: [.lilac, .violet]) { s.settingsTab = t; s.page = .settings }
        }
        return [
            PaletteItem(id: "quick", title: "Quick Clean", subtitle: "Remove caches, logs and temp files now", symbol: "wand.and.stars", colors: [.mint, .teal]) {
                Task { await Automation.shared.runNow(automatic: false, forceClean: true) }
            },
            PaletteItem(id: "smartscan", title: "Run Smart Scan", subtitle: "Check everything at once", symbol: "sparkles", colors: [.violet, .pinkish]) {
                s.module = .smartCare; s.page = nil; s.smart.scan(s)
            },
        ] + Module.allCases.map(go) + [
            settings(.automation, "Schedule scans and smart alerts"),
            settings(.history, "What Super Mac cleaned, plus the disk forecast"),
            settings(.exclusions, "Folders Super Mac never touches"),
            settings(.cleanup, "Choose what Cleanup looks for"),
            settings(.general, "Launch at login, Dock, menu bar"),
            PaletteItem(id: "trash", title: "Open Trash", subtitle: "See what's waiting to be emptied", symbol: "trash.fill", colors: [.pinkish, .rose]) {
                NSWorkspace.shared.open(home(".Trash"))
            },
            PaletteItem(id: "about", title: "About Super Mac", subtitle: "Version, updates and the maker", symbol: "info.circle.fill", colors: [.violet, .pinkish]) { s.page = .about },
        ]
    }

    var filtered: [PaletteItem] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return items }
        return items.filter { ($0.title + " " + $0.subtitle).lowercased().contains(q) }
    }

    func perform(_ it: PaletteItem) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { s.showPalette = false }
        it.run()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { withAnimation(.spring(response: 0.3)) { s.showPalette = false } }
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white.opacity(0.6))
                    TextField("Search actions…", text: $query)
                        .textFieldStyle(.plain).font(.system(size: 19, weight: .medium))
                        .focused($focused)
                        .onSubmit { if let it = filtered[safe: index] { perform(it) } }
                    Text("esc").font(.system(size: 10, weight: .semibold)).padding(.horizontal, 6).padding(.vertical, 3)
                        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 5)).foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 18).padding(.vertical, 15)
                Rectangle().fill(.white.opacity(0.08)).frame(height: 1)
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(Array(filtered.enumerated()), id: \.1.id) { i, it in
                                Button { perform(it) } label: {
                                    HStack(spacing: 12) {
                                        IconTile(symbol: it.symbol, colors: it.colors, size: 30)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(it.title).font(.system(size: 13.5, weight: .semibold))
                                            Text(it.subtitle).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
                                        }
                                        Spacer()
                                        if i == index { Image(systemName: "return").font(.system(size: 11, weight: .semibold)).foregroundStyle(.white.opacity(0.5)) }
                                    }
                                    .padding(.horizontal, 10).padding(.vertical, 7)
                                    .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(i == index ? Color.white.opacity(0.1) : .clear))
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain).id(i)
                                .onHover { if $0 { index = i } }
                            }
                            if filtered.isEmpty {
                                Text("No matching actions").font(.system(size: 13)).foregroundStyle(.white.opacity(0.45)).padding(24)
                            }
                        }
                        .padding(8)
                    }
                    .frame(maxHeight: 360)
                    .onChange(of: index) { _, i in withAnimation(.easeOut(duration: 0.12)) { proxy.scrollTo(i) } }
                }
            }
            .frame(width: 580)
            .background(Color(hex: 0x14112A).opacity(0.82), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .glass(22)
            .shadow(color: .black.opacity(0.5), radius: 40, y: 20)
            .padding(.top, 90)
            .transition(.scale(scale: 0.96).combined(with: .opacity))
        }
        .onAppear { focused = true; index = 0 }
        .onChange(of: query) { _, _ in index = 0 }
        .onKeyPress(.downArrow) { index = min(index + 1, max(filtered.count - 1, 0)); return .handled }
        .onKeyPress(.upArrow) { index = max(index - 1, 0); return .handled }
        .onKeyPress(.escape) { withAnimation(.spring(response: 0.3)) { s.showPalette = false }; return .handled }
    }
}

extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}
