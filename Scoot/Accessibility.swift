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

        /// The element's frame, in screen coords.
        let frame: CGRect
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

        func traverse(node: UIElement) {
            guard let children: [UIElement] = try? node.arrayAttribute(.children) else {
                return
            }

            for child in children {
                guard let role: Role = try? child.role() else {
                    return
                }

                guard let frame: CGRect = try? child.attribute(.frame) else {
                    return
                }

                switch role {
                case .button, .link:
                    let element = Element(
                        role: role,
                        subrole: try? child.subrole(),
                        title: try? child.attribute(.title),
                        description: try? child.attribute(.description),
                        valueDescription: try? child.attribute(.valueDescription),
                        enabled: (try? child.attribute(.enabled)) ?? false,
                        frame: frame
                    )
                    elements.append(element)
                default:
                    traverse(node: child)
                }
            }

        }

        traverse(node: focusedWindow)

        return elements
    }

}
