import AppKit
import KeyboardShortcuts

extension KeyboardShortcuts.Name {

    static let useElementBasedNavigation = Self(
        "useElementBasedNavigation",
        default: .init(.j, modifiers: [.command, .shift])
    )

    static let useGridBasedNavigation = Self(
        "useGridBasedNavigation",
        default: .init(.k, modifiers: [.command, .shift])
    )

    static let useFreestyleNavigation = Self(
        "useFreestyleNavigation",
        default: .init(.l, modifiers: [.command, .shift])
    )

}


struct GlobalKeybindings {

    static var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }

    static func registerGlobalKeyboardShortcuts() {

        KeyboardShortcuts.onKeyUp(for: .useElementBasedNavigation) {
            appDelegate?.bringToForeground(using: .element)
        }

        KeyboardShortcuts.onKeyUp(for: .useGridBasedNavigation) {
            appDelegate?.bringToForeground(using: .grid)
        }

        KeyboardShortcuts.onKeyUp(for: .useFreestyleNavigation) {
            appDelegate?.bringToForeground(using: .freestyle)
        }

    }

    static func synchronizeMenuBarItemsWithGlobalKeyboardShortcuts() {
        guard let appDelegate = appDelegate else {
            return
        }

        appDelegate.useElementBasedNavigationMenuItem.setShortcut(for: .useElementBasedNavigation)
        appDelegate.useGridBasedNavigationMenuItem.setShortcut(for: .useGridBasedNavigation)
        appDelegate.useFreestyleNavigationMenuItem.setShortcut(for: .useFreestyleNavigation)
    }


}
