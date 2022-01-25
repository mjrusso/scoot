import AppKit
import os.log

extension OSLog {

    private static var subsystem = Bundle.main.bundleIdentifier!

    private static func createLogger(category: String) -> Logger {
        return Logger(subsystem: subsystem, category: category)
    }

    static let main = createLogger(category: "Main")

}
