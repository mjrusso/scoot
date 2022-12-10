import Cocoa

struct Mouse {

    enum Button {
        case left
        case right
        case center
    }

    enum Event {
        case down
        case up
        case drag
    }

    /// The location of the mouse cursor, in the Core Graphics (Quartz) coordinate system.
    var currentLocation: CGPoint {
        NSEvent.mouseLocation.convertToCG()
    }

    /// The screen that the mouse cursor is currently inhabiting.
    var currentScreen: NSScreen? {
        NSScreen.screens.first {
            NSMouseInRect(NSEvent.mouseLocation, $0.frame, false)
        }
    }

    func move(to point: CGPoint) {
        let destination = point.convertToCG()
        let event =  CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: destination,
            mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }

    func click(button: Mouse.Button) {
        pressDown(button)
        usleep(10000)
        release(button)
    }

    func pressDown(_ button: Mouse.Button) {
        CGEvent(
            mouseEventSource: nil,
            mouseType: button.cgEventType(for: .down),
            mouseCursorPosition: currentLocation,
            mouseButton: button.cgMouseButton
        )?.post(tap: .cghidEventTap)
    }

    func notifyDrag(_ button: Mouse.Button) {
        CGEvent(
            mouseEventSource: nil,
            mouseType: button.cgEventType(for: .drag),
            mouseCursorPosition: currentLocation,
            mouseButton: button.cgMouseButton
        )?.post(tap: .cghidEventTap)
    }

    func release(_ button: Mouse.Button) {
        CGEvent(
            mouseEventSource: nil,
            mouseType: button.cgEventType(for: .up),
            mouseCursorPosition: currentLocation,
            mouseButton: button.cgMouseButton
        )?.post(tap: .cghidEventTap)
    }

    func doubleClick(button: Mouse.Button = .left) {
        click(button: button)

        var event = CGEvent(
            mouseEventSource: nil,
            mouseType: button.cgEventType(for: .down),
            mouseCursorPosition: currentLocation,
            mouseButton: button.cgMouseButton
        )
        event?.setIntegerValueField(.mouseEventClickState, value: 2)
        event?.post(tap: .cghidEventTap)

        event = CGEvent(
            mouseEventSource: nil,
            mouseType: button.cgEventType(for: .up),
            mouseCursorPosition: currentLocation,
            mouseButton: button.cgMouseButton
        )
        event?.setIntegerValueField(.mouseEventClickState, value: 2)
        event?.post(tap: .cghidEventTap)
    }

    func drag(to point: CGPoint) {
        let start = currentLocation
        let end = point.convertToCG()

        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: start,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)

        usleep(50000 * 4)

        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDragged,
            mouseCursorPosition: end,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)

        usleep(50000)

        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: end,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)
    }

    func scroll(x deltaX: Int, y deltaY: Int) {
        CGEvent(
            scrollWheelEvent2Source: nil,
            units: .pixel,
            wheelCount: 2,
            wheel1: Int32(deltaY),
            wheel2: Int32(deltaX),
            wheel3: 0
        )?.post(tap: .cghidEventTap)
    }

    // MARK: Convenience

    func move(_ direction: NSPoint.Direction, stepSize: CGFloat, stepMultiple: CGFloat = 1) {
        move(to: NSEvent.mouseLocation.offset(by: stepSize * stepMultiple, in: direction))
    }

    func move(to landmark: NSScreen.AbsoluteLandmark) {
        guard let screen = currentScreen else {
            return
        }

        move(to: screen.point(for: landmark))
    }

    func move(to landmark: NSScreen.RelativeLandmark) {
        guard let screen = currentScreen else {
            return
        }

        move(to: screen.point(for: landmark, relativeTo: NSEvent.mouseLocation))
    }

    // Mimic (somewhat) the recenter-top-bottom behavior in Emacs, by cycling
    // between the center of the screen, and the screen's corners.
    func cycle() {
        guard let screen = currentScreen else {
            return
        }

        switch NSEvent.mouseLocation {
        case screen.point(for: .center): move(to: .topLeft)
        case screen.point(for: .topLeft): move(to: .topRight)
        case screen.point(for: .topRight): move(to: .bottomRight)
        case screen.point(for: .bottomRight): move(to: .bottomLeft)
        case screen.point(for: .bottomLeft): move(to: .center)
        default: move(to: .center)
        }
    }

    func drag(_ direction: NSPoint.Direction, distance: CGFloat) {
        drag(to: NSEvent.mouseLocation.offset(by: distance, in: direction))
    }

    func scroll(_ direction: NSPoint.Direction, stepSize: CGFloat, stepMultiple: CGFloat = 1) {
        let offset = Int(stepSize * stepMultiple)
        switch direction {
        case .up:
            scroll(x: 0, y: offset)
        case .down:
            scroll(x: 0, y: -offset)
        case .left:
            scroll(x: offset, y: 0)
        case .right:
            scroll(x: -offset, y: 0)
        }
    }

}

extension Mouse.Button {

    func cgEventType(for event: Mouse.Event) -> CGEventType {
        switch (self, event) {
        case (.left, .down):
            return .leftMouseDown
        case (.left, .up):
            return .leftMouseUp
        case (.left, .drag):
            return .leftMouseDragged
        case (.right, .down):
            return .rightMouseDown
        case (.right, .up):
            return .rightMouseUp
        case (.right, .drag):
            return .rightMouseDragged
        case (.center, .down):
            return .otherMouseDown
        case (.center, .up):
            return .otherMouseUp
        case (.center, .drag):
            return .otherMouseDragged
        }
    }

    var cgMouseButton: CGMouseButton {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        case .center:
            return .center
        }
    }

}
