import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let screen = NSScreen.main else {
            return
        }

        self.window?.setFrame(screen.visibleFrame, display: true)
    }

}
