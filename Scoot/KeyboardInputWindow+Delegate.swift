import Cocoa

extension KeyboardInputWindow: NSWindowDelegate {

    // Automatically hide the grid UI when Scoot is not in the foreground.
    func windowDidResignMain(_ notification: Notification) {
        hideGridViews()

        appDelegate?.inputWindow.currentNode = nil
    }

    // Automatically show the grid UI when Scoot enters the foreground.
    func windowDidBecomeMain(_ notification: Notification) {
        showGridViews()
    }

}
