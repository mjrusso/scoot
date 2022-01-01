import Cocoa

extension KeyboardInputWindow: NSWindowDelegate {

    func windowDidResignMain(_ notification: Notification) {
        hideJumpViews()

        appDelegate?.inputWindow.currentNode = nil
    }

    func windowDidBecomeMain(_ notification: Notification) {

    }

}
