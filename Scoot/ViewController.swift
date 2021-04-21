import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func randomButtonPressed(_ sender: NSButton) {
        guard let window = self.view.window else {
            return
        }

        let point = CGPoint(x: CGFloat.random(in: 0..<window.frame.width),
                            y: CGFloat.random(in: 0..<window.frame.height))

        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)

    }

    @IBAction func clickButtonPressed(_ sender: NSButton) {
        let point = CGPoint(x: 600, y: 440)

        CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left)?.post(tap: CGEventTapLocation.cghidEventTap)

        usleep(40000)

        CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left)?.post(tap: .cghidEventTap)

        NSApplication.shared.hide(self)
    }

    @IBAction func dragButtonPressed(_ sender: NSButton) {
        let start = CGPoint(x: 400, y: 300)
        let end = CGPoint(x: 850, y: 950)

        CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: start, mouseButton: .left)?.post(tap: .cghidEventTap)

        usleep(50000 * 4)

        CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: end, mouseButton: .left)?.post(tap: .cghidEventTap)

        usleep(50000)

        CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: end, mouseButton: .left)?.post(tap: .cghidEventTap)
    }

}

