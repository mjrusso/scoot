import Foundation

struct Grid {

    let numColumns: Int

    let numRows: Int

    let size: CGSize

    var cellWidth: CGFloat {
        size.width / CGFloat(numColumns)
    }

    var cellHeight: CGFloat {
        size.height / CGFloat(numRows)
    }

    var cellSize: CGSize {
        CGSize(width: cellWidth, height: cellHeight)
    }

    var numCells: Int {
        data.count
    }

    /// The underlying data stored in the grid.  (See `index` for details on how grid
    /// coordinates are mapped to this 1-dimensional array.)
    let data: [String]

    init(numRows rows: Int, numCols cols: Int, gridSize size: CGSize) {
        self.numRows = rows
        self.numColumns = cols
        self.size = size

        let count = numRows * numColumns
        var data = [String]()
        data.reserveCapacity(count)

        for i in 0..<count {
            data.append("\(i)")
        }

        self.data = data
    }

    init(gridSize: CGSize, targetCellSize: CGSize) {
        let numCols = floor(gridSize.width / targetCellSize.width)
        let numRows = floor(gridSize.height / targetCellSize.height)

        self.init(numRows: Int(numRows), numCols: Int(numCols), gridSize: gridSize)
    }

    func data(atX x: Int, y: Int) -> String {
        let index = (y * numColumns) + x
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
