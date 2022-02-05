import Foundation

// IMPORTANT / FIXME: There is some duplication between the settings encoded
// here, and in the SwiftUI settings views. It's unclear how to properly access
// values wrapped with @AppStorage from outside of SwiftUI views. See the
// discussion at https://developer.apple.com/forums/thread/658569 for more
// context. For now, make sure to use the same identifier (see
// UserSettings.Constants) with both @UserPersistedProperty and @AppStorage,
// and be sure to set them to the same default value.

class UserSettings {

    struct Constants {
        static let keybindingMode = "KeybindingMode"
    }

    static let shared = UserSettings()

    @UserPersistedProperty(Constants.keybindingMode, defaultValue: .emacs)
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
