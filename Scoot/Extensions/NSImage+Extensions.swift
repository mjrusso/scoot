import AppKit

extension NSImage {

    /// Returns a new version of the current image with the specified tint
    /// color.
    ///
    /// The current image must represent a template image. Otherwise, the
    /// current image is returned (unmodified).
    func withTintColor(_ tintColor: NSColor) -> NSImage {
        // Implementation adapted from:
        // https://gist.github.com/usagimaru/c0a03ef86b5829fb9976b650ec2f1bf4
        if self.isTemplate == false {
            return self
        }

        guard let image = self.copy() as? NSImage else {
            return self
        }

        image.lockFocus()

        tintColor.set()

        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceIn)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }

}
