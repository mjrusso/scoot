import Cocoa

extension NSScreen {

    // MARK: - Convenience

    /// The system's primary screen.
    static var primary: NSScreen? {
        // The primary screen is always at index 0 in the `NSScreen.screens`
        // array. Also note that this screen always contains the menu bar, and
        // has an origin at point (0, 0).
        NSScreen.screens.first
    }

    // MARK: - Landmarks (Absolute and Relative)

    static let edgePadding: CGFloat = 18.0

    enum AbsoluteLandmark {
        case center
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }

    func point(for landmark: AbsoluteLandmark) -> CGPoint {
        let padding = Self.edgePadding
        let frame = self.frame.insetBy(dx: padding, dy: padding)

        switch landmark {
        case .center: return CGPoint(x: frame.midX, y: frame.midY)
        case .topLeft: return CGPoint(x: frame.minX, y: frame.maxY)
        case .topRight: return CGPoint(x: frame.maxX, y: frame.maxY)
        case .bottomRight: return CGPoint(x: frame.maxX, y: frame.minY)
        case .bottomLeft: return CGPoint(x: frame.minX, y: frame.minY)
        }
    }

    enum RelativeLandmark {
        case topEdge
        case bottomEdge
        case leftEdge
        case rightEdge
    }

    func point(for landmark: RelativeLandmark, relativeTo point: NSPoint) -> CGPoint {
        let padding = Self.edgePadding
        let frame = self.frame.insetBy(dx: padding, dy: padding)

        switch landmark {
        case .topEdge: return CGPoint(x: point.x, y: frame.maxY)
        case .bottomEdge: return CGPoint(x: point.x, y: frame.minY)
        case .leftEdge: return CGPoint(x: frame.minX, y: point.y)
        case .rightEdge: return CGPoint(x: frame.maxX, y: point.y)
        }
    }

}
