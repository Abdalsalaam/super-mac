import SwiftUI
import AppKit

// MARK: - Module screens

struct ModuleLanding<Extra: View>: View {
    let module: Module
    var buttonTitle = "Scan"
    let action: () -> Void
    @ViewBuilder var extra: () -> Extra
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 10)
            FloatingArt(module: module, size: 230)
                .scaleEffect(appeared ? 1 : 0.85).opacity(appeared ? 1 : 0)
            VStack(spacing: 12) {
                Text(module.title.uppercased())
                    .font(.system(size: 11, weight: .semibold)).kerning(2.2)
                    .foregroundStyle(.white.opacity(0.5))
                Text(module.headline)
                    .font(.display(38, .bold)).tracking(-0.8)
                    .multilineTextAlignment(.center)
                Text(module.blurb).font(.system(size: 15)).foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center).frame(maxWidth: 520)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 12)

            HStack(spacing: 10) {
                ForEach(Array(module.features.enumerated()), id: \.offset) { i, f in
                    HStack(spacing: 8) {
                        Image(systemName: f.0).font(.system(size: 12, weight: .semibold)).foregroundStyle(module.colors[0])
                        Text(f.1).font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 14).padding(.vertical, 9)
                    .glassCapsule(interactive: false)
                    .opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 10)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(i) * 0.07), value: appeared)
                }
            }
            .padding(.top, 22)
            extra().padding(.top, 16)
            Spacer(minLength: 10)
            OrbButton(title: buttonTitle, colors: module.colors, action: action)
                .scaleEffect(appeared ? 1 : 0.6).opacity(appeared ? 1 : 0)
                .padding(.bottom, 26)
        }
        .padding(.horizontal, 40)
        .onAppear { withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) { appeared = true } }
    }
}

extension ModuleLanding where Extra == EmptyView {
    init(module: Module, buttonTitle: String = "Scan", action: @escaping () -> Void) {
        self.init(module: module, buttonTitle: buttonTitle, action: action, extra: { EmptyView() })
    }
}

struct ScanningScreen: View {
    let module: Module
    var title: String
    var detail: String
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                SpinnerRing(colors: module.colors, size: 300)
                ArtView(module: module, size: 190)
                    .shadow(color: module.colors[0].opacity(0.5), radius: 24)
                    .modifier(Breathing())
            }
            VStack(spacing: 8) {
                Text(title).font(.system(size: 26, weight: .bold))
                Text(detail).font(.system(size: 14)).foregroundStyle(.white.opacity(0.55))
                    .contentTransition(.opacity)
            }
        }
    }
}

struct Breathing: ViewModifier {
    @State private var on = false
    func body(content: Content) -> some View {
        content.scaleEffect(on ? 1.05 : 0.95)
            .onAppear { withAnimation(.easeInOut(duration: 1.2).repeatForever()) { on = true } }
    }
}

struct WorkingScreen: View {
    let module: Module
    var title: String
    var progress: Double? = nil
    var detail: String = ""
    var body: some View {
        ZStack {
            Bubbles().ignoresSafeArea()
            VStack(spacing: 30) {
                ZStack {
                    if let progress {
                        Ring(value: progress, colors: module.colors + [.white], lineWidth: 16).frame(width: 260, height: 260)
                        Text("\(Int(progress * 100))%").font(.system(size: 50, weight: .heavy))
                            .contentTransition(.numericText())
                    } else {
                        SpinnerRing(colors: module.colors, size: 260)
                        ArtView(module: module, size: 150).modifier(Breathing())
                    }
                }
                VStack(spacing: 8) {
                    Text(title).font(.system(size: 26, weight: .bold))
                    Text(detail).font(.system(size: 13, design: .monospaced)).foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1).truncationMode(.middle).frame(width: 400)
                }
            }
        }
    }
}

struct DoneScreen: View {
    let module: Module
    var big: String
    var subtitle: String
    var lines: [String] = []
    var buttonTitle = "Done"
    let action: () -> Void
    @State private var pop = false
    @State private var ripple = false

    var body: some View {
        ZStack {
            Confetti(colors: module.colors + [.white, .amber, .aqua]).ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle().stroke(module.colors[0].opacity(0.6), lineWidth: 2).frame(width: 140, height: 140)
                        .scaleEffect(ripple ? 2 : 1).opacity(ripple ? 0 : 1)
                    Circle().fill(LinearGradient(colors: module.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 140, height: 140)
                        .overlay(Circle().fill(LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .center)))
                        .shadow(color: module.colors[0].opacity(0.6), radius: 30)
                    Image(systemName: "checkmark").font(.system(size: 58, weight: .heavy)).foregroundStyle(.white)
                        .bounceEffect(value: pop)
                }
                .scaleEffect(pop ? 1 : 0.3)
                VStack(spacing: 8) {
                    Text(big).font(.system(size: 54, weight: .heavy)).multilineTextAlignment(.center)
                    Text(subtitle).font(.system(size: 16)).foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center).frame(maxWidth: 520)
                    if !lines.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(lines, id: \.self) { l in
                                Label(l, systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .padding(16).glass(16).padding(.top, 8)
                    }
                }
                .opacity(pop ? 1 : 0).offset(y: pop ? 0 : 20)
                Button(buttonTitle, action: action).buttonStyle(PrimaryButtonStyle(colors: module.colors))
                    .keyboardShortcut(.defaultAction).opacity(pop ? 1 : 0).padding(.top, 6)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.55)) { pop = true }
            withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) { ripple = true }
        }
    }
}

/// Header shown at the top of results screens.
struct ResultsHeader: View {
    let module: Module
    var title: String
    var subtitle: String
    var body: some View {
        HStack(spacing: 18) {
            ArtView(module: module, size: 74).shadow(color: module.colors[0].opacity(0.4), radius: 14)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 30, weight: .heavy)).contentTransition(.numericText())
                Text(subtitle).font(.system(size: 14)).foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(.horizontal, 32).padding(.top, 8)
    }
}

struct BottomBar<Left: View>: View {
    let module: Module
    var title: String
    var detail: String
    var disabled: Bool
    let action: () -> Void
    @ViewBuilder var left: () -> Left

    var body: some View {
        HStack(spacing: 12) {
            left()
            Spacer()
            Button(action: action) {
                HStack(spacing: 10) {
                    Text(title)
                    if !detail.isEmpty && !disabled { Text(detail).opacity(0.85).contentTransition(.numericText()) }
                }
            }
            .buttonStyle(PrimaryButtonStyle(colors: module.colors))
            .disabled(disabled).opacity(disabled ? 0.4 : 1)
        }
        .padding(.horizontal, 32).padding(.vertical, 18)
    }
}

// MARK: - Rows

struct FileRow: View {
    @Binding var item: FileItem
    var showDate = false
    var tint: Color = .violet
    @State private var hover = false

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: $item.selected.animation(.snappy)).toggleStyle(.checkbox).labelsHidden()
            Image(nsImage: fileIcon(item.url)).resizable().frame(width: 30, height: 30)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(item.url.lastPathComponent).font(.system(size: 13, weight: .semibold)).lineLimit(1)
                    if !item.note.isEmpty && item.note.count < 14 { TagPill(text: item.note, color: item.note == "Original" ? .mint : .white) }
                }
                Text(item.note.count >= 14 ? item.note : tilde(item.url.deletingLastPathComponent()))
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.45))
                    .lineLimit(1).truncationMode(.middle)
            }
            Spacer(minLength: 8)
            if showDate {
                Text(relativeDate(item.date)).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5))
                    .frame(width: 90, alignment: .trailing)
            }
            Text(fmt(item.size)).font(.system(size: 13, weight: .semibold)).monospacedDigit()
                .frame(width: 80, alignment: .trailing)
            Button { NSWorkspace.shared.activateFileViewerSelecting([item.url]) } label: {
                Image(systemName: "magnifyingglass").font(.system(size: 12, weight: .semibold))
            }
            .buttonStyle(.plain).foregroundStyle(.white.opacity(hover ? 0.9 : 0.35)).help("Show in Finder")
        }
        .padding(.horizontal, 14).padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(item.selected ? tint.opacity(0.14) : .white.opacity(hover ? 0.06 : 0.02)))
        .onHover { h in withAnimation(.easeOut(duration: 0.15)) { hover = h } }
    }
}

struct EmptyState: View {
    var symbol: String
    var title: String
    var subtitle: String
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol).font(.system(size: 40)).foregroundStyle(brandGradient)
            Text(title).font(.system(size: 18, weight: .bold))
            Text(subtitle).font(.system(size: 13)).foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(40)
    }
}

struct Chip: View {
    let title: String
    let selected: Bool
    var count: Int? = nil
    var colors: [Color]
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                if let count { Text("\(count)").opacity(0.7) }
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background {
                if selected {
                    Capsule().fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                } else { Capsule().fill(.white.opacity(0.07)) }
            }
            .overlay(Capsule().strokeBorder(.white.opacity(selected ? 0.3 : 0.1), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Effects

struct Bubbles: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for i in 0..<26 {
                    let seed = Double(i) * 12.9898
                    let fx = abs((sin(seed) * 43758.5453).truncatingRemainder(dividingBy: 1))
                    let cycle = size.height + 60
                    let y = size.height + 30 - (t * (30 + fx * 60) + fx * cycle).truncatingRemainder(dividingBy: cycle)
                    let x = size.width * abs(sin(seed * 1.7)) + sin(t * 0.8 + seed) * 24
                    let r = 3 + 11 * abs(cos(seed))
                    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.05)))
                    ctx.stroke(Path(ellipseIn: rect), with: .color(.white.opacity(0.2)), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct Confetti: View {
    struct Piece { let angle, speed, spin, size, delay: Double; let color: Color }
    var colors: [Color]
    @State private var start = Date()
    @State private var pieces: [Piece] = []

    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSince(start)
            Canvas { ctx, size in
                let c = CGPoint(x: size.width / 2, y: size.height * 0.38)
                for p in pieces {
                    let tt = max(0, t - p.delay)
                    guard tt < 3.2 else { continue }
                    var g = ctx
                    g.opacity = max(0, 1 - tt / 3)
                    g.translateBy(x: c.x + cos(p.angle) * p.speed * tt, y: c.y + sin(p.angle) * p.speed * tt + 300 * tt * tt)
                    g.rotate(by: .radians(p.spin * tt))
                    g.fill(Path(roundedRect: CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2), cornerRadius: 1.5),
                           with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            start = Date()
            pieces = (0..<110).map { _ in
                Piece(angle: .random(in: 0...(2 * .pi)), speed: .random(in: 160...560), spin: .random(in: -9...9),
                      size: .random(in: 6...12), delay: .random(in: 0...0.2), color: colors.randomElement()!)
            }
        }
    }
}

// MARK: - Treemap

func squarify(_ values: [Double], in rect: CGRect) -> [CGRect] {
    var result = [CGRect](repeating: .zero, count: values.count)
    let total = values.reduce(0, +)
    guard total > 0, rect.width > 0, rect.height > 0 else { return result }
    let scale = Double(rect.width * rect.height) / total
    let areas = values.map { $0 * scale }
    func worst(_ row: [Double], _ w: Double) -> Double {
        let s = row.reduce(0, +)
        guard s > 0, let mx = row.max(), let mn = row.min(), mn > 0 else { return .infinity }
        return max(w * w * mx / (s * s), s * s / (w * w * mn))
    }
    var r = rect
    var i = 0
    while i < areas.count {
        let short = Double(min(r.width, r.height))
        var row = [i]
        var best = worst([areas[i]], short)
        var j = i + 1
        while j < areas.count {
            let w = worst((row + [j]).map { areas[$0] }, short)
            if w <= best { row.append(j); best = w; j += 1 } else { break }
        }
        let rowArea = row.reduce(0.0) { $0 + areas[$1] }
        if r.width >= r.height {
            let colW = CGFloat(rowArea) / r.height
            var y = r.minY
            for k in row { let h = CGFloat(areas[k]) / colW; result[k] = CGRect(x: r.minX, y: y, width: colW, height: h); y += h }
            r = CGRect(x: r.minX + colW, y: r.minY, width: max(0, r.width - colW), height: r.height)
        } else {
            let rowH = CGFloat(rowArea) / r.width
            var x = r.minX
            for k in row { let w = CGFloat(areas[k]) / rowH; result[k] = CGRect(x: x, y: r.minY, width: w, height: rowH); x += w }
            r = CGRect(x: r.minX, y: r.minY + rowH, width: r.width, height: max(0, r.height - rowH))
        }
        i = j
    }
    return result
}
