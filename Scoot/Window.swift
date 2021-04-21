import Cocoa

class Window: NSWindow {

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor =  NSColor.clear
//        backgroundColor =  NSColor.white.withAlphaComponent(0.01)

        isOpaque = false
        isMovable = true
    }

}
