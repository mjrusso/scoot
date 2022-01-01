import Foundation

/// A tree-based data structure (decision tree).
///
/// - Parent nodes are connected to child nodes via labelled edges.
///
/// - Leaf nodes (i.e., candidates) store values (of type `T`).
///
/// - The labels associated with each edge are distinct, per-level of the tree.
///
/// - These properties enable each leaf node to be uniquely identified by a sequence of characters.

class Tree<T>: CustomStringConvertible where T: Equatable {

    class Node<T>: Equatable, CustomStringConvertible where T: Equatable {

        /// The label of the edge connecting this node to its parent.
        ///
        /// All labels must be distinct, per level of the tree.
        let label: Character

        /// The value associated with this node.
        ///
        /// It is assumed that only leaf nodes have non-nil values.
        var value: T?

        var children: [Node]

        var isLeaf: Bool { children.isEmpty }

        var numChildren: Int { children.count }

        var description: String {
            isLeaf ? "\(label) \(String(describing: value))" : "\(label) \(children)"
        }

        init(label: Character, value: T? = nil) {
            self.children = []
            self.label = label
            self.value = value
        }

        func addChild(_ child: Node) {
            self.children.append(child)
        }

        func step(by character: Character) -> Node<T>? {
            self.children.first(where: {
                $0.label == character
            })
        }

        static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
            return lhs.label == rhs.label &&
                lhs.value == rhs.value &&
                lhs.children == rhs.children
        }

    }

    let root: Node<T>

    var description: String {
        String(describing: root)
    }

    lazy var leaves: [Node<T>] = {
        func traverse(from node: Node<T>) -> [Node<T>] {
            node.isLeaf ? [node] : node.children.flatMap { traverse(from: $0)}
        }
        return traverse(from: self.root)
    }()

    /// Returns the list of all possible character sequences associated with the decision tree.
    ///
    /// (Each sequence  is a string of non-overlapping characters used to uniquely identify one of
    /// the candidates represented in the tree.)
    lazy var sequences: [String] = {
        func traverse(from node: Node<T>, path: String = "") -> [String] {
            node.isLeaf ?
                [String("\(path)\(String(node.label))".dropFirst())] :
                node.children.flatMap {
                    traverse(from: $0, path: path + String(node.label))
                }
        }
        return traverse(from: self.root)
    }()

    init(candidates: [T], keys: [Character]) {
        self.root = Node(label: " ")

        let numCandidates = candidates.count

        // The underlying implementation expects there to be at least as many
        // candidates as there are keys...
        let keys = Array(keys.prefix(numCandidates))

        // ...and it also expects to have at least one candidate.
        guard numCandidates > 0 else {
            return
        }

        var numLeafs = 0

        // Build out the first level of the tree.
        for key in keys {
            self.root.addChild(Node(label: key))
        }

        func buildLevel(level: [Node<T>]) {
            numLeafs = level.count

            var nextLevel = [Node<T>]()

            for node in level {
                for key in keys {
                    guard numLeafs < numCandidates else {
                        break
                    }

                    let child = Node<T>(label: key)
                    node.addChild(child)
                    nextLevel.append(child)

                    // Adding one child to an existing leaf doesn't increase the
                    // total number of leaves (the operation is net neutral).
                    if node.numChildren > 1 {
                        numLeafs += 1
                    }
                }

            }

            if numLeafs < numCandidates {
                buildLevel(level: nextLevel)
            }
        }

        buildLevel(level: self.root.children)

        assert(candidates.count == leaves.count)

        for (n, choice) in candidates.enumerated() {
            leaves[n].value = choice
        }
    }

    func walk(sequence: [Character]) -> Node<T>? {
        func traverse(from node: Node<T>, sequence: [Character]) -> Node<T>? {
            if sequence.isEmpty {
                return node.isLeaf ? node : nil
            }

            guard let character = sequence.first else {
                return nil
            }

            if let child = node.step(by: character) {
                return traverse(from: child, sequence: Array(sequence.dropFirst()))
            } else {
                return nil
            }
        }
        return traverse(from: self.root, sequence: sequence)
    }

}
