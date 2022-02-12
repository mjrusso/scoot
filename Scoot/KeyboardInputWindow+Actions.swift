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
        let delta = UserSettings.Constants.Sliders.targetGridCellSideLength.step
        modifyGridSize(by: delta)
    }

    @IBAction func decreaseGridSize(_ sender: NSMenuItem) {
        let delta = UserSettings.Constants.Sliders.targetGridCellSideLength.step
        modifyGridSize(by: -delta)
    }

    func modifyGridSize(by delta: Double) {
        let config = UserSettings.Constants.Sliders.targetGridCellSideLength

        UserSettings.shared.targetGridCellSideLength = clamp(
            UserSettings.shared.targetGridCellSideLength + delta,
            minValue: config.min,
            maxValue: config.max
        )

        initializeCoreDataStructuresForGridBasedMovement()
        redrawJumpViews()
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
