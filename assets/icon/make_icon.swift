// Renders the Recenter app icon (concept A, "return to center") as an opaque 1024×1024 PNG.
// Usage: swift assets/icon/make_icon.swift <output.png>
import AppKit

let size = 1024
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"

let space = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(
  data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
  space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!

func rgb(_ hex: Int, _ alpha: CGFloat = 1) -> CGColor {
  CGColor(
    srgbRed: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
    blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
}

// Core Graphics' origin is bottom-left; flip so coordinates match the SVG concept.
ctx.translateBy(x: 0, y: CGFloat(size))
ctx.scaleBy(x: 1, y: -1)

let teal = 0x0F766E
let cream = 0xF5E6C8

ctx.setFillColor(rgb(teal))
ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))

func ring(cx: CGFloat, cy: CGFloat, r: CGFloat, width: CGFloat, color: CGColor) {
  ctx.setStrokeColor(color)
  ctx.setLineWidth(width)
  ctx.strokeEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
}

// The ring that has drifted off center, faint.
ring(cx: 430, cy: 430, r: 250, width: 44, color: rgb(0xFFFFFF, 0.28))
// The settled ring and its center.
ring(cx: 512, cy: 512, r: 250, width: 56, color: rgb(0xFFFFFF))
ctx.setFillColor(rgb(cream))
ctx.fillEllipse(in: CGRect(x: 512 - 92, y: 512 - 92, width: 184, height: 184))

let image = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: image)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")
