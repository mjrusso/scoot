import XCTest
@testable import Scoot

class GridTests: XCTestCase {

    let grid = Grid(config: Grid.Config(numRows: 3, numColumns: 4, gridSize: .zero))

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

    func testInitialization() {
        let numRows = 3
        let numColumns = 4
        let gridSize = CGSize(width: 200, height: 400)

        let config = Grid.Config(numRows: numRows, numColumns: numColumns, gridSize: gridSize)

        XCTAssertEqual(config.numCells, numRows*numColumns)
        XCTAssertEqual(config.cellWidth, gridSize.width/CGFloat(numColumns))
        XCTAssertEqual(config.cellHeight, gridSize.height/CGFloat(numRows))
        XCTAssertEqual(config.cellSize, CGSize(
                        width: gridSize.width/CGFloat(numColumns),
                        height: gridSize.height/CGFloat(numRows)))
    }

    func testInitializationViaTargetCellSizing() {
        let gridSize = CGSize(width: 200, height: 440)

        // This target size evenly divides the grid size, in both dimensions.
        var targetCellSize = CGSize(width: 20, height: 40)

        var config = Grid.Config(gridSize: gridSize, targetCellSize: targetCellSize)

        var grid = Grid(config: config)

        XCTAssertEqual(grid.numColumns, 10)

        XCTAssertEqual(grid.numRows, 11)

        XCTAssertEqual(grid.cellSize, targetCellSize)

        // This target size doesn't evenly divide the grid size, in either dimension.
        targetCellSize = CGSize(width: 30, height: 30)

        config = Grid.Config(gridSize: gridSize, targetCellSize: targetCellSize)

        grid = Grid(config: config)

        XCTAssertEqual(grid.numColumns, 6)
        XCTAssertEqual(grid.numRows, 14)

        XCTAssertEqual(grid.cellSize, CGSize(
                        width: gridSize.width/CGFloat(6),
                        height: gridSize.height/CGFloat(14)))
    }

    func testRects() {
        let numRows = 3
        let numColumns = 2
        let gridSize = CGSize(width: 200, height: 90)

        let config = Grid.Config(numRows: numRows, numColumns: numColumns, gridSize: gridSize)

        XCTAssertEqual(config.rects, [
            CGRect(x: 0, y: 0, width: 100, height: 30),
            CGRect(x: 100, y: 0, width: 100, height: 30),
            CGRect(x: 0, y: 30, width: 100, height: 30),
            CGRect(x: 100, y: 30, width: 100, height: 30),
            CGRect(x: 0, y: 60, width: 100, height: 30),
            CGRect(x: 100, y: 60, width: 100, height: 30),
        ])
    }

    func testPropertyProxying() {
        let numRows = 3
        let numColumns = 4
        let gridSize = CGSize(width: 200, height: 400)

        let config = Grid.Config(numRows: numRows, numColumns: numColumns, gridSize: gridSize)
        let grid = Grid(config: config)

        XCTAssertEqual(grid.numCells, config.numCells)
        XCTAssertEqual(grid.cellWidth, config.cellWidth)
        XCTAssertEqual(grid.cellHeight, config.cellHeight)
        XCTAssertEqual(grid.cellSize, config.cellSize)
        XCTAssertEqual(grid.rects, config.rects)
    }
}
