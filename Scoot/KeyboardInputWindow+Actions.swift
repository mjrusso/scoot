import Cocoa

extension KeyboardInputWindow {

    @IBAction func toggleGridLabels(_ sender: NSMenuItem) {
        UserSettings.shared.showGridLabels.toggle()
        redrawJumpViews()
    }

    @IBAction func toggleGridLines(_ sender: NSMenuItem) {
        UserSettings.shared.showGridLines.toggle()
        redrawJumpViews()
    }

    @IBAction func increaseGridSize(_ sender: NSMenuItem) {
        targetCellSize += CGSize(width: 10.0, height: 10.0)
        appDelegate?.jumpViewControllers.forEach {
            $0.redrawGrid()
        }
    }

    @IBAction func decreaseGridSize(_ sender: NSMenuItem) {
        targetCellSize -= CGSize(width: 10.0, height: 10.0)
        appDelegate?.jumpViewControllers.forEach {
            $0.redrawGrid()
        }
    }

    @IBAction func increaseContrast(_ sender: NSMenuItem) {
        appDelegate?.jumpViewControllers.forEach {
            $0.gridLineAlphaComponent += 0.2
            $0.gridLabelAlphaComponent += 0.05
            $0.gridBackgroundAlphaComponent += 0.2
            $0.elementLabelAlphaComponent += 0.01
            $0.elementLabelBackgroundAlphaComponent += 0.05
            $0.elementBackgroundAlphaComponent += 0.05
        }
    }

    @IBAction func decreaseContrast(_ sender: NSMenuItem) {
        appDelegate?.jumpViewControllers.forEach {
            $0.gridLineAlphaComponent -= 0.2
            $0.gridLabelAlphaComponent -= 0.05
            $0.gridBackgroundAlphaComponent -= 0.2
            $0.elementLabelAlphaComponent -= 0.01
            $0.elementLabelBackgroundAlphaComponent -= 0.05
            $0.elementBackgroundAlphaComponent -= 0.05
        }
    }

}
