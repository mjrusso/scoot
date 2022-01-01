import Cocoa

// MARK: - Coordinate System Conversions

extension NSPoint {

    /// The screen that the point is currently on.
    var currentScreen: NSScreen? {
        NSScreen.screens.first {
            NSPointInRect(self, $0.frame)
        }
    }

    /// Change the drawing orientation of the vertical axis.
    ///
    /// See
    /// https://developer.apple.com/library/archive/documentation/General/Conceptual/Devpedia-CocoaApp/CoordinateSystem.html
    /// for additional details.
    func swapVerticalAxisOrientation() -> Self {
        // Unlike the advice in https://stackoverflow.com/a/19314037,
        // everything seems to work properly when the tallest screen is used,
        // not the current screen...
        //
        // guard let screen = self.currentScreen else {
        //     return .zero
        // }

        guard let tallestScreen = NSScreen.tallest else {
            return .zero
        }

        return Self(x: self.x,
                    y: tallestScreen.frame.origin.y + tallestScreen.frame.size.height - self.y)
    }

    /// Convert from the Cocoa/ AppKit coordinate system (origin at lower
    /// left, increasing upwards), to the Core Graphics/ Quartz/ Carbon
    /// coordinate system (origin at top left, increasing downwards).
    func convertToCG() -> Self {
        self.swapVerticalAxisOrientation()
    }

    /// Convert from the Core Graphics/ Quartz/ Carbon coordinate system
    /// (origin at top left, increasing downwards), to the Cocoa/ AppKit
    /// coordinate system (origin at lower left, increasing upwards).
    func convertToCocoa() -> Self {
        self.swapVerticalAxisOrientation()
    }

}

// MARK: - Convenience

extension NSPoint {

    enum Direction {
        case up
        case down
        case left
        case right
    }

    func offset(by offset: CGFloat, in direction: Direction) -> CGPoint {
        switch direction {
        case .up: return CGPoint(x: x, y: y + offset)
        case .down: return CGPoint(x: x, y: y - offset)
        case .left: return CGPoint(x: x - offset, y: y)
        case .right: return CGPoint(x: x + offset, y: y)
        }
    }

}
