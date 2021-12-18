import Cocoa

class JumpViewController: NSViewController {

    // A grid, subdividing the screen into a collection of evenly-sized cells.
    var grid: Grid!

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
                maxValue: 1.0
            )
            gridView.redraw()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gridView.viewController = self

        hideGrid()
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

    func flashFeedback(at rect: NSRect, duration: TimeInterval) {
        let feedbackView = FeedbackView(frame: rect)
        self.view.addSubview(feedbackView)
        feedbackView.flash(duration: duration) {
            feedbackView.removeFromSuperview()
        }
    }

}

