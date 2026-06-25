import Cocoa
import OSLog

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

        let frame = screen.visibleFrame

        guard frame.isUsableScreenFrame else {
            OSLog.main.error("Invalid screen frame detected: \(String(describing: frame), privacy: .public)")
            appDelegate?.presentScreenValidationAlertIfNeeded(details: "\(frame)")
            return
        }

        setWindowFrame(frame)
    }

    func setWindowFrame(_ frame: NSRect) {
        self.window?.setFrame(frame, display: true)
    }

}
