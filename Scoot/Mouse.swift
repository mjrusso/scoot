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
        // It should be possible to `pressDown()` and then `release()` (after a
        // short delay), however that approach doesn't work reliably: in some
        // applications (for example, when trying to click on a hyperlink in a
        // browser, or in an apps that render their user interface using web
        // technologies), mouse clicks don't actually register.
        //
        // For an unknown reason, posting two `leftMouseDown` events, followed
        // by a single `leftMouseUp`, *seems* to work consistently everywhere.
        // How's that for a hack?
        //
        // [N.B.: A previous implementation issued two clicks in a row (i.e.,
        // `pressDown()`, `release()`, `pressDown()`, `release()`), and that
        // worked better than one could reasonably expect. However, there were
        // rare cases where two clicks would actually be registered: for example,
        // in Safari, clicking the "close tab" button (the one embedded in the
        // tab itself) would result in two tabs being closed. Another example:
        // it wasn't possible to use Scoot to bring up it's menu bar: two clicks
        // would register, and it would immediately close.]
        //
        // [N.B.: This question [0] on Stack Overflow ("Simulating mouse clicks
        // on Mac OS X does not work for some applications") seems relevant, but
        // unfortunately none of the proposed strategies seem to work.]
        //
        // [0]: https://stackoverflow.com/q/2369806/15304124
        pressDown()
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

    func scroll(_ direction: NSScreen.Direction, stepSize: CGFloat, stepMultiple: CGFloat = 1) {
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
