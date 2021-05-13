import Cocoa

struct Mouse {

    let screen: NSScreen

    var screenSize: CGSize {
        screen.frame.size
    }

    var currentLocation: CGPoint {
        NSEvent.mouseLocation.convertToCG(screenSize: screenSize)
    }

    func move(to point: CGPoint) {
        let destination = point.convertToCG(screenSize: screenSize)
        let event =  CGEvent(
            mouseEventSource: nil,
            mouseType: .mouseMoved,
            mouseCursorPosition: destination,
            mouseButton: .left)
        event?.post(tap: .cghidEventTap)
    }

    func click() {
        pressDown()
        usleep(40000)
        release()
    }

    func pressDown() {
        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: currentLocation,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)
    }

    func notifyDrag() {
        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDragged,
            mouseCursorPosition: currentLocation,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)
    }

    func release() {
        CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: currentLocation,
            mouseButton: .left
        )?.post(tap: .cghidEventTap)
    }

    func doubleClick() {
        click()

        var event = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: currentLocation,
            mouseButton: .left
        )
        event?.setIntegerValueField(.mouseEventClickState, value: 2)
        event?.post(tap: .cghidEventTap)

        event = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: currentLocation,
            mouseButton: .left
        )
        event?.setIntegerValueField(.mouseEventClickState, value: 2)
        event?.post(tap: .cghidEventTap)
    }

    func drag(to point: CGPoint) {
        let start = currentLocation
        let end = point.convertToCG(screenSize: screenSize)

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

    // MARK: Convenience

    func move(_ direction: NSScreen.Direction, stepSize: CGFloat, stepMultiple: CGFloat = 1) {
        move(to: screen.point(for: direction, relativeTo: NSEvent.mouseLocation, offset: stepSize * stepMultiple))
    }

    func move(to landmark: NSScreen.AbsoluteLandmark) {
        move(to: screen.point(for: landmark))
    }

    func move(to landmark: NSScreen.RelativeLandmark) {
        move(to: screen.point(for: landmark, relativeTo: NSEvent.mouseLocation))
    }

    // Mimic (somewhat) the recenter-top-bottom behavior in Emacs, by cycling
    // between the center of the screen, and the screen's corners.
    func cycle() {
        switch NSEvent.mouseLocation {
        case screen.point(for: .center): move(to: .topLeft)
        case screen.point(for: .topLeft): move(to: .topRight)
        case screen.point(for: .topRight): move(to: .bottomRight)
        case screen.point(for: .bottomRight): move(to: .bottomLeft)
        case screen.point(for: .bottomLeft): move(to: .center)
        default: move(to: .center)
        }
    }

    func drag(_ direction: NSScreen.Direction, distance: CGFloat) {
        drag(to: screen.point(for: direction, relativeTo: NSEvent.mouseLocation, offset: distance))
    }

}
