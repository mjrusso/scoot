import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let screen = NSScreen.main else {
            return
        }

        window?.setFrame(screen.visibleFrame, display: true)
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
    }

    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)

    }

}
