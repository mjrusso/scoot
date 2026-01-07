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
        
        let shouldRoundBorders = UserSettings.shared.roundElementBorders
        let borderOpacity = UserSettings.shared.elementBorderOpacity
        
        ctx.cgContext.setFillColor(
            NSColor.black.withAlphaComponent(
                viewController.elementBackgroundAlphaComponent
            ).cgColor)

        for (element, _) in elements {
            ctx.cgContext.fill(element.windowRect)
        }

        // Setup font & font bg color
        let fontSize = UserSettings.shared.elementViewFontSize
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .medium)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let foregroundColor = UserSettings.shared.primaryColor.withAlphaComponent(
            viewController.elementLabelAlphaComponent
        )

        let backgroundColor = NSColor.black.withAlphaComponent(
            viewController.elementLabelBackgroundAlphaComponent
        )
        
        let borderColor = foregroundColor.withAlphaComponent(borderOpacity)
    
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
            .paragraphStyle: paragraphStyle,
        ]

        let currentSequence = String(viewController.keyboardInputWindow?.currentSequence ?? [])

        // Draw the Labels
        for (element, sequence) in elements {
            let rect = element.windowRect

            let text = sequence
            let string = NSMutableAttributedString(string: text)
            string.addAttributes(attrs, range: NSRange(text.startIndex..., in: text))

            // Highlight logic
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
            
            // Text padding
            let xPadding: CGFloat = 10.0
            let yPadding: CGFloat = 6.0
            let bgWidth = labelSize.width + xPadding
            let bgHeight = labelSize.height + yPadding
                
            // Calculate Y position
            let padding = CGSize(width: 8.0, height: 8.0)
            let y = rect.origin.y - rect.height + (0.4 * labelSize.height) - padding.height
            let clampedY = max(y, self.frame.minY)

            // Calculate X position
            let bgX = rect.origin.x + (rect.width - bgWidth) / 2
                
            // Create the elment text bg Rectangle
            let badgeRect = CGRect(x: bgX, y: clampedY, width: bgWidth, height: bgHeight)
                
            // Draw Rounded Background
            let cornerRadius: CGFloat = shouldRoundBorders ? 4.0 : 0.0
            let bezierPath = NSBezierPath(roundedRect: badgeRect, xRadius: cornerRadius, yRadius: cornerRadius)
            
            backgroundColor.setFill()
            bezierPath.fill()
            
            // Add border
            if shouldRoundBorders {
                bezierPath.lineWidth = 1.5
                borderColor.setStroke()
                bezierPath.stroke()
            }
            
            // Calculate the math to center the smaller text rect inside the larger badge rect
            let yOffset = (badgeRect.height - labelSize.height) / 2

            // IMPORTANT: We use 'labelSize.height' for the height, not 'badgeRect.height'.
            // If you use the full badge height, draw(in:) will stick the text to the top.
            let textDrawRect = CGRect(
                x: badgeRect.origin.x,
                y: badgeRect.origin.y + yOffset + 1.0,
                width: badgeRect.width,
                height: labelSize.height
            )

            string.draw(in: textDrawRect)
        }
    }

}
