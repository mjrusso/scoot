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

        ctx.cgContext.setFillColor(
            NSColor.black.withAlphaComponent(
                viewController.elementBackgroundAlphaComponent
            ).cgColor)

        for (element, _) in elements {
            ctx.cgContext.fill(element.windowRect)
        }

        let fontSize = UserSettings.shared.elementViewFontSize
        let font = NSFont.systemFont(ofSize: fontSize, weight: .medium)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let foregroundColor = UserSettings.shared.primaryColor.withAlphaComponent(
            viewController.elementLabelAlphaComponent
        )

        let backgroundColor = NSColor.black.withAlphaComponent(
            viewController.elementLabelBackgroundAlphaComponent
        )

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
            .backgroundColor: backgroundColor,
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

            let boundingRect = string.boundingRect(
                with: rect.size,
                options: .usesLineFragmentOrigin
            ).integral

            let textHeight = boundingRect.height

            let padding = CGSize(width: 18.0, height: 18.0)

            let y = rect.origin.y - rect.height + (0.4 * textHeight) - padding.height

            string.draw(
                with: CGRect(
                    origin: CGPoint(
                        x: rect.origin.x - (padding.width / 2),
                        y: max(y, self.frame.minY)
                    ),
                    size: rect.size + padding
                ),
                options: .usesLineFragmentOrigin,
                context: nil
            )

        }

    }

}
