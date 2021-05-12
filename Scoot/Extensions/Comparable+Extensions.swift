import Foundation

/// Clamps a comparable type between a minimum and maximum value.
public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
    min(max(value, minValue), maxValue)
}
