import AppKit
import SwiftUI

// SettingsView owns persistence through @AppStorage. UserSettings accesses the
// AppDelegate's SettingsView, using computed properties for colors and wrapped
// properties for the other settings.

@MainActor
class UserSettings {

    struct Constants {

        struct Names {
            static let keybindingMode = "KeybindingMode"
            static let primaryColor = "PrimaryColor"
            static let secondaryColor = "SecondaryColor"
            static let showGridLines = "ShowGridLines"
            static let showGridLabels = "ShowGridLabels"
            static let targetGridCellSideLength = "TargetGridCellSideLength"
            static let gridViewOverallContrast = "GridViewOverallContrast"
            static let elementViewOverallContrast = "ElementViewOverallContrast"
            static let gridViewFontSize = "GridViewFontSize"
            static let elementViewFontSize = "ElementViewFontSize"
            static let roundElementLabelCorners = "RoundElementLabelCorners"
            static let elementLabelBorderOpacity = "ElementLabelBorderOpacity"
            static let elementLabelBackgroundOpacity = "ElementLabelBackgroundOpacity"
        }

        struct DefaultValues {
            static let keybindingMode = KeybindingMode.emacs
            static let primaryColor = Color("PrimaryColor")     // References a named color in Asset Bundle.
            static let secondaryColor = Color("SecondaryColor") // Ditto.
            static let showGridLines = true
            static let showGridLabels = true
            static let targetGridCellSideLength = Double(60)
            static let gridViewOverallContrast = Double(0)
            static let elementViewOverallContrast = Double(0)
            static let gridViewFontSize = Double(18)
            static let elementViewFontSize = Double(14)
            static let roundElementLabelCorners = false
            static let elementLabelBorderOpacity = Double(0)
            static let elementLabelBackgroundOpacity = Double(1)
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
            static let gridViewFontSize = Config(min: 10, max: 24, step: 2)
            static let elementViewFontSize = Config(min: 6, max: 22, step: 2)
            static let elementLabelBorderOpacity = Config(min: 0.0, max: 1.0, step: 0.1)
            static let elementLabelBackgroundOpacity = Config(min: 0.0, max: 1.0, step: 0.1)
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

    var primaryColor: NSColor {
        get {
            NSColor(settingsView?.primaryColor ?? Constants.DefaultValues.primaryColor)
        }
        set {
            settingsView?.primaryColor = Color(newValue)
        }
    }

    var secondaryColor: NSColor {
        get {
            NSColor(settingsView?.secondaryColor ?? Constants.DefaultValues.secondaryColor)
        }
        set {
            settingsView?.secondaryColor = Color(newValue)
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

    var roundElementLabelCorners: Bool {
        get {
            settingsView?.roundElementLabelCorners ?? Constants.DefaultValues.roundElementLabelCorners
        }
        set {
            settingsView?.roundElementLabelCorners = newValue
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

    var gridViewFontSize: Double {
        get {
            settingsView?.gridViewFontSize ?? Constants.DefaultValues.gridViewFontSize
        }
        set {
            settingsView?.gridViewFontSize = newValue
        }
    }

    var elementViewFontSize: Double {
        get {
            settingsView?.elementViewFontSize ?? Constants.DefaultValues.elementViewFontSize
        }
        set {
            settingsView?.elementViewFontSize = newValue
        }
    }

    var elementLabelBorderOpacity: Double {
        get {
            settingsView?.elementLabelBorderOpacity ?? Constants.DefaultValues.elementLabelBorderOpacity
        }
        set {
            settingsView?.elementLabelBorderOpacity = newValue
        }
    }

    var elementLabelBackgroundOpacity: Double {
        get {
            settingsView?.elementLabelBackgroundOpacity ?? Constants.DefaultValues.elementLabelBackgroundOpacity
        }
        set {
            settingsView?.elementLabelBackgroundOpacity = newValue
        }
    }

}
