import Cocoa

class JumpViewController: NSViewController {

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

    var isDisplayingGridLabels: Bool = true {
        didSet {
            gridView.redraw()
        }
    }

    var isDisplayingGridLines: Bool = true {
        didSet {
            gridView.redraw()
        }
    }

    var gridLineAlphaComponent: CGFloat = 0.15 {
        didSet {
            gridLineAlphaComponent = clamp(
                gridLineAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            gridView.redraw()
        }
    }

    var gridLabelAlphaComponent: CGFloat = 0.95 {
        didSet {
            gridLabelAlphaComponent = clamp(
                gridLabelAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            gridView.redraw()
        }
    }

    var gridBackgroundAlphaComponent: CGFloat = 0.45 {
        didSet {
            gridBackgroundAlphaComponent = clamp(
                gridBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 0.6
            )
            gridView.redraw()
        }
    }

    var elementLabelAlphaComponent: CGFloat = 0.95 {
        didSet {
            elementLabelAlphaComponent = clamp(
                elementLabelAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            elementView.redraw()
        }
    }

    var elementLabelBackgroundAlphaComponent: CGFloat = 0.85 {
        didSet {
            elementLabelBackgroundAlphaComponent = clamp(
                elementLabelBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            elementView.redraw()
        }
    }

    var elementBackgroundAlphaComponent: CGFloat = 0.15 {
        didSet {
            elementBackgroundAlphaComponent = clamp(
                elementBackgroundAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            elementView.redraw()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gridView.viewController = self
        elementView.viewController = self

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

    func showElements() {
        self.elementView.isHidden = false
    }

    func hideElements() {
        self.elementView.isHidden = true
    }

    func flashFeedback(at rect: NSRect, duration: TimeInterval) {
        let feedbackView = FeedbackView(frame: rect)
        self.view.addSubview(feedbackView)
        feedbackView.flash(duration: duration) {
            feedbackView.removeFromSuperview()
        }
    }

}
