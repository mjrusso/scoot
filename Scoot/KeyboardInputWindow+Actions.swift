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
        switch activeJumpMode {
        case .element:
            let delta = UserSettings.Constants.Sliders.elementViewOverallContrast.step
            modifyElementViewContrast(by: delta)
        case .grid:
            let delta = UserSettings.Constants.Sliders.gridViewOverallContrast.step
            modifyGridViewContrast(by: delta)
        default:
            break
        }
    }

    @IBAction func decreaseContrast(_ sender: NSMenuItem) {
        switch activeJumpMode {
        case .element:
            let delta = UserSettings.Constants.Sliders.elementViewOverallContrast.step
            modifyElementViewContrast(by: -delta)
        case .grid:
            let delta = UserSettings.Constants.Sliders.gridViewOverallContrast.step
            modifyGridViewContrast(by: -delta)
        default:
            break
        }
    }

    func modifyElementViewContrast(by delta: Double) {
        let config = UserSettings.Constants.Sliders.elementViewOverallContrast

        UserSettings.shared.elementViewOverallContrast = clamp(
            UserSettings.shared.elementViewOverallContrast + delta,
            minValue: config.min,
            maxValue: config.max
        )
        updateElementViewContrast()
    }

    func modifyGridViewContrast(by delta: Double) {
        let config = UserSettings.Constants.Sliders.gridViewOverallContrast

        UserSettings.shared.gridViewOverallContrast = clamp(
            UserSettings.shared.gridViewOverallContrast + delta,
            minValue: config.min,
            maxValue: config.max
        )

        updateGridViewContrast()
    }

    func updateGridViewContrast() {
        appDelegate?.jumpViewControllers.forEach {
            $0.updateGridContrast()
        }
    }

    func updateElementViewContrast() {
        appDelegate?.jumpViewControllers.forEach {
            $0.updateElementContrast()
        }
    }

}
