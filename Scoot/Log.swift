import AppKit
import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    private static func createLogger(category: String) -> Logger {
        return Logger(subsystem: subsystem, category: category)
    }

    static let main = createLogger(category: "Main")

}

extension Logger {

    func logDetailsForAllConnectedScreens() {

        self.log("Connected screens: \(NSScreen.screens.count)")

        for (index, screen) in NSScreen.screens.enumerated() {
            self.log("* Screen \(index): \(screen.localizedName, privacy: .private(mask: .hash)) \(String(describing: screen.frame), privacy: .public)")
        }

    }

    func logDetailsForAllJumpWindows() {

        guard let jumpWindowControllers = (NSApp.delegate as? AppDelegate)?.jumpWindowControllers else {
            return
        }

        self.log("Jump Window Controllers: \(jumpWindowControllers.count)")

        for (index, windowController) in jumpWindowControllers.enumerated() {
            self.log("* Jump Window Controller \(index):")

            if let screen = windowController.assignedScreen {
                self.log("** Assigned Screen: \(screen.localizedName, privacy: .private(mask: .hash)), \(String(describing: screen.frame), privacy: .public)")
            } else {
                self.log("** No assigned screen!")
            }

            if let window = windowController.window {
                self.log("** Jump Window: \(String(describing: window.frame), privacy: .public)")
            } else {
                self.log("** No Jump Window!")
            }

            self.log("** Jump View Controller: \(String(describing: windowController.viewController.view.frame), privacy: .public)")
        }
    }

}
