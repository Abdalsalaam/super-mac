import AppKit

// Masks full-bleed artwork to Apple's macOS icon grid: a continuous-corner squircle
// 824x824 centred on a 1024x1024 canvas, so the Dock shows it without a frame.
let src = NSImage(contentsOfFile: CommandLine.arguments[1])!
let size: CGFloat = 1024, body: CGFloat = 824, o = (size - body) / 2

func squircle(_ r: NSRect, n: Double = 5) -> NSBezierPath {
    let p = NSBezierPath(); let a = Double(r.width) / 2, b = Double(r.height) / 2
    let cx = Double(r.midX), cy = Double(r.midY)
    for i in 0...720 {
        let t = Double(i) / 720 * 2 * .pi
        let c = cos(t), s = sin(t)
        let x = cx + a * (c < 0 ? -1 : 1) * pow(abs(c), 2 / n)
        let y = cy + b * (s < 0 ? -1 : 1) * pow(abs(s), 2 / n)
        i == 0 ? p.move(to: NSPoint(x: x, y: y)) : p.line(to: NSPoint(x: x, y: y))
    }
    p.close(); return p
}

let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()
let rect = NSRect(x: o, y: o, width: body, height: body)
let path = squircle(rect)
NSGraphicsContext.saveGraphicsState()
path.addClip()
src.draw(in: rect.insetBy(dx: -2, dy: -2))
// fine top rim highlight, like system icons
NSGradient(colors: [NSColor.white.withAlphaComponent(0.18), NSColor.white.withAlphaComponent(0)])!
    .draw(in: NSRect(x: o, y: o + body * 0.55, width: body, height: body * 0.45), angle: -90)
NSGraphicsContext.restoreGraphicsState()
NSColor.white.withAlphaComponent(0.22).setStroke()
path.lineWidth = 2; path.stroke()
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[2]))
