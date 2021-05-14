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

extension WindowController: NSWindowDelegate {

    // Automatically hide the app when it is not in the foreground.
    func windowDidResignMain(_ notification: Notification) {
        NSApplication.shared.hide(self)
    }

}
