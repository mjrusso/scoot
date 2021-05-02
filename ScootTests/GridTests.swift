import XCTest
@testable import Scoot

class GridTests: XCTestCase {

    let grid = Grid(numRows: 3, numCols: 4, gridSize: CGSize(width: 200, height: 200))

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

}
