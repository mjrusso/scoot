import Cocoa

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
