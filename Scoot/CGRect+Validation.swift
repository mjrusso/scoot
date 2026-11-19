import CoreGraphics

extension CGRect {
    var hasFiniteComponents: Bool {
        origin.x.isFinite &&
        origin.y.isFinite &&
        size.width.isFinite &&
        size.height.isFinite
    }

    var isUsableScreenFrame: Bool {
        hasFiniteComponents &&
        !isNull &&
        !isInfinite &&
        width > 1 &&
        height > 1
    }
}
