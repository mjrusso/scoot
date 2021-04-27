import Cocoa

extension NSPoint {

    // Convert between the Cocoa coordinate system (origin at lower left,
    // increasing upwards), and the Core Graphics (Quartz) coordinate system
    // (origin at top left, increasing downwards).
    func convertToCG(screenSize: CGSize) -> CGPoint {
        return CGPoint(x: self.x, y: screenSize.height - self.y)
    }

}
