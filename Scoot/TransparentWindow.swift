import Cocoa

class TransparentWindow: NSWindow {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = NSColor.clear

        isOpaque = false
        isMovable = false
        ignoresMouseEvents = true

        collectionBehavior = [
            // When the window becomes active, move it to the active space
            // instead of switching spaces.
            .moveToActiveSpace,

            // The window floats in Spaces and hides in Exposé.
            .transient,
        ]
    }

}
