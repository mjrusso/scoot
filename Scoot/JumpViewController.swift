import Cocoa

class JumpViewController: NSViewController {

    struct Defaults {
        static let gridLineAlphaComponent: CGFloat = 0.15
        static let gridLabelAlphaComponent: CGFloat = 0.95
        static let gridBackgroundAlphaComponent: CGFloat = 0.45
        static let elementLabelAlphaComponent: CGFloat = 0.95
        static let elementLabelBackgroundAlphaComponent: CGFloat = 0.85
        static let elementBackgroundAlphaComponent: CGFloat = 0.15
    }

    /// A grid, subdividing the screen into a collection of evenly-sized cells.
    ///
    /// Used for grid-based navigation.
    var grid: Grid!

    /// An array of UI elements and the corresponding character sequences used to
    /// access these elements.
    ///
    /// Used for element-based navigation.
    var elements = [(element: Accessibility.Element, sequence: String)]()

    var window: NSWindow? {
        view.window
    }

    var appDelegate: AppDelegate? {
        NSApp.delegate as? AppDelegate
    }

    var keyboardInputWindow: KeyboardInputWindow? {
        appDelegate?.inputWindow
    }

    @IBOutlet var gridView: GridView!

    @IBOutlet var elementView: ElementView!

    var gridLineAlphaComponent = Defaults.gridLineAlphaComponent {
        didSet {
            gridLineAlphaComponent = clamp(
                gridLineAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            redrawGrid()
        }
    }

    var gridLabelAlphaComponent = Defaults.gridLabelAlphaComponent {
        didSet {
            gridLabelAlphaComponent = clamp(
                gridLabelAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            redrawGrid()
        }
    }

    var gridBackgroundAlphaComponent = Defaults.gridBackgroundAlphaComponent {
        didSet {
            gridBackgroundAlphaComponent = clamp(
                gridBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 0.6
            )
            redrawGrid()
        }
    }

    var elementLabelAlphaComponent = Defaults.elementLabelAlphaComponent {
        didSet {
            elementLabelAlphaComponent = clamp(
                elementLabelAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            redrawElements()
        }
    }

    var elementLabelBackgroundAlphaComponent = Defaults.elementLabelBackgroundAlphaComponent {
        didSet {
            elementLabelBackgroundAlphaComponent = clamp(
                elementLabelBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            redrawElements()
        }
    }

    var elementBackgroundAlphaComponent = Defaults.elementBackgroundAlphaComponent {
        didSet {
            elementBackgroundAlphaComponent = clamp(
                elementBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 0.6
            )
            redrawElements()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gridView.viewController = self
        elementView.viewController = self

        updateGridContrast()
        updateElementContrast()

        hideGrid()
        hideElements()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }
}


extension JumpViewController {

    func showGrid() {
        self.gridView.isHidden = false
    }

    func hideGrid() {
        self.gridView.isHidden = true
    }

    func redrawGrid() {
        self.gridView.redraw()
    }

    func showElements() {
        self.elementView.isHidden = false
    }

    func hideElements() {
        self.elementView.isHidden = true
    }

    func redrawElements() {
        self.elementView.redraw()
    }

}

extension JumpViewController {

    func updateGridContrast() {
        let adjustmentFactor = UserSettings.shared.gridViewOverallContrast

        gridLineAlphaComponent = Defaults.gridLineAlphaComponent + (1.0 * adjustmentFactor)
        gridLabelAlphaComponent = Defaults.gridLabelAlphaComponent + (0.9 * adjustmentFactor)
        gridBackgroundAlphaComponent = Defaults.gridBackgroundAlphaComponent + (0.8 * adjustmentFactor)
    }

    func updateElementContrast() {
        let adjustmentFactor = UserSettings.shared.elementViewOverallContrast

        elementLabelAlphaComponent = Defaults.elementLabelAlphaComponent + (0.8 * adjustmentFactor)
        elementLabelBackgroundAlphaComponent = Defaults.elementLabelBackgroundAlphaComponent + (0.6 * adjustmentFactor)
        elementBackgroundAlphaComponent = Defaults.elementBackgroundAlphaComponent + (0.4 * adjustmentFactor)
    }

}

extension JumpViewController {

    func flashFeedback(at rect: NSRect, duration: TimeInterval) {
        let feedbackView = FeedbackView(frame: rect)
        self.view.addSubview(feedbackView)
        feedbackView.flash(duration: duration) {
            feedbackView.removeFromSuperview()
        }
    }

}
