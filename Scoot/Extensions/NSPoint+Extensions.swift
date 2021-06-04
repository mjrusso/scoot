import Cocoa

extension NSPoint {

    // Convert between the Cocoa coordinate system (origin at lower left,
    // increasing upwards), and the Core Graphics (Quartz) coordinate system
    // (origin at top left, increasing downwards).
    func convertToCG(screenHeight: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: screenHeight - self.y)
    }

    func convertToCG() -> CGPoint {
        let screen = NSScreen.screens.sorted { $0.frame.height < $1.frame.height }.last
        return convertToCG(screenHeight: screen?.frame.height ?? 0.0)
    }

}

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
