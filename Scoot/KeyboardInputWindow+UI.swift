import Cocoa

extension KeyboardInputWindow {

    func showAppropriateJumpView() {
        appDelegate?.jumpWindowControllers.forEach {
            switch activeJumpMode {
            case .grid:
                $0.viewController.showGrid()
                $0.viewController.hideElements()
            case .element:
                $0.viewController.showElements()
                $0.viewController.hideGrid()
            case .freestyle:
                $0.viewController.hideGrid()
                $0.viewController.hideElements()
            }
        }
        appDelegate?.useElementBasedNavigationMenuItem.isHidden = true
        appDelegate?.useGridBasedNavigationMenuItem.isHidden = true
        appDelegate?.useFreestyleNavigationMenuItem.isHidden = true
        appDelegate?.hideMenuItem.isHidden = false
    }

    func hideJumpViews() {
        appDelegate?.jumpWindowControllers.forEach {
            $0.viewController.hideGrid()
            $0.viewController.hideElements()
        }
        appDelegate?.useElementBasedNavigationMenuItem.isHidden = false
        appDelegate?.useGridBasedNavigationMenuItem.isHidden = false
        appDelegate?.useFreestyleNavigationMenuItem.isHidden = false
        appDelegate?.hideMenuItem.isHidden = true
    }

    func redrawJumpViews() {
        appDelegate?.jumpWindowControllers.forEach {
            $0.viewController.gridView.redraw()
            $0.viewController.elementView.redraw()
        }
    }

    func flashFeedback(duration: TimeInterval) {
        guard let jumpWindowControllers = appDelegate?.jumpWindowControllers else {
            return
        }

        for jumpWindowController in jumpWindowControllers {
            let viewController = jumpWindowController.viewController
            viewController.flashFeedback(at: viewController.view.bounds, duration: duration)
        }
    }

    func flashFeedback(at screenRect: CGRect, duration: TimeInterval) {
        guard let jumpWindowControllers = appDelegate?.jumpWindowControllers else {
            return
        }

        for windowController in jumpWindowControllers {
            if let screen = windowController.assignedScreen {
                if screen.frame.contains(screenRect) {
                    let rect = NSRect( // Convert from screen coordinates to window coordinates.
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
