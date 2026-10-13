// Blurs and dims a screenshot everywhere except the given regions (e.g. the status bar and a
// notification banner), so third-party content behind them isn't shown in store screenshots.
// Usage: swift focus_region.swift <in.png> <out.png> <x,y,width,height,cornerRadius>...
// Regions are in pixels, measured from the top-left corner.
import AppKit
import CoreImage

let args = CommandLine.arguments
guard args.count >= 4 else {
  print("usage: focus_region.swift <in.png> <out.png> <x,y,width,height,radius>...")
  exit(1)
}

let source = CIImage(contentsOf: URL(fileURLWithPath: args[1]))!
let extent = source.extent
let width = Int(extent.width)
let height = Int(extent.height)

// White where the image stays sharp, black where it's blurred.
let maskContext = CGContext(
  data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
  space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)!
maskContext.setFillColor(gray: 0, alpha: 1)
maskContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
maskContext.setFillColor(gray: 1, alpha: 1)
for spec in args.dropFirst(3) {
  let v = spec.split(separator: ",").compactMap { Double($0) }
  guard v.count == 5 else {
    print("bad region \(spec); expected x,y,width,height,radius")
    exit(1)
  }
  // Core Graphics' origin is bottom-left.
  let rect = CGRect(x: v[0], y: Double(height) - v[1] - v[3], width: v[2], height: v[3])
  maskContext.addPath(CGPath(roundedRect: rect, cornerWidth: v[4], cornerHeight: v[4], transform: nil))
  maskContext.fillPath()
}
let mask = CIImage(cgImage: maskContext.makeImage()!)

let blurred = source.clampedToExtent()
  .applyingGaussianBlur(sigma: 60)
  .cropped(to: extent)
  .applyingFilter("CIExposureAdjust", parameters: [kCIInputEVKey: -1.2])

let result = source.applyingFilter(
  "CIBlendWithMask", parameters: [kCIInputBackgroundImageKey: blurred, kCIInputMaskImageKey: mask])

let cg = CIContext().createCGImage(result, from: extent)!
// Re-encode without alpha: App Store screenshots must be opaque.
let opaque = CGContext(
  data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
  space: CGColorSpace(name: CGColorSpace.sRGB)!,
  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
opaque.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
let rep = NSBitmapImageRep(cgImage: opaque.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
print("wrote \(args[2])")
