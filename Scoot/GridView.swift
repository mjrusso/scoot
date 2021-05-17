import Cocoa

class GridView: NSView {

    weak var viewController: ViewController!

    func redraw() {
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let grid = viewController.grid else {
            return
        }

        guard let ctx = NSGraphicsContext.current else {
            return
        }

        ctx.cgContext.setFillColor(
            NSColor.black.withAlphaComponent(
                viewController.gridBackgroundAlphaComponent
            ).cgColor)

        ctx.cgContext.fill(bounds)

        let cellSize = grid.cellSize

        ctx.cgContext.setStrokeColor(
            NSColor.systemTeal.withAlphaComponent(
                viewController.gridLineAlphaComponent
            ).cgColor
        )
        ctx.cgContext.setLineWidth(2)

        if viewController.isDisplayingGridLines {
            for x in stride(from: 0.0, to: grid.size.width, by: cellSize.width) {
                ctx.cgContext.move(to: CGPoint(x: x, y: 0))
                ctx.cgContext.addLine(to: CGPoint(x: x, y: grid.size.height))
            }

            for y in stride(from: 0.0, to: grid.size.height, by: cellSize.height) {
                ctx.cgContext.move(to: CGPoint(x: 0, y: y))
                ctx.cgContext.addLine(to: CGPoint(x: grid.size.width, y: y))
            }

            ctx.cgContext.drawPath(using: .stroke)
        }

        guard viewController.isDisplayingGridLabels else {
            return
        }

        let font = NSFont.systemFont(ofSize: 18, weight: .medium)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs: [NSAttributedString.Key: Any]  = [
          .font: font,
          .foregroundColor: NSColor.systemTeal.withAlphaComponent(
            viewController.gridLabelAlphaComponent
           ),
          .paragraphStyle: paragraphStyle,
//          .strokeWidth: -2.0,
//          .strokeColor: NSColor.black,
        ]

        for (index, cellRect) in grid.rects.enumerated() {
            let text = grid.data(atIndex: index)

            let boundingRect = text.boundingRect(
                with: cellRect.size,
                options: .usesLineFragmentOrigin,
                attributes: attrs
            )

            let textHeight = boundingRect.height

            text.draw(
                with: CGRect(
                    origin: CGPoint(
                        x: cellRect.origin.x,
                        y: cellRect.origin.y - textHeight
                    ),
                    size: cellRect.size
                ),
                options: .usesLineFragmentOrigin,
                attributes: attrs,
                context: nil
            )

        }

    }
}
