import AXSwift
import AppKit
import OSLog

struct Accessibility {

    struct Element: Positionable, Equatable {
        let role: Role

        let subrole: Subrole?

        let title: String?

        let description: String?

        let valueDescription: String?

        /// True, if the element responds to user.
        let enabled: Bool

        /// The screen that the element is located on.
        let screen: NSScreen

        /// The element's frame, in Cocoa/AppKit screen (*not* window) coordinates.
        let frame: CGRect

        /// The element's frame, in Cocoa/AppKit screen coordinates.
        var screenRect: CGRect {
            frame
        }

        /// The element's frame, in Cocoa/AppKit window coordinates.
        var windowRect: CGRect {
            CGRect(x: frame.origin.x - screen.visibleFrame.origin.x,
                   y: frame.origin.y - screen.visibleFrame.origin.y,
                   width: frame.width,
                   height: frame.height)
        }

        /// The element's width.
        var width: CGFloat {
            frame.width
        }

        /// The element's height.
        var height: CGFloat {
            frame.height
        }

    }

    static func checkIfProcessIsTrusted(withPrompt showPrompt: Bool = false) -> Bool {
        UIElement.isProcessTrusted(withPrompt: showPrompt)
    }

    @discardableResult
    static func enableEnhancedUserInterfaceIfNecessary(for runningApp: NSRunningApplication) -> Bool {

        guard let app = Application(runningApp) else {
            return false
        }

        let enhancedUserInterfaceAlreadyEnabled = (try? app.attribute(.enhancedUserInterface) ?? false) ?? false

        if !enhancedUserInterfaceAlreadyEnabled {

            OSLog.main.log("Enabling AXEnhancedUserInterface for \(String(describing: runningApp.localizedName ?? "<unknown>"), privacy: .private(mask: .hash))")

            try? app.setAttribute(.enhancedUserInterface, value: true)
        }

        return enhancedUserInterfaceAlreadyEnabled
    }

    static func disableEnhancedUserInterface(for runningApp: NSRunningApplication) {
        guard let app = Application(runningApp) else {
            return
        }

        OSLog.main.log("Disabling AXEnhancedUserInterface for \(String(describing: runningApp.localizedName ?? "<unknown>"), privacy: .private(mask: .hash))")

        try? app.setAttribute(.enhancedUserInterface, value: false)
    }

    // Some apps are not accessible unless an assistive client (such as
    // VoiceOver) is enabled. (VoiceOver sets the `AXEnhancedUserInterface`
    // attribute on the main application window.)
    //
    // In order to ensure that Scoot can see what a screenreader sees,
    // Scoot adds this attribute to all running apps.
    //
    // Note that in earlier releases, Scoot added the `AXEnhancedUserInterface`
    // attribute (when necessary) immediately before traversing the element
    // tree; however, this solution was not ideal because apps may take some
    // time to enable their accessibility APIs, resulting in Scoot seeing an
    // incomplete picture of all available elements.
    //
    // For additional notes and discussion, see: https://github.com/mjrusso/scoot/issues/11
    static func enableEnhancedUserInterfaceForAllApps() {
        NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }.forEach { app in
            Accessibility.enableEnhancedUserInterfaceIfNecessary(for: app)
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didLaunchApplicationNotification,
            object: nil,
            queue: nil
        ) { notification in
            guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
                return
            }

            Accessibility.enableEnhancedUserInterfaceIfNecessary(for: app)
        }
    }

    static func disableEnhancedUserInterfaceForAllApps() {
        NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }.forEach { app in
            Accessibility.disableEnhancedUserInterface(for: app)
        }
    }

    static func getAccessibleElementsForFocusedWindow(of runningApp: NSRunningApplication) -> [Element] {
        var elements = [Element]()

        guard let app = Application(runningApp) else {
            return elements
        }

        guard let focusedWindow: UIElement = try? app.attribute(.focusedWindow) else {
            return elements
        }

        guard let focusedWindowFrame: CGRect = try? focusedWindow.attribute(.frame) else {
            return elements
        }

        func traverse(node: UIElement) {
            guard let children: [UIElement] = try? node.arrayAttribute(.children) else {
                return
            }

            for child in children {

                // Bail, if the parent and child are (somehow?) the same node.
                //
                // See: https://github.com/mjrusso/scoot/issues/13
                guard child != node else {
                    continue
                }

                guard let frame: CGRect = try? child.attribute(.frame) else {
                    continue
                }

                // Ignore any elements that don't intersect with the window
                // bounds.
                guard focusedWindowFrame.intersects(frame) else {
                    continue
                }

                let convertedFrame = frame.convertToCocoa()

                let screen = NSScreen.screens.first(where: {
                    $0.frame.contains(convertedFrame)
                })

                let role: Role? = try? child.role()

                if let role = role, let screen = screen {

                    func addElement() {
                        let element = Element(
                            role: role,
                            subrole: try? child.subrole(),
                            title: try? child.attribute(.title),
                            description: try? child.attribute(.description),
                            valueDescription: try? child.attribute(.valueDescription),
                            enabled: (try? child.attribute(.enabled)) ?? false,
                            screen: screen,
                            frame: convertedFrame
                        )
                        elements.append(element)
                    }

                    switch role {
                    case .cell, .button, .radioButton, .link, .checkBox, .slider, .popUpButton, .menuButton, .incrementor, .handle:
                        addElement()
                    default:
                        break
                    }
                }

                traverse(node: child)
            }

        }

        traverse(node: focusedWindow)

        OSLog.main.debug("Found \(elements.count) accessibility elements.")

        return elements
    }

}
