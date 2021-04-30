import Cocoa

class ViewController: NSViewController {

    var grid: Grid?

    var mouse: Mouse?

    var window: NSWindow? {
        view.window
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

        self.grid = Grid(
            gridSize: screen.visibleFrame.size,
            targetStepSize: CGSize(width: 60.0, height: 60.0))

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
