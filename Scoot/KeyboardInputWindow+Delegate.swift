import Cocoa

extension KeyboardInputWindow: NSWindowDelegate {

    func windowDidResignMain(_ notification: Notification) {
        hideJumpViews()

        appDelegate?.inputWindow.currentNode = nil
        appDelegate?.updateMenuBarStatusItemForInactiveState()
    }

    func windowDidBecomeMain(_ notification: Notification) {
        appDelegate?.updateMenuBarStatusItemForActiveState()
    }

}
