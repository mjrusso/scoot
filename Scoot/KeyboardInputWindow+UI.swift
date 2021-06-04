import Cocoa

extension KeyboardInputWindow {

    func showGridViews() {
        appDelegate?.gridWindowControllers.forEach {
            $0.viewController.showGrid()
        }
        appDelegate?.showMenuItem.isHidden = true
        appDelegate?.hideMenuItem.isHidden = false
    }

    func hideGridViews() {
        appDelegate?.gridWindowControllers.forEach {
            $0.viewController.hideGrid()
        }
        appDelegate?.showMenuItem.isHidden = false
        appDelegate?.hideMenuItem.isHidden = true
    }

    func redrawGridViews() {
        appDelegate?.gridWindowControllers.forEach {
            $0.viewController.gridView.redraw()
        }
    }

    func flashFeedback(duration: TimeInterval) {
        guard let gridWindowControllers = appDelegate?.gridWindowControllers else {
            return
        }

        for gridWindowController in gridWindowControllers {
            let viewController = gridWindowController.viewController
            viewController.flashFeedback(at: viewController.view.bounds, duration: duration)
        }
    }

    func flashFeedback(at screenRect: CGRect, duration: TimeInterval) {
        guard let gridWindowControllers = appDelegate?.gridWindowControllers else {
            return
        }

        for windowController in gridWindowControllers {
            if let screen = windowController.assignedScreen {
                if screen.frame.contains(screenRect) {
                    let rect = NSRect( // Convert from screen coordinates.
                        x: screenRect.origin.x - screen.frame.origin.x,
                        y: screenRect.origin.y - screen.frame.origin.y,
                        width: screenRect.width,
                        height: screenRect.height
                    )
                    windowController.viewController.flashFeedback(at: rect, duration: duration)
                    break
                }
            }
        }
    }

}
