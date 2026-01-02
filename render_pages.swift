import Foundation
import PDFKit
import AppKit

let inputURL = URL(fileURLWithPath: "correcciones.pdf")
guard let document = PDFDocument(url: inputURL) else {
  fputs("Failed to open PDF\n", stderr)
  exit(1)
}
let scale: CGFloat = 2.0
for index in 0..<document.pageCount {
  guard let page = document.page(at: index) else { continue }
  let bounds = page.bounds(for: .mediaBox)
  let width = Int(bounds.width * scale)
  let height = Int(bounds.height * scale)
  guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
  ) else {
    continue
  }
  context.interpolationQuality = .high
  context.setFillColor(NSColor.white.cgColor)
  context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
  context.scaleBy(x: scale, y: scale)
  if let pageRef = page.pageRef {
    context.drawPDFPage(pageRef)
  } else {
    continue
  }
  guard let cgImage = context.makeImage() else { continue }
  let bitmap = NSBitmapImageRep(cgImage: cgImage)
  guard let data = bitmap.representation(using: .png, properties: [:]) else { continue }
  let outputURL = URL(fileURLWithPath: String(format: "correcciones-page-%02d.png", index + 1))
  do {
    try data.write(to: outputURL)
    print("Wrote", outputURL.path)
  } catch {
    fputs("Failed writing page \(index + 1): \(error)\n", stderr)
  }
}
