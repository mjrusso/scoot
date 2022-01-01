import AXSwift
import AppKit

struct Accessibility {

    struct Element {
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
                    switch role {
                    case .button, .link:
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
                        continue
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
