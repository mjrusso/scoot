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
            CGRect(x: frame.origin.x - screen.frame.origin.x,
                   y: frame.origin.y - screen.frame.origin.y,
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
            try? app.setAttribute(.enhancedUserInterface, value: true)
        }

        return enhancedUserInterfaceAlreadyEnabled
    }

    static func disableEnhancedUserInterface(for runningApp: NSRunningApplication) {
        guard let app = Application(runningApp) else {
            return
        }

        Logger().log("Disabling AXEnhancedUserInterface for \(String(describing: runningApp.localizedName ?? "<unknown>"))")

        try? app.setAttribute(.enhancedUserInterface, value: false)
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

        // Hack: some apps are not accessible unless an assistive client (such
        // as VoiceOver) is enabled. (VoiceOver sets the
        // `AXEnhancedUserInterface` attribute on the main application window.)
        // In order to ensure that Scoot can see what a screenreader sees,
        // manually add the attribute (if necessary) before traversing the
        // element tree.
        //
        // FIXME: remove the `AXEnhancedUserInterface` attribute, for example
        // when Scoot is moved to the background. (But only if Scoot added it
        // in the first place.)
        //
        // FIXME: an app may take some time to enable accessibility APIs; i.e.,
        // we may query the element tree too quickly after setting the
        // `AXEnhancedUserInterface` attribute. (This seems to be especially
        // prevalent with Electron-based apps.) For the time being, as a
        // workaround, users can simply re-invoke Scoot to force the element
        // tree to be traversed again.
        //
        // Also see: https://github.com/mjrusso/scoot/issues/11
        Self.enableEnhancedUserInterfaceIfNecessary(for: runningApp)

        func traverse(node: UIElement) {
            guard let children: [UIElement] = try? node.arrayAttribute(.children) else {
                return
            }

            for child in children {

                guard let frame: CGRect = try? child.attribute(.frame) else {
                    continue
                }

                // Ignore any elements that don't intersect with the window
                // bounds.
                guard focusedWindowFrame.intersects(frame) else {
                    continue
                }

                let screen = NSScreen.screens.first(where: {
                    $0.frame.contains(frame)
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
                            frame: frame.convertToCocoa()
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

        return elements
    }

}
