import Cocoa

extension NSScreen {

    // MARK: - Landmarks (Absolute and Relative)

    enum AbsoluteLandmark {
        case center
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }

    func point(for landmark: AbsoluteLandmark) -> CGPoint {
        switch landmark {
        case .center: return CGPoint(x: frame.midX, y: frame.midY)
        case .topLeft: return CGPoint(x: 0, y: frame.maxY)
        case .topRight: return CGPoint(x: frame.maxX, y: frame.maxY)
        case .bottomRight: return CGPoint(x: frame.maxX, y: 0)
        case .bottomLeft: return CGPoint(x: 0, y: 0)
        }
    }

    enum RelativeLandmark {
        case topEdge
        case bottomEdge
        case leftEdge
        case rightEdge
    }

    func point(for landmark: RelativeLandmark, relativeTo point: NSPoint) -> CGPoint {
        switch landmark {
        case .topEdge: return CGPoint(x: point.x, y: frame.height)
        case .bottomEdge: return CGPoint(x: point.x, y: 0)
        case .leftEdge: return CGPoint(x: 0, y: point.y)
        case .rightEdge: return CGPoint(x: frame.width, y: point.y)
        }
    }

}
