import AppKit

/// Draws a classic single-day calendar glyph with the current day number inside it,
/// as a template image so the menu bar tints it for light/dark automatically.
enum MenuBarIcon {
    static func image(day: Int) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size)
        image.lockFocus()

        NSColor.black.setStroke()
        NSColor.black.setFill()

        // Calendar body.
        let body = NSRect(x: 1.5, y: 1, width: 15, height: 14)
        let bodyPath = NSBezierPath(roundedRect: body, xRadius: 3, yRadius: 3)
        bodyPath.lineWidth = 1.4
        bodyPath.stroke()

        // Header separator line.
        let headerY = body.maxY - 3.5
        let header = NSBezierPath()
        header.move(to: NSPoint(x: body.minX, y: headerY))
        header.line(to: NSPoint(x: body.maxX, y: headerY))
        header.lineWidth = 1.4
        header.stroke()

        // Two binding rings on top.
        for x in [body.minX + 4, body.maxX - 4] {
            let ring = NSBezierPath()
            ring.move(to: NSPoint(x: x, y: body.maxY - 1))
            ring.line(to: NSPoint(x: x, y: body.maxY + 1.5))
            ring.lineWidth = 1.4
            ring.stroke()
        }

        // Day number, centered in the body below the header.
        let text = "\(day)"
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9, weight: .bold),
            .foregroundColor: NSColor.black,
            .paragraphStyle: paragraph
        ]
        let attributed = NSAttributedString(string: text, attributes: attrs)
        let textSize = attributed.size()
        let area = NSRect(x: body.minX, y: body.minY, width: body.width, height: headerY - body.minY)
        let textRect = NSRect(
            x: area.minX,
            y: area.minY + (area.height - textSize.height) / 2,
            width: area.width,
            height: textSize.height
        )
        attributed.draw(in: textRect)

        image.unlockFocus()
        image.isTemplate = true
        return image
    }
}
