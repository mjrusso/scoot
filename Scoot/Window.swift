import Cocoa

class Window: NSWindow {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor =  NSColor.clear

        isOpaque = false
        isMovable = true
        ignoresMouseEvents = true
    }

}
