import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let screen = NSScreen.main else {
            return
        }

        window?.setFrame(screen.visibleFrame, display: true)
    }

    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)

        let characters = event.charactersIgnoringModifiers
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        guard let window = self.window else {
            return
        }

        switch (modifiers, characters) {
        case (.command, "r"): // Random
            let point = CGPoint(x: CGFloat.random(in: 0..<window.frame.width),
                                y: CGFloat.random(in: 0..<window.frame.height))

            CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)

            print("YUP")
        case (.command, "c"): // Click
            let point = CGPoint(x: 600, y: 440)

            CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)?.post(tap: CGEventTapLocation.cghidEventTap)

            usleep(40000)

            CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)

            NSApplication.shared.hide(self)
        case (.command, "d"): // Drag
            let start = CGPoint(x: 400, y: 300)
            let end = CGPoint(x: 850, y: 950)

            CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: start, mouseButton: .left)?.post(tap: .cghidEventTap)

            usleep(50000 * 4)

            CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: end, mouseButton: .left)?.post(tap: .cghidEventTap)

            usleep(50000)

            CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: end, mouseButton: .left)?.post(tap: .cghidEventTap)

        default:
            break
        }

    }

}
