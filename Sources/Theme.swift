import SwiftUI
import AppKit

// MARK: - Colors

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xff) / 255,
                  green: Double((hex >> 8) & 0xff) / 255,
                  blue: Double(hex & 0xff) / 255,
                  opacity: alpha)
    }
    static let violet = Color(hex: 0x8B5CF6)
    static let magenta = Color(hex: 0xD946EF)
    static let pinkish = Color(hex: 0xEC4899)
    static let aqua = Color(hex: 0x22D3EE)
    static let sky = Color(hex: 0x3B82F6)
    static let amber = Color(hex: 0xF59E0B)
    static let coral = Color(hex: 0xFB7185)
    static let mint = Color(hex: 0x10B981)
    static let teal = Color(hex: 0x14B8A6)
    static let rose = Color(hex: 0xF43F5E)
    static let lilac = Color(hex: 0xA78BFA)
    static let peach = Color(hex: 0xFDBA74)
}

let brandGradient = LinearGradient(colors: [.violet, .pinkish], startPoint: .topLeading, endPoint: .bottomTrailing)
let ringGradient = AngularGradient(colors: [.violet, .pinkish, .amber, .aqua, .sky, .violet], center: .center)

// MARK: - Modules

enum Module: String, CaseIterable, Identifiable {
    case smartCare, cleanup, protection, performance, applications, clutter, spaceLens
    var id: String { rawValue }

    var title: String {
        switch self {
        case .smartCare: "Smart Care"
        case .cleanup: "Cleanup"
        case .protection: "Protection"
        case .performance: "Performance"
        case .applications: "Applications"
        case .clutter: "My Clutter"
        case .spaceLens: "Space Lens"
        }
    }

    var headline: String {
        switch self {
        case .smartCare: "Everything your Mac needs, in one scan"
        case .cleanup: "Clear out the junk you never see"
        case .protection: "Keep your Mac private and adware-free"
        case .performance: "Make your Mac feel fast again"
        case .applications: "Uninstall apps completely"
        case .clutter: "Find big, old and duplicate files"
        case .spaceLens: "See what's taking up your disk"
        }
    }

    var blurb: String {
        switch self {
        case .smartCare: "Cleanup, protection, speed, apps and clutter — checked together, with one button to fix what's safe."
        case .cleanup: "Caches, logs, temporary files, developer junk and more. Apps rebuild these automatically."
        case .protection: "Check launch agents against known adware and wipe browser history, cookies and recent-items lists."
        case .performance: "Run maintenance scripts, manage background items and spot the apps eating your memory."
        case .applications: "Remove apps along with the support files, caches and preferences they leave behind."
        case .clutter: "Large files you forgot about, duplicate copies and old installers — all sent safely to the Trash."
        case .spaceLens: "An interactive map of your storage. Click through folders to find what's huge."
        }
    }

    var features: [(String, String)] {
        switch self {
        case .smartCare: [("sparkles", "One-click care"), ("shield.lefthalf.filled", "Safety checks"), ("bolt.fill", "Speed tips")]
        case .cleanup: [("shippingbox.fill", "App caches"), ("doc.text.fill", "Logs"), ("hammer.fill", "Dev junk")]
        case .protection: [("checkmark.shield.fill", "Adware check"), ("hand.raised.fill", "Privacy"), ("clock.fill", "Recent items")]
        case .performance: [("memorychip.fill", "Free up RAM"), ("network", "Flush DNS"), ("power", "Login items")]
        case .applications: [("trash.fill", "Uninstaller"), ("puzzlepiece.extension.fill", "Leftovers"), ("clock.badge.questionmark.fill", "Unused apps")]
        case .clutter: [("externaldrive.fill", "Large files"), ("doc.on.doc.fill", "Duplicates"), ("shippingbox.and.arrow.backward.fill", "Old installers")]
        case .spaceLens: [("square.grid.3x3.fill", "Storage map"), ("folder.fill", "Drill down"), ("magnifyingglass", "Reveal")]
        }
    }

    var colors: [Color] {
        switch self {
        case .smartCare: [.violet, .pinkish]
        case .cleanup: [.mint, .teal]
        case .protection: [.sky, .aqua]
        case .performance: [.amber, .coral]
        case .applications: [.sky, .violet]
        case .clutter: [.lilac, .peach]
        case .spaceLens: [.aqua, .magenta]
        }
    }

    var art: String {
        switch self {
        case .smartCare: "smart_care"
        case .cleanup: "cleanup"
        case .protection: "protection"
        case .performance: "performance"
        case .applications: "applications"
        case .clutter: "clutter"
        case .spaceLens: "space_lens"
        }
    }

    var symbol: String {
        switch self {
        case .smartCare: "sparkles"
        case .cleanup: "bubbles.and.sparkles.fill"
        case .protection: "checkmark.shield.fill"
        case .performance: "gauge.with.dots.needle.67percent"
        case .applications: "square.stack.3d.up.fill"
        case .clutter: "archivebox.fill"
        case .spaceLens: "circle.hexagongrid.fill"
        }
    }
}

// MARK: - Art (generated PNG illustrations, with SF Symbol fallback)

enum ArtCache {
    static var images: [String: NSImage] = [:]
    static func image(_ name: String) -> NSImage? {
        if let i = images[name] { return i }
        guard let url = Bundle.main.url(forResource: name, withExtension: "png"),
              let img = NSImage(contentsOf: url) else { return nil }
        images[name] = img
        return img
    }
}

struct ArtView: View {
    let module: Module
    var size: CGFloat
    var body: some View {
        if let img = ArtCache.image(module.art) {
            Image(nsImage: img).resizable().interpolation(.high).scaledToFit()
                .frame(width: size, height: size)
        } else {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(LinearGradient(colors: module.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Image(systemName: module.symbol).font(.system(size: size * 0.42, weight: .semibold)).foregroundStyle(.white))
                .frame(width: size * 0.8, height: size * 0.8)
                .frame(width: size, height: size)
        }
    }
}

struct FloatingArt: View {
    let module: Module
    var size: CGFloat = 260
    @State private var up = false
    var body: some View {
        ZStack {
            Ellipse().fill(module.colors[0].opacity(0.55))
                .frame(width: size * 0.9, height: size * 0.5)
                .blur(radius: 60).offset(y: size * 0.18)
                .opacity(up ? 0.9 : 0.6)
            ArtView(module: module, size: size)
                .shadow(color: .black.opacity(0.45), radius: 30, y: 24)
                .offset(y: up ? -6 : 6)
        }
        .onAppear { withAnimation(.easeInOut(duration: 3.2).repeatForever()) { up = true } }
    }
}

// MARK: - Background: dark animated blur gradient

struct AnimatedBackground: View {
    var colors: [Color]
    var body: some View {
        ZStack {
            Color(hex: 0x07060D)
            if #available(macOS 15, *) {
                TimelineView(.animation(minimumInterval: 1 / 30, paused: Prefs.shared.reduceMotion)) { tl in
                    let t = tl.date.timeIntervalSinceReferenceDate
                    let a = Float(sin(t * 0.21)) * 0.18, b = Float(cos(t * 0.17)) * 0.18
                    MeshGradient(width: 3, height: 3, points: [
                        [0, 0], [0.5 + a, 0], [1, 0],
                        [0, 0.5 + b], [0.5 + b, 0.5 - a], [1, 0.5 + a],
                        [0, 1], [0.5 - a, 1], [1, 1],
                    ], colors: [
                        Color(hex: 0x07060D), colors[0].opacity(0.55), Color(hex: 0x0B0A16),
                        colors[1].opacity(0.35), Color(hex: 0x120D24), colors[0].opacity(0.3),
                        Color(hex: 0x07060D), colors[1].opacity(0.25), Color(hex: 0x07060D),
                    ])
                    .blur(radius: 40)
                }
            } else {
                LegacyBlobs(colors: colors)
            }
            // vignette + subtle top light
            RadialGradient(colors: [.clear, .black.opacity(0.55)], center: .center, startRadius: 200, endRadius: 900)
            LinearGradient(colors: [.white.opacity(0.04), .clear], startPoint: .top, endPoint: .center)
        }
        .ignoresSafeArea()
    }
}

struct LegacyBlobs: View {
    var colors: [Color]
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: Prefs.shared.reduceMotion)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for (i, c) in [colors[0], colors[1], Color.violet].enumerated() {
                    let d = Double(i) * 2
                    let x = size.width * (0.55 + 0.35 * cos(t * 0.08 + d)), y = size.height * (0.5 + 0.35 * sin(t * 0.1 + d))
                    let r = min(size.width, size.height) * 0.45
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(c.opacity(0.3)))
                }
            }
            .blur(radius: 120)
        }
    }
}

// MARK: - Typography (SF Pro, Apple-style tracking)

extension Font {
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font { .system(size: size, weight: weight) }
}

// MARK: - Glass (Apple Liquid Glass on macOS 26+, material fallback)

enum GlassConfig { nonisolated(unsafe) static var liquid = true }

struct Glass: ViewModifier {
    var radius: CGFloat = 20
    var tint: Color? = nil
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        if #available(macOS 26, *), GlassConfig.liquid {
            content
                .glassEffect(.regular.tint((tint ?? .white).opacity(tint == nil ? 0.02 : 0.18)), in: shape)
        } else {
            content
                .background(.white.opacity(0.05), in: shape)
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.22), .white.opacity(0.03)],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        }
    }
}

extension View {
    func glass(_ r: CGFloat = 20, tint: Color? = nil) -> some View { modifier(Glass(radius: r, tint: tint)) }
    @ViewBuilder func glassCapsule(tint: Color? = nil, interactive: Bool = true) -> some View {
        if #available(macOS 26, *), GlassConfig.liquid {
            let g = Glass.Variant.make(tint)
            self.glassEffect(interactive ? g.interactive() : g, in: Capsule())
        } else {
            self.background(tint.map { AnyShapeStyle($0.opacity(0.85)) } ?? AnyShapeStyle(.white.opacity(0.08)), in: Capsule())
                .overlay(Capsule().strokeBorder(.white.opacity(0.18), lineWidth: 1))
        }
    }
}

extension Glass { enum Variant {
    @available(macOS 26, *)
    static func make(_ tint: Color?) -> SwiftUI.Glass { tint.map { SwiftUI.Glass.regular.tint($0.opacity(0.75)) } ?? .regular }
} }

struct PrimaryButtonStyle: ButtonStyle {
    var colors: [Color] = [.violet, .pinkish]
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(LinearGradient(colors: colors.map { $0.opacity(0.9) }, startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
            .glassCapsule(tint: nil)
            .shadow(color: colors.last!.opacity(0.4), radius: configuration.isPressed ? 6 : 16, y: 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white.opacity(0.9))
            .padding(.horizontal, 15).padding(.vertical, 8)
            .glassCapsule()
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

/// The big round glass button used to start scans (bottom-centre, like a hero action).
struct OrbButton: View {
    let title: String
    let colors: [Color]
    let action: () -> Void
    @State private var glow = false
    @State private var hover = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(colors[0].opacity(0.35)).frame(width: 150, height: 150).blur(radius: 30)
                    .scaleEffect(glow ? 1.1 : 0.9)
                Circle()
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(Circle().fill(LinearGradient(colors: [.white.opacity(0.45), .clear], startPoint: .top, endPoint: .center)).padding(3))
                    .overlay(Circle().strokeBorder(LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)], startPoint: .top, endPoint: .bottom), lineWidth: 1.2))
                    .frame(width: 104, height: 104)
                    .shadow(color: colors.last!.opacity(0.55), radius: hover ? 28 : 18, y: 10)
                Text(title).font(.system(size: 17, weight: .semibold)).foregroundStyle(.white)
            }
            .scaleEffect(hover ? 1.06 : 1)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { hover = h } }
        .onAppear { withAnimation(.easeInOut(duration: 2.2).repeatForever()) { glow = true } }
    }
}

// MARK: - Common pieces

struct TagPill: View {
    let text: String
    var color: Color = .white
    var body: some View {
        Text(text).font(.system(size: 10, weight: .semibold)).kerning(0.3)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.2), in: Capsule())
            .foregroundStyle(color == .white ? .white.opacity(0.8) : color)
    }
}

struct SectionTitle: View {
    let text: String
    var trailing: String? = nil
    var body: some View {
        HStack {
            Text(text).font(.system(size: 15, weight: .bold))
            Spacer()
            if let trailing { Text(trailing).font(.system(size: 12)).foregroundStyle(.white.opacity(0.55)) }
        }
    }
}

struct Ring: View {
    var value: Double
    var colors: [Color]
    var lineWidth: CGFloat = 10
    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.08), lineWidth: lineWidth)
            Circle().trim(from: 0, to: max(0.001, min(1, value)))
                .stroke(AngularGradient(colors: colors + [colors[0]], center: .center),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: colors[0].opacity(0.5), radius: 8)
        }
    }
}

struct SpinnerRing: View {
    var colors: [Color]
    var size: CGFloat = 300
    @State private var spin = false
    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.06), lineWidth: 12)
            Circle().trim(from: 0, to: 0.28)
                .stroke(AngularGradient(colors: colors + [.white], center: .center), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(spin ? 360 : 0))
                .shadow(color: colors[0].opacity(0.8), radius: 14)
            Circle().trim(from: 0, to: 0.12)
                .stroke(colors[1].opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .padding(22)
                .rotationEffect(.degrees(spin ? -720 : 0))
        }
        .frame(width: size, height: size)
        .onAppear { withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { spin = true } }
    }
}

func fileIcon(_ url: URL) -> NSImage { NSWorkspace.shared.icon(forFile: url.path) }
