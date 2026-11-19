import Cocoa

class ElementView: NSView {

    weak var viewController: JumpViewController!

    func redraw() {
        setNeedsDisplay(bounds)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let elements = viewController?.elements else {
            return
        }

        guard let ctx = NSGraphicsContext.current else {
            return
        }

        let shouldRoundCorners = UserSettings.shared.roundElementLabelCorners
        let borderOpacity = UserSettings.shared.elementLabelBorderOpacity
        let backgroundOpacity = UserSettings.shared.elementLabelBackgroundOpacity

        ctx.cgContext.setFillColor(
            NSColor.black.withAlphaComponent(
                viewController.elementBackgroundAlphaComponent
            ).cgColor)

        for (element, _) in elements {
            ctx.cgContext.fill(element.windowRect)
        }

        let fontSize = UserSettings.shared.elementViewFontSize
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let foregroundColor = UserSettings.shared.primaryColor.withAlphaComponent(
            viewController.elementLabelAlphaComponent
        )

        let backgroundColor = NSColor.black.withAlphaComponent(
            viewController.elementLabelBackgroundAlphaComponent
        ).withAlphaComponent(backgroundOpacity)

        let borderColor = foregroundColor.withAlphaComponent(borderOpacity)

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle,
        ]

        let currentSequence = String(viewController.keyboardInputWindow?.currentSequence ?? [])

        for (element, sequence) in elements {
            let rect = element.windowRect

            let text = sequence
            let string = NSMutableAttributedString(string: text)

            string.addAttributes(attrs, range: NSRange(text.startIndex..., in: text))

            if !currentSequence.isEmpty {
                if let range = text.range(of: currentSequence),
                   text.distance(from: text.startIndex, to: range.lowerBound) == 0  {
                    string.addAttribute(.foregroundColor,
                                        value: foregroundColor.withAlphaComponent(0.5),
                                        range: NSRange(range, in: text))
                } else {
                    string.addAttribute(.foregroundColor,
                                        value: foregroundColor.withAlphaComponent(0.1),
                                        range: NSRange(text.startIndex..., in: text))
                }
            }

            let labelSize = string.size()

            let labelPadding = CGSize(width: 10.0, height: 6.0)
            let badgeSize = labelSize + labelPadding

            let padding = CGSize(width: 8.0, height: 8.0)
            let y = rect.origin.y - rect.height + (0.4 * labelSize.height) - padding.height

            let badgeRect = CGRect(
                origin: CGPoint(
                    x: rect.origin.x + (rect.width - badgeSize.width) / 2,
                    y: max(y, self.frame.minY)
                ),
                size: badgeSize
            )

            let cornerRadius: CGFloat = shouldRoundCorners ? 4.0 : 0.0
            let bezierPath = NSBezierPath(roundedRect: badgeRect, xRadius: cornerRadius, yRadius: cornerRadius)

            backgroundColor.setFill()
            bezierPath.fill()

            if shouldRoundCorners {
                bezierPath.lineWidth = 1.5
                borderColor.setStroke()
                bezierPath.stroke()
            }

            // Draw into a rect that is only as tall as the text, centered
            // vertically in the badge; `draw(in:)` top-aligns text.
            let textDrawRect = CGRect(
                x: badgeRect.origin.x,
                y: badgeRect.origin.y + (badgeRect.height - labelSize.height) / 2 + 1.0,
                width: badgeRect.width,
                height: labelSize.height
            )

            string.draw(in: textDrawRect)
        }

    }

}
