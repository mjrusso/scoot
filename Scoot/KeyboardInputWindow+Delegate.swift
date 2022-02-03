import Cocoa
import OSLog

extension KeyboardInputWindow: NSWindowDelegate {

    func windowDidResignMain(_ notification: Notification) {
        OSLog.main.debug("KeyboardInputWindow windowDidResignMain")

        stopMonitoringScrollEvents()
        hideJumpViews()

        appDelegate?.inputWindow.currentNode = nil
        appDelegate?.updateMenuBarStatusItemForInactiveState()
    }

    func windowDidBecomeMain(_ notification: Notification) {
        OSLog.main.debug("KeyboardInputWindow windowDidBecomeMain")

        startMonitoringScrollEvents()

        appDelegate?.updateMenuBarStatusItemForActiveState()
    }

}
