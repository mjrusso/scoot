import Cocoa

class ViewController: NSViewController {

    var grid: Grid?

    var mouse: Mouse?

    var window: NSWindow? {
        view.window
    }

    var defaultCellSize = CGSize(width: 60.0, height: 60.0)

    var numStepsPerCell = CGFloat(6.0)

    var stepWidth: CGFloat {
        (grid?.cellWidth ?? defaultCellSize.width) / numStepsPerCell
    }

    var stepHeight: CGFloat {
        (grid?.cellHeight ?? defaultCellSize.height) / numStepsPerCell
    }

    @IBOutlet var gridView: GridView!

    var isDisplayingGrid: Bool = false {
        didSet {
            gridView.redraw()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gridView.viewController = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        guard let screen = NSScreen.main else {
            return
        }

        self.mouse = Mouse(screen: screen)

        let config = Grid.Config(
            gridSize: screen.visibleFrame.size,
            targetCellSize: defaultCellSize)

        self.grid = Grid(config: config)

        isDisplayingGrid = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        window?.makeFirstResponder(self)
    }
}

// MARK: - Actions

extension ViewController {

    @IBAction func toggleGrid(_ sender: NSMenuItem) {
        isDisplayingGrid.toggle()
    }

}
