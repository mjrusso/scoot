import Cocoa

class TransparentWindow: NSWindow {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = NSColor.clear

        isOpaque = false
        isMovable = false
        ignoresMouseEvents = true
    }

}
