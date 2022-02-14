import AppKit


// FIXME: To avoid duplicating code for reading/writing persisted state, code
// in this class directly accesses @AppStorage-wrapped properties in
// SettingsView. Architecturally, this is an odd (wrong!?) choice, however it's
// the only thing I could actually get working.
//
// I've tried duplicating @AppStorage declarations (here and in the appropriate
// SwiftUI view), however that didn't always work reliably: sometimes an
// @AppStorage-wrapped property would have a stale value when the other
// changed.
//
// I've also tried importing SwiftUI in this file, declaring all of the
// @AppStorage properties here, and then using them as a @Binding from SwiftUI,
// however that also led to incorrect behaviour: for example, toggling a
// checkbox in the SwiftUI view would change the underlying value, but not
// update the actual SwiftUI-managed UI. It's unclear if I'm doing something
// wrong, or if this use case is deliberately unsupported, or if this is some
// sort of SwiftUI bug.
//
// In any event, this (hacky) workaround seems to work...
//
// For posterity, a potential solution approach is described at
// https://developer.apple.com/forums/thread/658569?answerId=700948022#700948022,
// however there is no code sample, and I've been unable to get the described
// approach to work.

class UserSettings {

    struct Constants {

        struct Names {
            static let keybindingMode = "KeybindingMode"
            static let showGridLines = "ShowGridLines"
            static let showGridLabels = "ShowGridLabels"
            static let targetGridCellSideLength = "TargetGridCellSideLength"
            static let gridViewOverallContrast = "GridViewOverallContrast"
            static let elementViewOverallContrast = "ElementViewOverallContrast"
        }

        struct DefaultValues {
            static let keybindingMode = KeybindingMode.emacs
            static let showGridLines = true
            static let showGridLabels = true
            static let targetGridCellSideLength = Double(60)
            static let gridViewOverallContrast = Double(0)
            static let elementViewOverallContrast = Double(0)
        }

        struct Sliders {

            struct Config {
                let min: Double
                let max: Double
                let step: Double

                var range: ClosedRange<Double> {
                    min...max
                }
            }

            static let targetGridCellSideLength = Config(min: 40, max: 80, step: 10)
            static let gridViewOverallContrast = Config(min: -0.4, max: 0.5, step: 0.1)
            static let elementViewOverallContrast = Config(min: -0.4, max: 0.5, step: 0.1)
        }

    }

    static let shared = UserSettings()

    var settingsView: SettingsView? {
        (NSApp.delegate as? AppDelegate)?.settingsView
    }

    var keybindingMode: KeybindingMode {
        get {
            settingsView?.keybindingMode ?? Constants.DefaultValues.keybindingMode
        }
        set {
            settingsView?.keybindingMode = newValue
        }
    }

    var showGridLines: Bool {
        get {
            settingsView?.showGridLines ?? Constants.DefaultValues.showGridLines
        }
        set {
            settingsView?.showGridLines = newValue
        }
    }

    var showGridLabels: Bool {
        get {
            settingsView?.showGridLabels ?? Constants.DefaultValues.showGridLabels
        }
        set {
            settingsView?.showGridLabels = newValue
        }
    }

    var targetGridCellSideLength: Double {
        get {
            settingsView?.targetGridCellSideLength ?? Constants.DefaultValues.targetGridCellSideLength
        }
        set {
            settingsView?.targetGridCellSideLength = newValue
        }
    }

    var gridViewOverallContrast: Double {
        get {
            settingsView?.gridViewOverallContrast ?? Constants.DefaultValues.gridViewOverallContrast
        }
        set {
            settingsView?.gridViewOverallContrast = newValue
        }
    }

    var elementViewOverallContrast: Double {
        get {
            settingsView?.elementViewOverallContrast ?? Constants.DefaultValues.elementViewOverallContrast
        }
        set {
            settingsView?.elementViewOverallContrast = newValue
        }
    }

}
