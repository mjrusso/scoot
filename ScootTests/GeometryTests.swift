import XCTest
@testable import Scoot

func makeRect(width: CGFloat, height: CGFloat) -> CGRect {
    CGRect(origin: .zero, size: CGSize(width: width, height: height))
}

class GeometryTests: XCTestCase {

    func testRectArea() {
        XCTAssertEqual(makeRect(width:  0, height:  0).area, 0)
        XCTAssertEqual(makeRect(width:  0, height:  1).area, 0)
        XCTAssertEqual(makeRect(width:  2, height:  4).area, 8)
        XCTAssertEqual(makeRect(width:  4, height:  2).area, 8)
        XCTAssertEqual(makeRect(width: -4, height:  2).area, 8)
        XCTAssertEqual(makeRect(width:  4, height: -2).area, 8)
        XCTAssertEqual(makeRect(width: 16, height:  4).area, 64)
    }

    func testRectNoOverlap() {
        let a = CGRect(x: 1, y: 1, width: 4, height: 4)
        let b = CGRect(x: 9, y: 9, width: 4, height: 4)

        XCTAssertEqual(a.percentageOverlapping(b), 0)

        let c = CGRect(x: 1, y: 1, width: 0, height: 0)
        let d = CGRect(x: 2, y: 2, width: 0, height: 0)

        XCTAssertEqual(c.percentageOverlapping(d), 0)
    }

    func testRectFullOverlap() {
        let a = CGRect(x: 0, y: 0, width: 4, height: 4)
        let b = CGRect(x: 0, y: 0, width: 4, height: 4)

        XCTAssertEqual(a.percentageOverlapping(b), 1)

        let c = CGRect(x: 0, y: 0, width: 4, height: 4)
        let d = CGRect(x: 1, y: 1, width: 2, height: 2)

        XCTAssertEqual(c.percentageOverlapping(d), 1)

        let e = CGRect(x: 1, y: 1, width: 2, height: 2)
        let f = CGRect(x: 0, y: 0, width: 4, height: 4)

        XCTAssertEqual(e.percentageOverlapping(f), 1)

        let g = CGRect(x: 0, y: 0, width: 4, height: 4)
        let h = CGRect(x: 2, y: 2, width: 2, height: 2)

        XCTAssertEqual(g.percentageOverlapping(h), 1)
    }

    func testRectPartialOverlap() {
        let a = CGRect(x: 0, y: 0, width: 4, height: 4)
        let b = CGRect(x: 2, y: 2, width: 4, height: 4)

        XCTAssertEqual(a.percentageOverlapping(b), 0.25)

        let c = CGRect(x: 0, y: 0, width: 4, height: 4)
        let d = CGRect(x: 3, y: 3, width: 4, height: 4)

        XCTAssertEqual(c.percentageOverlapping(d), 0.0625)

        let e = CGRect(x: 0, y: 0, width: 4, height: 4)
        let f = CGRect(x: 1, y: 1, width: 4, height: 4)

        XCTAssertEqual(e.percentageOverlapping(f), 0.5625)

        let g = CGRect(x: 1,   y: 1,   width: 4, height: 4)
        let h = CGRect(x: 1.2, y: 1.2, width: 4, height: 4)

        XCTAssertEqual(g.percentageOverlapping(h), 0.9025)

        let i = CGRect(x: -1, y: 0, width: 10, height: 10)
        let j = CGRect(x:  1, y: 0, width: 10, height: 10)

        XCTAssertEqual(i.percentageOverlapping(j), 0.8)

        let k = CGRect(x: -1, y: 0, width: 10, height: 10)
        let l = CGRect(x:  1, y: 0, width: 30, height: 10)

        XCTAssertEqual(k.percentageOverlapping(l), 0.4)
    }

}
