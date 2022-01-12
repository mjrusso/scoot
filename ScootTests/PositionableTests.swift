import XCTest
@testable import Scoot

struct Item: Positionable, Equatable {
    var frame: CGRect
}

func reduceCrowding(_ items: [Item]) -> [Item] {
    items.reducingCrowding(intersectionThreshold: 0.1, paddingX: 0, paddingY: 10)
}

class PositionableTests: XCTestCase {

    func testNoItemsRemovedWhenFramesAreNotCloseEnough()  {
        var items = [Item]()

        XCTAssertEqual(reduceCrowding(items), items)

        items = [Item(frame: .zero)]

        XCTAssertEqual(reduceCrowding(items), items)

        items = [
            Item(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10))),
            Item(frame: CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 10, height: 10))),
        ]

        XCTAssertEqual(reduceCrowding(items), items)

        items = [
            Item(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10))),
            Item(frame: CGRect(origin: CGPoint(x: 20, y: 20), size: CGSize(width: 10, height: 10))),
            Item(frame: CGRect(origin: CGPoint(x: 40, y: 40), size: CGSize(width: 10, height: 10))),
        ]

        XCTAssertEqual(reduceCrowding(items), items)
    }

    func testItemsWithDuplicateFramesRemoved() {
        let item = Item(frame: CGRect(origin: CGPoint(x: 2, y: 4), size: CGSize(width: 10, height: 10)))

        XCTAssertEqual(reduceCrowding([item, item, item, item, item]), [item])
        XCTAssertEqual(reduceCrowding([item, item, item, item]), [item])
        XCTAssertEqual(reduceCrowding([item, item, item]), [item])
        XCTAssertEqual(reduceCrowding([item, item, item]), [item])
        XCTAssertEqual(reduceCrowding([item, item]), [item])
        XCTAssertEqual(reduceCrowding([item]), [item])

        let other = Item(frame: .zero)

        XCTAssertEqual(reduceCrowding([item, other, item, item, item, item]), [item, other])
        XCTAssertEqual(reduceCrowding([item, other, item, item, item]), [item, other])
        XCTAssertEqual(reduceCrowding([item, other, item, item]), [item, other])
        XCTAssertEqual(reduceCrowding([item, other, item, item]), [item, other])
        XCTAssertEqual(reduceCrowding([item, other, item]), [item, other])
        XCTAssertEqual(reduceCrowding([item, other]), [item, other])

        XCTAssertEqual(reduceCrowding([other, item, item, item, item, item]), [other, item])
    }

    func testItemsNotRemovedWhenFramesOverlapLessThanTenPercent() {
        let size = CGSize(width: 10, height: 10)

        let a = Item(frame: CGRect(origin: .zero, size: size))
        let b = Item(frame: CGRect(origin: CGPoint(x: 9, y: 9), size: size))

        let items = [a, b]

        let percentageOverlapping = a.frame.percentageOverlapping(b.frame)

        XCTAssertGreaterThan(percentageOverlapping, 0)
        XCTAssertLessThan(percentageOverlapping, 0.1)

        XCTAssertEqual(reduceCrowding(items), items)
    }

    func testLargerItemsRemovedWhenFramesOverlapCompletely() {
        let size = CGSize(width: 10, height: 10)

        let a0 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 1, height: 1)))
        let a1 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 0, height: 0)))

        let b0 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 0, height: 0)))
        let b1 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 1, height: 1)))

        let overlap0 = a0.frame.percentageOverlapping(b0.frame)

        XCTAssertEqual(overlap0, 1.0)

        XCTAssertEqual(reduceCrowding([a0, b0]), [b0])
        XCTAssertEqual(reduceCrowding([b0, a0]), [b0])

        let overlap1 = a1.frame.percentageOverlapping(b1.frame)

        XCTAssertEqual(overlap1, 1.0)

        XCTAssertEqual(reduceCrowding([a1, b1]), [a1])
        XCTAssertEqual(reduceCrowding([b1, a1]), [a1])
    }

    func testSmallerItemsRemovedWhenFramesOverlapAtLeastTenPercent() {
        let size = CGSize(width: 10, height: 10)

        let a0 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 1, height: 1)))
        let a1 = Item(frame: CGRect(origin: .zero, size: size + CGSize(width: 0, height: 0)))

        let b0 = Item(frame: CGRect(origin: CGPoint(x: 6.5, y: 6.5), size: size + CGSize(width: 0, height: 0)))
        let b1 = Item(frame: CGRect(origin: CGPoint(x: 6.5, y: 6.5), size: size + CGSize(width: 1, height: 1)))

        let overlap0 = a0.frame.percentageOverlapping(b0.frame)

        XCTAssertGreaterThan(overlap0, 0)
        XCTAssertGreaterThanOrEqual(overlap0, 0.1)

        XCTAssertEqual(reduceCrowding([a0, b0]), [a0])
        XCTAssertEqual(reduceCrowding([b0, a0]), [a0])

        let overlap1 = a1.frame.percentageOverlapping(b1.frame)

        XCTAssertGreaterThan(overlap1, 0)
        XCTAssertGreaterThanOrEqual(overlap1, 0.1)

        XCTAssertEqual(reduceCrowding([a1, b1]), [b1])
        XCTAssertEqual(reduceCrowding([b1, a1]), [b1])
    }

    func testItemsRemovedWhenPaddedFrameOverlaps() {
        let smaller = CGSize(width: 10, height: 10)
        let bigger = CGSize(width: 10.5, height: 10.5)

        let a = Item(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: smaller))
        let b = Item(frame: CGRect(origin: CGPoint(x: 0, y: 11), size: bigger))

        XCTAssertFalse(a.frame.intersects(b.frame))

        XCTAssertEqual(reduceCrowding([a, b]), [b])
        XCTAssertEqual(reduceCrowding([b, a]), [b])
    }

    func testComplexCrowdingScenarios() {
        let a = Item(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))
        let b = Item(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)))

        let c = Item(frame: CGRect(origin: CGPoint(x: -1, y: 4), size: CGSize(width: 8, height: 8)))
        let d = Item(frame: CGRect(origin: CGPoint(x: -1, y: 4), size: CGSize(width: 8, height: 8)))

        let e = Item(frame: CGRect(origin: CGPoint(x: -9, y: 9), size: CGSize(width: 2, height: 2)))
        let f = Item(frame: CGRect(origin: CGPoint(x: -9, y: 9), size: CGSize(width: 2, height: 2)))

        XCTAssertEqual(reduceCrowding([a]), [a])

        XCTAssertEqual(reduceCrowding([a, c]), [c])

        XCTAssertEqual(reduceCrowding([a, c, e]), [c, e])

        XCTAssertEqual(reduceCrowding([a, b, c, d, e, f]), [c, e])

        XCTAssertEqual(reduceCrowding([a, b, a, b, c, d, c, d, e, f, e, f]), [c, e])

        XCTAssertEqual(reduceCrowding([a, b, b, a, c, d, d, c, e, f, f, e]), [c, e])
    }

}
