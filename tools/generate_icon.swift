// Renders the app icon: a classic day-calendar that fills the whole tile, with an
// exclamation mark. Headless-safe (Core Graphics). Usage: swift generate_icon.swift <out.png>
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let outPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"
let size = 1024

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
    space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("Could not create context") }

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: colorSpace, components: [r, g, b, a])!
}

let red = color(0.95, 0.30, 0.27)
let white = color(1, 1, 1)
let ringColor = color(0.27, 0.28, 0.31)

let canvas = CGFloat(size)
// Full-bleed rounded tile: the calendar IS the whole icon (no surrounding margin).
let card = CGRect(x: 0, y: 0, width: canvas, height: canvas)
let radius: CGFloat = 200
let headerHeight: CGFloat = 300
let cardPath = CGPath(roundedRect: card, cornerWidth: radius, cornerHeight: radius, transform: nil)

// White body.
ctx.setFillColor(white)
ctx.addPath(cardPath)
ctx.fillPath()

// Red header band, clipped to the tile's rounded shape.
ctx.saveGState()
ctx.addPath(cardPath)
ctx.clip()
ctx.setFillColor(red)
ctx.fill(CGRect(x: card.minX, y: card.maxY - headerHeight, width: card.width, height: headerHeight))
ctx.restoreGState()

// Two binding rings near the top of the red band.
ctx.setFillColor(ringColor)
let ringWidth: CGFloat = 58
let ringHeight: CGFloat = 132
for fraction in [0.34, 0.66] {
    let x = card.minX + card.width * CGFloat(fraction) - ringWidth / 2
    let ring = CGRect(x: x, y: card.maxY - 56 - ringHeight, width: ringWidth, height: ringHeight)
    ctx.addPath(CGPath(roundedRect: ring, cornerWidth: ringWidth / 2, cornerHeight: ringWidth / 2, transform: nil))
    ctx.fillPath()
}

// Exclamation mark in the white body (stem + dot), centered.
ctx.setFillColor(red)
let bodyCenterX = card.midX
let bodyTop = card.maxY - headerHeight
let bodyCenterY = (bodyTop + card.minY) / 2

let stemWidth: CGFloat = 112
let stemHeight: CGFloat = 340
let dotDiameter: CGFloat = 132
let gap: CGFloat = 64
let totalHeight = stemHeight + gap + dotDiameter
let topY = bodyCenterY + totalHeight / 2

let stem = CGRect(x: bodyCenterX - stemWidth / 2, y: topY - stemHeight, width: stemWidth, height: stemHeight)
ctx.addPath(CGPath(roundedRect: stem, cornerWidth: stemWidth / 2, cornerHeight: stemWidth / 2, transform: nil))
ctx.fillPath()

let dot = CGRect(x: bodyCenterX - dotDiameter / 2, y: topY - totalHeight, width: dotDiameter, height: dotDiameter)
ctx.fillEllipse(in: dot)

// Write PNG.
guard let image = ctx.makeImage() else { fatalError("Could not render image") }
let url = URL(fileURLWithPath: outPath)
guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
    fatalError("Could not create destination")
}
CGImageDestinationAddImage(dest, image, nil)
guard CGImageDestinationFinalize(dest) else { fatalError("Could not write PNG") }
print("Wrote \(outPath)")
