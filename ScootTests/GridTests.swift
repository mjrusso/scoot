import XCTest
@testable import Scoot

class GridTests: XCTestCase {

    let grid = Grid(numRows: 3, numCols: 4, gridSize: .zero)

    func testIndexing() {
        XCTAssertEqual(grid.index(atX: 0, y: 0), 0)
        XCTAssertEqual(grid.index(atX: 1, y: 0), 1)
        XCTAssertEqual(grid.index(atX: 2, y: 0), 2)
        XCTAssertEqual(grid.index(atX: 3, y: 0), 3)
        XCTAssertEqual(grid.index(atX: 0, y: 1), 4)
        XCTAssertEqual(grid.index(atX: 1, y: 1), 5)
        XCTAssertEqual(grid.index(atX: 2, y: 1), 6)
        XCTAssertEqual(grid.index(atX: 3, y: 1), 7)
        XCTAssertEqual(grid.index(atX: 0, y: 2), 8)
        XCTAssertEqual(grid.index(atX: 1, y: 2), 9)
        XCTAssertEqual(grid.index(atX: 2, y: 2), 10)
        XCTAssertEqual(grid.index(atX: 3, y: 2), 11)
    }

    func testInverseIndexing() {
        XCTAssertEqual(grid.coordinates(atIndex: 0).x, 0)
        XCTAssertEqual(grid.coordinates(atIndex: 0).y, 0)

        XCTAssertEqual(grid.coordinates(atIndex: 1).x, 1)
        XCTAssertEqual(grid.coordinates(atIndex: 1).y, 0)

        XCTAssertEqual(grid.coordinates(atIndex: 2).x, 2)
        XCTAssertEqual(grid.coordinates(atIndex: 2).y, 0)

        XCTAssertEqual(grid.coordinates(atIndex: 3).x, 3)
        XCTAssertEqual(grid.coordinates(atIndex: 3).y, 0)

        XCTAssertEqual(grid.coordinates(atIndex: 4).x, 0)
        XCTAssertEqual(grid.coordinates(atIndex: 4).y, 1)

        XCTAssertEqual(grid.coordinates(atIndex: 5).x, 1)
        XCTAssertEqual(grid.coordinates(atIndex: 5).y, 1)

        XCTAssertEqual(grid.coordinates(atIndex: 6).x, 2)
        XCTAssertEqual(grid.coordinates(atIndex: 6).y, 1)

        XCTAssertEqual(grid.coordinates(atIndex: 7).x, 3)
        XCTAssertEqual(grid.coordinates(atIndex: 7).y, 1)

        XCTAssertEqual(grid.coordinates(atIndex: 8).x, 0)
        XCTAssertEqual(grid.coordinates(atIndex: 8).y, 2)

        XCTAssertEqual(grid.coordinates(atIndex: 9).x, 1)
        XCTAssertEqual(grid.coordinates(atIndex: 9).y, 2)

        XCTAssertEqual(grid.coordinates(atIndex: 10).x, 2)
        XCTAssertEqual(grid.coordinates(atIndex: 10).y, 2)

        XCTAssertEqual(grid.coordinates(atIndex: 11).x, 3)
        XCTAssertEqual(grid.coordinates(atIndex: 11).y, 2)
    }

    func testBasicInitialization() {
        let numRows = 3
        let numCols = 4
        let gridSize = CGSize(width: 200, height: 400)

        let grid = Grid(numRows: numRows, numCols: numCols, gridSize: gridSize)

        XCTAssertEqual(grid.numCells, numRows*numCols)
        XCTAssertEqual(grid.cellWidth, gridSize.width/CGFloat(numCols))
        XCTAssertEqual(grid.cellHeight, gridSize.height/CGFloat(numRows))
        XCTAssertEqual(grid.cellSize, CGSize(
                        width: gridSize.width/CGFloat(numCols),
                        height: gridSize.height/CGFloat(numRows)))
    }

    func testInitializationViaTargetSizing() {
        let gridSize = CGSize(width: 200, height: 440)

        // This target size evenly divides the grid size, in both dimensions.
        var targetCellSize = CGSize(width: 20, height: 40)

        var grid = Grid(gridSize: gridSize, targetCellSize: targetCellSize)

        XCTAssertEqual(grid.numColumns, 10)

        XCTAssertEqual(grid.numRows, 11)

        XCTAssertEqual(grid.cellSize, targetCellSize)

        // This target size doesn't evenly divide the grid size, in either dimension.
        targetCellSize = CGSize(width: 30, height: 30)

        grid = Grid(gridSize: gridSize, targetCellSize: targetCellSize)

        XCTAssertEqual(grid.numColumns, 6)
        XCTAssertEqual(grid.numRows, 14)

        XCTAssertEqual(grid.cellSize, CGSize(
                        width: gridSize.width/CGFloat(6),
                        height: gridSize.height/CGFloat(14)))
    }

}
