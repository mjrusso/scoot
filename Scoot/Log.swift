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
            self.log("* Screen \(index): \(screen.localizedName) \(String(describing: screen.frame))")
        }

    }

}
