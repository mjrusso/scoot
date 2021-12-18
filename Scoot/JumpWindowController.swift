import Cocoa

class JumpWindowController: NSWindowController {

    var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }

    var viewController: JumpViewController {
        contentViewController as! JumpViewController
    }

    var assignedScreen: NSScreen?

    override func windowDidLoad() {
        super.windowDidLoad()
    }

}

extension JumpWindowController {

    class func spawn(on screen: NSScreen) -> JumpWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "WindowController") as! JumpWindowController
        controller.assignScreen(screen: screen)
        controller.showWindow(self)

        return controller
    }

    func assignScreen(screen: NSScreen) {
        self.assignedScreen = screen
        setWindowFrame(screen.visibleFrame)
    }

    func setWindowFrame(_ frame: NSRect) {
        self.window?.setFrame(frame, display: true)
    }

}
