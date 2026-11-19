import Foundation

class Grid {

    /// The underlying data stored in the grid.  (See `index` for details on how grid
    /// coordinates are mapped to this 1-dimensional array.)
    var data: [String] {
        didSet {
            if numCells != data.count {
                data = oldValue
            }
        }
    }

    let numColumns: Int

    let numRows: Int

    let size: CGSize

    let cellWidth: CGFloat

    let cellHeight: CGFloat

    let cellSize: CGSize

    let numCells: Int

    lazy var rects: [CGRect] = {
        var rects = [CGRect]()
        rects.reserveCapacity(numCells)

        // Index-based, not `stride(from: 0, to: width, by: cellWidth)`: with a
        // fractional cell size the last step can land a hair under the edge
        // and emit an extra row or column (e.g. 800×1865 at 160 pt gave 60
        // rects for 55 cells), which tripped the cell-count assertion when
        // the grid was resized with ⇧⌘- and mislabelled cells in Release.
        for row in 0..<numRows {
            for column in 0..<numColumns {
                let origin = CGPoint(x: CGFloat(column) * cellWidth, y: CGFloat(row) * cellHeight)
                rects.append(CGRect(origin: origin, size: cellSize))
            }
        }

        return rects
    }()

    convenience init(gridSize: CGSize, targetCellSize: CGSize) {
        let numRows = Int(floor(gridSize.height / targetCellSize.height))
        let numColumns = Int(floor(gridSize.width / targetCellSize.width))
        self.init(numRows: numRows, numColumns: numColumns, gridSize: gridSize)
    }

    init(numRows: Int, numColumns: Int, gridSize: CGSize) {
        let numCells = numRows * numColumns
        self.size = gridSize
        self.numRows = numRows
        self.numColumns = numColumns
        self.numCells = numCells
        self.cellWidth = gridSize.width / CGFloat(numColumns)
        self.cellHeight = gridSize.height / CGFloat(numRows)
        self.cellSize = CGSize(width: cellWidth, height: cellHeight)
        self.data = (0..<numCells).map { String($0) }
    }

    func data(atX x: Int, y: Int) -> String {
        let index = (y * numColumns) + x
        return data[index]
    }

    func data(atIndex index: Int) -> String {
        return data[index]
    }

    /// Converts grid coordinates into an index in a 1-dimensional array.
    ///
    /// Consider a grid with 6 columns and 4 rows: (x: 0, y: 0) is the is the
    /// bottom-left corner, and (x: 5, y: 3) is the top-right corner. This maps
    /// to the following indices in a 1-dimensional array:
    ///
    /// 18 19 20 21 22 23
    /// 12 13 14 15 16 17
    ///  6  7  8  9 10 11
    ///  0  1  2  3  4  5
    ///
    /// For example, the coordinate (x: 0, y: 0) has an index of 0, and the
    /// coordinate (x: 5, y: 3) has an index of 23.
    internal func index(atX x: Int, y: Int) -> Int {
        (y * numColumns) + x
    }

    /// The inverse of `index`: given the index in a 1-dimensional array,
    /// return the grid coordinates.
    internal func coordinates(atIndex index: Int) -> (x: Int, y: Int) {
        let x = index % self.numColumns
        let y = (index - x) / self.numColumns
        return (x: x, y: y)
    }

}
