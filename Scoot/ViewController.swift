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

        let grid = Grid(
            gridSize: screen.visibleFrame.size,
            targetCellSize: defaultCellSize
        )

        let tree = Tree(
            candidates: grid.rects,
            keys: determineAvailableKeys(numCandidates: grid.numCells)
        )

        grid.data = tree.sequences

        self.tree = tree
        self.grid = grid

        isDisplayingGrid = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        window?.makeFirstResponder(self)
    }
}

extension ViewController {

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

    @IBAction func toggleGrid(_ sender: NSMenuItem) {
        isDisplayingGrid.toggle()
    }

}
