import Cocoa

class ViewController: NSViewController {

    var mouse: Mouse!

    // A grid, subdividing the screen into a collection of evenly-sized cells.
    var grid: Grid!

    // The underlying data structure enabling cursor movement via a
    // character-based decision tree.
    var tree: Tree<CGRect>!

    // Non-nil, if the user is in the process of entering a key sequence to
    // navigate via the decision tree.
    var currentNode: Tree<CGRect>.Node<CGRect>?

    var isWalkingDecisionTree: Bool {
        currentNode != nil
    }

    var isHoldingDownMouseButton = false

    var window: NSWindow? {
        view.window
    }

    var targetCellSize = CGSize(width: 60.0, height: 60.0) {
        didSet {
            targetCellSize = clamp(
                targetCellSize,
                minValue: CGSize(width: 45.0, height: 45.0),
                maxValue: CGSize(width: 90.0, height: 90.0)
            )
            if targetCellSize != oldValue {
                initializeCoreDataStructures()
            }
        }
    }

    let numStepsPerCell = CGFloat(6.0)

    var stepWidth: CGFloat {
        (grid?.cellWidth ?? targetCellSize.width) / numStepsPerCell
    }

    var stepHeight: CGFloat {
        (grid?.cellHeight ?? targetCellSize.height) / numStepsPerCell
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

    var gridLineAlphaComponent: CGFloat = 0.04 {
        didSet {
            gridLineAlphaComponent = clamp(
                gridLineAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
            gridView.redraw()
        }
    }

    var gridLabelAlphaComponent: CGFloat = 0.5 {
        didSet {
            gridLabelAlphaComponent = clamp(
                gridLabelAlphaComponent,
                minValue: 0.01,
                maxValue: 1.0
            )
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

        self.initializeCoreDataStructures()
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        window?.makeFirstResponder(self)
    }
}

extension ViewController {

    func initializeCoreDataStructures() {
        guard let screen = NSScreen.main else {
            return
        }

        let screenSize = screen.visibleFrame.size

        let grid = Grid(
            gridSize: screenSize,
            targetCellSize: targetCellSize
        )

        let tree = Tree(
            candidates: grid.rects,
            keys: determineAvailableKeys(numCandidates: grid.numCells)
        )

        grid.data = tree.sequences

        assert(grid.numCells == grid.rects.count)
        assert(tree.sequences.count == grid.numCells)

        self.tree = tree
        self.grid = grid

        gridView.redraw()
    }

    func determineAvailableKeys(numCandidates: Int) -> [Character] {

        let keys: [[Character]] = [
            ["a", "s", "d", "f", "j", "k", "l"],
            ["g", "h"],
            ["q", "w", "e", "r", "u", "i", "o", "p"],
            ["t", "y"],
            ["z", "x", "c", "v", "b", "n", "m"],
            [";"],
        ]

        switch numCandidates {
        case 0..<800:
            return keys[0] + keys[1]
        case 800..<1200:
            return keys[0] + keys[1] + keys[2]
        case 1200..<1400:
            return keys[0] + keys[1] + keys[2] + keys[3]
        default:
            return keys.flatMap { $0 }
        }
    }

}

// MARK: - Actions

extension ViewController {

    @IBAction func toggleGridLabels(_ sender: NSMenuItem) {
        isDisplayingGridLabels.toggle()
    }

    @IBAction func toggleGridLines(_ sender: NSMenuItem) {
        isDisplayingGridLines.toggle()
    }

    @IBAction func increaseGridSize(_ sender: NSMenuItem) {
        targetCellSize += CGSize(width: 10.0, height: 10.0)
    }

    @IBAction func decreaseGridSize(_ sender: NSMenuItem) {
        targetCellSize -= CGSize(width: 10.0, height: 10.0)
    }

    @IBAction func increaseContrast(_ sender: NSMenuItem) {
        gridLineAlphaComponent += 0.1
        gridLabelAlphaComponent += 0.15
    }

    @IBAction func decreaseContrast(_ sender: NSMenuItem) {
        gridLineAlphaComponent -= 0.1
        gridLabelAlphaComponent -= 0.15
    }

}
