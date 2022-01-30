import AppKit
import OSLog

extension KeyboardInputWindow {

    // When using the element-based navigation jump mode, automatically update
    // the displayed elements when the user scrolls.
    //
    // See https://github.com/mjrusso/scoot/issues/3 for more details.

    func startMonitoringScrollEvents() {

        OSLog.main.debug("Registering monitor for scroll events.")

        scrollEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) {
            [weak self] _ in

            guard let self = self else {
                return
            }

            guard self.activeJumpMode == .element else {
                return
            }

            guard let app = self.appDelegate?.currentApp else {
                return
            }

            self.appDelegate?.jumpViewControllers.forEach {
                $0.hideElements()
            }

            self.scrollEventDebounceTimer?.invalidate()

            self.scrollEventDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                self.initializeCoreDataStructuresForElementBasedMovement(of: app)
                self.appDelegate?.jumpViewControllers.forEach {
                    $0.redrawElements()
                    $0.showElements()
                }
            }
        }
    }

    func stopMonitoringScrollEvents() {
        OSLog.main.debug("De-registering monitor for scroll events.")

        scrollEventDebounceTimer?.invalidate()

        guard let scrollMonitor = scrollEventMonitor else {
            return
        }

        NSEvent.removeMonitor(scrollMonitor)
    }

}
