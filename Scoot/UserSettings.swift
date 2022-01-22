import Foundation

class UserSettings {
    static let shared = UserSettings()

    @UserPersistedProperty("KeybindingMode", defaultValue: .emacs)
    var keybindingMode: KeybindingMode
}

/// A property wrapper to simplify reading and writing from UserDefaults.
///
/// Adapted from: https://stackoverflow.com/a/63752463
@propertyWrapper
struct UserPersistedProperty<T: RawRepresentable> {

    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) else {
                return defaultValue
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }

}
