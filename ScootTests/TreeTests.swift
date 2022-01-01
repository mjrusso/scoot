import XCTest
@testable import Scoot

class TreeTests: XCTestCase {

    func testSequenceGenerationWithTwoKeys() throws {

        let keys: [Character] = ["a", "l"]

        XCTAssertEqual(
            Tree(candidates: Array(0..<2), keys: keys).sequences,
            ["a", "l"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<3), keys: keys).sequences,
            ["aa", "al", "l"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<4), keys: keys).sequences,
            ["aa", "al", "la", "ll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<5), keys: keys).sequences,
            ["aaa", "aal", "al", "la", "ll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<6), keys: keys).sequences,
            ["aaa", "aal", "ala", "all", "la", "ll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<7), keys: keys).sequences,
            ["aaa", "aal", "ala", "all", "laa", "lal", "ll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<8), keys: keys).sequences,
            ["aaa", "aal", "ala", "all", "laa", "lal", "lla", "lll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<9), keys: keys).sequences,
            ["aaaa", "aaal", "aal", "ala", "all", "laa", "lal", "lla", "lll"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<10), keys: keys).sequences,
            ["aaaa", "aaal", "aala", "aall", "ala", "all", "laa", "lal", "lla", "lll"]
        )

    }

    func testSequenceGenerationWithThreeKeys() throws {

        let keys: [Character] = ["a", "l", "g"]

        XCTAssertEqual(
            Tree(candidates: Array(0..<3), keys: keys).sequences,
            ["a", "l", "g",]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<4), keys: keys).sequences,
            ["aa", "al", "l", "g"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<5), keys: keys).sequences,
            ["aa", "al", "ag", "l", "g"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<6), keys: keys).sequences,
            ["aa", "al", "ag", "la", "ll", "g"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<7), keys: keys).sequences,
            ["aa", "al", "ag", "la", "ll", "lg", "g"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<8), keys: keys).sequences,
            ["aa", "al", "ag", "la", "ll", "lg", "ga", "gl"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<9), keys: keys).sequences,
            ["aa", "al", "ag", "la", "ll", "lg", "ga", "gl", "gg"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<10), keys: keys).sequences,
            ["aaa", "aal", "al", "ag", "la", "ll", "lg", "ga", "gl", "gg"]
        )

    }

    func testSequenceGenerationWithFourKeys() throws {

        let keys: [Character] = ["a", "l", "g", "h"]

        XCTAssertEqual(
            Tree(candidates: Array(0..<4), keys: keys).sequences,
            ["a", "l", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<5), keys: keys).sequences,
            ["aa", "al", "l", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<6), keys: keys).sequences,
            ["aa", "al", "ag", "l", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<7), keys: keys).sequences,
            ["aa", "al", "ag", "ah", "l", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<8), keys: keys).sequences,
            ["aa", "al", "ag", "ah", "la", "ll", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<9), keys: keys).sequences,
            ["aa", "al", "ag", "ah", "la", "ll", "lg", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<10), keys: keys).sequences,
            ["aa", "al", "ag", "ah", "la", "ll", "lg", "lh", "g", "h"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<11), keys: keys).sequences,
            ["aa", "al", "ag", "ah", "la", "ll", "lg", "lh", "ga", "gl", "h"]
        )

    }

    func testSequenceGenerationWithMoreKeysThanCandidates() throws {

        let keys: [Character] = ["a", "l", "g", "h"]

        XCTAssertEqual(
            Tree(candidates: Array(0..<1), keys: keys).sequences,
            ["a"]
        )
        XCTAssertEqual(
            Tree(candidates: Array(0..<2), keys: keys).sequences,
            ["a", "l"]
        )

        XCTAssertEqual(
            Tree(candidates: Array(0..<3), keys: keys).sequences,
            ["a", "l", "g",]
        )

    }

    func testTreeGenerationWithNoCandidates() throws {

        let keys: [Character] = ["a", "l", "g", "h"]

        let tree = Tree(candidates: Array<Int>(), keys: keys)

        XCTAssertEqual(
            tree.sequences,
            [""]
        )

        XCTAssertEqual(
            tree.leaves.map({ $0.value }),
            [nil]
        )

    }

    func testCandidateAssignments() {

        var tree = Tree(candidates: Array(0..<2), keys: ["a", "l"])

        XCTAssertEqual(
            tree.leaves.map({ $0.value }),
            [0, 1]
        )

        tree = Tree(candidates: Array(0..<3), keys: ["a", "l"])

        XCTAssertEqual(
            tree.leaves.map({ $0.value }),
            [0, 1, 2]
        )

        tree = Tree(candidates: Array(0..<4), keys: ["a", "l"])

        XCTAssertEqual(
            tree.leaves.map({ $0.value }),
            [0, 1, 2, 3]
        )

        tree = Tree(candidates: Array(0..<5), keys: ["a", "l"])

        XCTAssertEqual(
            tree.leaves.map({ $0.value }),
            [0, 1, 2, 3, 4]
        )

    }

    func testSteppingByCharacter() {
        let tree = Tree(candidates: Array(0..<5), keys: ["a", "z"])

        XCTAssertEqual(
            tree.sequences,
            ["aaa", "aaz", "az", "za", "zz"]
        )

        var node: Tree<Int>.Node<Int>! = nil

        node = tree.root.step(by: "a")

        XCTAssertEqual(node.label, "a")

        node = node.step(by: "a")

        XCTAssertEqual(node.label, "a")

        node = node.step(by: "z")

        XCTAssertEqual(node, Tree<Int>.Node<Int>(label: "z", value: 1))

        node = node.step(by: "q")

        XCTAssertEqual(
            node,
            nil
        )

        node = tree.root.step(by: "q")

        XCTAssertEqual(node, nil)

        node = tree.root.step(by: "z")

        XCTAssertEqual(node.label, "z")

        node = node.step(by: "z")

        XCTAssertEqual(node, Tree<Int>.Node<Int>(label: "z", value: 4))
    }

    func testWalkingByCharacterSequence() {
        let tree = Tree(candidates: Array(0..<5), keys: ["a", "z"])

        XCTAssertEqual(
            tree.sequences,
            ["aaa", "aaz", "az", "za", "zz"]
        )

        XCTAssertEqual(
            tree.walk(sequence: ["a", "a", "a"])?.value,
            0
        )

        XCTAssertEqual(
            tree.walk(sequence: ["a", "a", "z"])?.value,
            1
        )

        XCTAssertEqual(
            tree.walk(sequence: ["a", "z"])?.value,
            2
        )

        XCTAssertEqual(
            tree.walk(sequence: ["z", "a"])?.value,
            3
        )

        XCTAssertEqual(
            tree.walk(sequence: ["z", "z"])?.value,
            4
        )

        XCTAssertEqual(
            tree.walk(sequence: ["z", "z", "q"])?.value,
            nil
        )

        XCTAssertEqual(
            tree.walk(sequence: ["z", "q"])?.value,
            nil
        )

        XCTAssertEqual(
            tree.walk(sequence: ["q"])?.value,
            nil
        )

    }

}
