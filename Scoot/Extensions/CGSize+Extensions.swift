import Foundation

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

extension CGSize: Comparable {

    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        (lhs.width < rhs.width) && (lhs.height < rhs.height)
    }

}
