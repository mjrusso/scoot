import Cocoa

class GridWindowController: NSWindowController {

    var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }

    var viewController: GridViewController {
        contentViewController as! GridViewController
    }

    var assignedScreen: NSScreen?

    override func windowDidLoad() {
        super.windowDidLoad()
    }

}

extension GridWindowController {

    class func spawn(on screen: NSScreen) -> GridWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateController(withIdentifier: "WindowController") as! GridWindowController
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
