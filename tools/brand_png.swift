import AppKit
// usage: brand_png <in.svg> <out.png>  — renders a white glyph at 256px
let a = CommandLine.arguments
guard let svg = NSImage(contentsOfFile: a[1]) else { fatalError("can't load \(a[1])") }
let n = 256
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: n, pixelsHigh: n, bitsPerSample: 8, samplesPerPixel: 4,
                           hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
svg.draw(in: NSRect(x: 0, y: 0, width: n, height: n))
NSColor.white.set()
NSRect(x: 0, y: 0, width: n, height: n).fill(using: .sourceAtop)
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: a[2]))
