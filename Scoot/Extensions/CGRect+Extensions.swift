import Cocoa

// MARK: - Coordinate System Conversions

extension CGRect {

    /// Convert from the Core Graphics/ Quartz/ Carbon coordinate system
    /// (origin at top left, increasing downwards), to the Cocoa/ AppKit
    /// coordinate system (origin at lower left, increasing upwards).
    func convertToCocoa() -> CGRect {
        let origin = self.origin.convertToCocoa()

        return CGRect(x: origin.x,
                      y: origin.y - self.height,
                      width: self.width,
                      height: self.height)
    }

}

// MARK: - Geometry

extension CGRect {

    /// The area of the rectangle.
    var area: CGFloat {
        self.width * self.height
    }

    /// Returns the percentage overlap between the two rects.
    func percentageOverlapping(_ other: CGRect) -> CGFloat {
        guard self.intersects(other) else {
            return 0
        }

        if self.contains(other) || other.contains(self) {
            return 1
        }

        return self.intersection(other).area / ((self.area + other.area) / 2)
    }

}
