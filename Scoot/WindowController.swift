import Cocoa

class WindowController: NSWindowController {

    var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }

    var viewController: ViewController {
        contentViewController as! ViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let screen = NSScreen.main else {
            return
        }

        self.window?.setFrame(screen.visibleFrame, display: true)
    }

}

extension WindowController: NSWindowDelegate {

    // Automatically hide the grid UI when Scoot is not in the foreground.
    func windowDidResignMain(_ notification: Notification) {
        viewController.hideGrid()
        viewController.currentNode = nil

        appDelegate?.showMenuItem.isHidden = false
        appDelegate?.hideMenuItem.isHidden = true
    }

    // Automatically show the grid UI when Scoot enters the foreground.
    func windowDidBecomeMain(_ notification: Notification) {
        viewController.showGrid()

        appDelegate?.showMenuItem.isHidden = true
        appDelegate?.hideMenuItem.isHidden = false
    }

}
