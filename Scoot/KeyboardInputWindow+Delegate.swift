import Cocoa
import OSLog

extension KeyboardInputWindow: NSWindowDelegate {

    func windowDidResignMain(_ notification: Notification) {
        #if DEBUG
        OSLog.main.debug("KeyboardInputWindow windowDidResignMain")
        #endif

        stopMonitoringScrollEvents()
        hideJumpViews()

        appDelegate?.inputWindow.currentNode = nil
        appDelegate?.updateMenuBarStatusItemForInactiveState()
    }

    func windowDidBecomeMain(_ notification: Notification) {
        #if DEBUG
        OSLog.main.debug("KeyboardInputWindow windowDidBecomeMain")
        #endif

        startMonitoringScrollEvents()

        appDelegate?.updateMenuBarStatusItemForActiveState()
    }

}
