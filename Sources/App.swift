import SwiftUI
import AppKit

struct RootView: View {
    @Bindable var s: AppState
    @Namespace private var ns

    var body: some View {
        ZStack {
            AnimatedBackground(colors: bgColors)
                .animation(.easeInOut(duration: 1.2), value: s.module)
                .animation(.easeInOut(duration: 1.2), value: s.page)
            HStack(spacing: 0) {
                sidebar
                content.frame(maxWidth: .infinity, maxHeight: .infinity).padding(.top, 26)
            }
            if s.showPalette {
                CommandPalette(s: s).zIndex(10)
            }
        }
        .foregroundStyle(.white)
        .frame(minWidth: 1080, minHeight: 700)
        .onAppear {
            Prefs.shared.applyDock()
            Automation.shared.start()
        }
    }

    var bgColors: [Color] {
        switch s.page {
        case .settings: [.lilac, .sky]
        case .about: [.violet, .pinkish]
        case nil: s.module.colors
        }
    }

    func footerButton(_ page: AppState.Page, _ title: String, _ symbol: String) -> some View {
        let sel = s.page == page
        return Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { s.page = page } } label: {
            HStack(spacing: 7) {
                Image(systemName: symbol).font(.system(size: 12, weight: .semibold))
                Text(title).font(.system(size: 12.5, weight: sel ? .bold : .medium))
            }
            .foregroundStyle(.white.opacity(sel ? 1 : 0.7))
            .frame(maxWidth: .infinity).padding(.vertical, 9)
            .background {
                if sel {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [Color.violet.opacity(0.4), Color.pinkish.opacity(0.18)], startPoint: .leading, endPoint: .trailing))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.white.opacity(0.14), lineWidth: 1))
                        .matchedGeometryEffect(id: "sel", in: ns)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(.white.opacity(0.05))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var sidebar: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 10) {
                if let icon = ArtCache.image("app_icon") {
                    Image(nsImage: icon).resizable().interpolation(.high).frame(width: 36, height: 36)
                        .shadow(color: .violet.opacity(0.5), radius: 8)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Super Mac").font(.system(size: 17, weight: .bold)).tracking(-0.3)
                    Text("Care for your Mac").font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.45))
                }
                Spacer()
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { s.showPalette = true } } label: {
                    Image(systemName: "magnifyingglass").font(.system(size: 12, weight: .semibold))
                        .frame(width: 28, height: 28).glassCapsule()
                }
                .buttonStyle(.plain).help("Command Palette  ⌘K")
            }
            .padding(.leading, 8).padding(.top, 34).padding(.bottom, 20)

            item(.smartCare)
            Text("TOOLS").font(.system(size: 10, weight: .semibold)).kerning(1.6)
                .foregroundStyle(.white.opacity(0.35)).padding(.leading, 12).padding(.top, 14).padding(.bottom, 4)
            ForEach(Module.allCases.dropFirst()) { item($0) }
            Spacer()
            MiniStats(stats: s.stats).padding(.bottom, 8)
            HStack(spacing: 6) {
                footerButton(.settings, "Settings", "gearshape.fill")
                footerButton(.about, "About", "info.circle.fill")
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 10)
        .frame(width: 236)
        .frame(maxHeight: .infinity)
        .background(Color(hex: 0x0B0A14).opacity(0.55), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .glass(26)
        .padding(10)
    }

    func item(_ mod: Module) -> some View {
        let selected = s.module == mod && s.page == nil
        return Button { withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { s.module = mod; s.page = nil } } label: {
            HStack(spacing: 12) {
                ArtView(module: mod, size: 26).scaleEffect(selected ? 1.1 : 1)
                Text(mod.title).font(.system(size: 14, weight: selected ? .bold : .medium))
                    .foregroundStyle(.white.opacity(selected ? 1 : 0.72))
                Spacer()
                badge(mod)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [mod.colors[0].opacity(0.32), mod.colors[1].opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(.white.opacity(0.14), lineWidth: 1))
                        .matchedGeometryEffect(id: "sel", in: ns)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder func badge(_ mod: Module) -> some View {
        switch mod {
        case .cleanup where s.cleanup.phase == .results && s.cleanup.total > 0:
            TagPill(text: fmt(s.cleanup.total))
        case .protection where s.protection.phase == .results && !s.protection.threats.isEmpty:
            TagPill(text: "\(s.protection.threats.count)", color: .rose)
        case .applications where s.apps.phase == .results:
            TagPill(text: "\(s.apps.apps.count)")
        default: EmptyView()
        }
    }

    @ViewBuilder var content: some View {
        ZStack {
            if let page = s.page {
                switch page {
                case .settings: SettingsScreen(s: s)
                case .about: AboutScreen()
                }
            } else {
            switch s.module {
            case .smartCare: SmartCareScreen(s: s)
            case .cleanup: CleanupScreen(m: s.cleanup)
            case .protection: ProtectionScreen(m: s.protection)
            case .performance: PerformanceScreen(m: s.performance, stats: s.stats)
            case .applications: ApplicationsScreen(m: s.apps)
            case .clutter: ClutterScreen(m: s.clutter)
            case .spaceLens: SpaceLensScreen(m: s.lens)
            }
            }
        }
        .id(s.page.map { "\($0)" } ?? s.module.rawValue)
        .transition(.asymmetric(insertion: .opacity.combined(with: .offset(y: 14)), removal: .opacity))
    }
}

struct MiniStats: View {
    let stats: LiveStats
    var body: some View {
        VStack(spacing: 10) {
            bar("internaldrive.fill", "Disk", stats.disk.usedFraction, "\(fmt(stats.disk.free)) free", [.aqua, .sky])
            bar("memorychip.fill", "Memory", stats.memFraction, "\(Int(stats.memFraction * 100))%", [.violet, .pinkish])
            bar("cpu.fill", "CPU", stats.cpu, "\(Int(stats.cpu * 100))%", [.amber, .coral])
        }
        .padding(14).glass(16)
    }
    func bar(_ icon: String, _ t: String, _ v: Double, _ d: String, _ c: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon).font(.system(size: 10)).foregroundStyle(c[0])
                Text(t).font(.system(size: 11, weight: .semibold))
                Spacer()
                Text(d).font(.system(size: 10)).foregroundStyle(.white.opacity(0.55)).contentTransition(.numericText())
            }
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.1))
                    Capsule().fill(LinearGradient(colors: c, startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(4, g.size.width * min(1, v)))
                }
            }
            .frame(height: 4)
            .animation(.smooth, value: v)
        }
    }
}

struct MenuBarPanel: View {
    let s: AppState
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                if let icon = ArtCache.image("app_icon") { Image(nsImage: icon).resizable().frame(width: 24, height: 24) }
                Text("Super Mac").font(.system(size: 15, weight: .bold))
                Spacer()
            }
            MiniStats(stats: s.stats)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    IconTile(symbol: "clock.arrow.2.circlepath", colors: [.sky, .violet], size: 28)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(Prefs.shared.nextAutoRun.map { "Next check \($0.formatted(.relative(presentation: .named)))" } ?? "Automation is off")
                            .font(.system(size: 12, weight: .semibold))
                        Text(Automation.shared.lastResult ?? "Freed \(fmt(History.shared.totalFreed)) so far")
                            .font(.system(size: 10.5)).foregroundStyle(.white.opacity(0.55)).lineLimit(1)
                    }
                    Spacer()
                }
                Button {
                    Task { await Automation.shared.runNow(automatic: false, forceClean: true) }
                } label: {
                    HStack(spacing: 8) {
                        if Automation.shared.running { ProgressView().controlSize(.small).tint(.white) } else { Image(systemName: "wand.and.stars") }
                        Text(Automation.shared.running ? "Cleaning…" : "Quick Clean")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(colors: [.mint, .teal]))
                .disabled(Automation.shared.running)
                .help("Removes caches, logs and temp files only")
            }
            .padding(12).glass(14)
            HStack {
                Button("Open Super Mac") { show(nil) }
                    .buttonStyle(PrimaryButtonStyle())
                Spacer()
                Button { show(.settings) } label: { Image(systemName: "gearshape.fill") }.buttonStyle(GhostButtonStyle()).help("Settings")
                Button("Quit") { NSApp.terminate(nil) }.buttonStyle(GhostButtonStyle())
            }
        }
        .padding(16)
        .frame(width: 290)
        .background(LinearGradient(colors: [Color(hex: 0x1A1033), Color(hex: 0x0C0A1C)], startPoint: .top, endPoint: .bottom))
        .foregroundStyle(.white)
        .environment(\.colorScheme, .dark)
    }

    func show(_ page: AppState.Page?) {
        if let page { s.page = page }
        NSApp.activate(ignoringOtherApps: true)
        if let w = NSApp.windows.first(where: { $0.canBecomeMain }) { w.makeKeyAndOrderFront(nil) } else { openWindow(id: "main") }
    }
}

struct MenuBarLabel: View {
    let s: AppState
    var body: some View {
        if Prefs.shared.menuBarFreeSpace {
            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                Text(fmt(s.stats.disk.free))
            }
        } else {
            Image(systemName: "sparkles")
        }
    }
}

@main
struct SuperMacApp: App {
    @State private var state = AppState()

    init() { Automation.shared.start() }

    var body: some Scene {
        Window("Super Mac", id: "main") {
            RootView(s: state).preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1160, height: 760)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") { state.page = .settings }.keyboardShortcut(",")
            }
            CommandGroup(replacing: .appInfo) {
                Button("About Super Mac") { state.page = .about }
            }
            CommandMenu("Go") {
                Button("Command Palette…") { withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { state.showPalette.toggle() } }
                    .keyboardShortcut("k", modifiers: .command)
                Divider()
                ForEach(Array(Module.allCases.enumerated()), id: \.1) { i, m in
                    Button(m.title) { state.module = m; state.page = nil }
                        .keyboardShortcut(KeyEquivalent(Character("\(i + 1)")), modifiers: .command)
                }
                Divider()
                Button("Automation") { state.page = .settings; state.settingsTab = .automation }
                    .keyboardShortcut("8", modifiers: .command)
                Button("History") { state.page = .settings; state.settingsTab = .history }
                    .keyboardShortcut("9", modifiers: .command)
            }
        }

        MenuBarExtra {
            MenuBarPanel(s: state)
        } label: {
            MenuBarLabel(s: state)
        }
        .menuBarExtraStyle(.window)
    }
}
