import SwiftUI
import OSLog
import KeyboardShortcuts

struct SettingsView: View {

    // MARK: Persisted Application State

    // IMPORTANT: these @AppStorage-wrapped properties are deliberately not
    // marked as private. See `UserSettings` for details.

    @AppStorage(UserSettings.Constants.Names.keybindingMode)
    var keybindingMode = UserSettings.Constants.DefaultValues.keybindingMode

    @AppStorage(UserSettings.Constants.Names.showGridLines)
    var showGridLines = UserSettings.Constants.DefaultValues.showGridLines

    @AppStorage(UserSettings.Constants.Names.showGridLabels)
    var showGridLabels = UserSettings.Constants.DefaultValues.showGridLabels

    @AppStorage(UserSettings.Constants.Names.targetGridCellSideLength)
    var targetGridCellSideLength = UserSettings.Constants.DefaultValues.targetGridCellSideLength

    @AppStorage(UserSettings.Constants.Names.gridViewOverallContrast)
    var gridViewOverallContrast = UserSettings.Constants.DefaultValues.gridViewOverallContrast

    @AppStorage(UserSettings.Constants.Names.elementViewOverallContrast)
    var elementViewOverallContrast = UserSettings.Constants.DefaultValues.elementViewOverallContrast

    // MARK: User Interface

    private enum Tabs: Hashable {
        case keybindings
        case presentation
    }

    var body: some View {
        TabView {
            PresentationSettingsView(
                showGridLines: $showGridLines,
                showGridLabels: $showGridLabels,
                targetGridCellSideLength: $targetGridCellSideLength,
                gridViewOverallContrast: $gridViewOverallContrast,
                elementViewOverallContrast: $elementViewOverallContrast
                ).tabItem {
                    Label("Presentation", systemImage: "scribble.variable")
                }
                .tag(Tabs.presentation)
            KeybindingsSettingsView(keybindingMode: $keybindingMode)
                .tabItem {
                    Label("Keybindings", systemImage: "keyboard")
                }
                .tag(Tabs.keybindings)
        }
        .padding(20)
        .frame(width: 400)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct KeybindingsSettingsView: View {

    @Binding var keybindingMode: KeybindingMode

    var body: some View {
        Form {
            Picker("Keybinding Mode:", selection: $keybindingMode) {
                Text("Emacs/ MacOS").tag(KeybindingMode.emacs)
                Text("vi").tag(KeybindingMode.vi)
            }
            .onChange(of: keybindingMode) { newValue in
                // Reset the grid, because changing the keybinding mode affects
                // which characters are available to the character-based
                // decision tree.
                (NSApp.delegate as? AppDelegate)?.inputWindow.initializeCoreDataStructuresForGridBasedMovement()

                OSLog.main.log("Now using \(keybindingMode.rawValue, privacy: .public) keybindings.")
            }
            KeyboardShortcuts.Recorder(for: .useElementBasedNavigation).formLabel(Text("Element-Based Navigation:"))
            KeyboardShortcuts.Recorder(for: .useGridBasedNavigation).formLabel(Text("Grid-Based Navigation:"))
            KeyboardShortcuts.Recorder(for: .useFreestyleNavigation).formLabel(Text("Freestyle Navigation:"))
        }
        .padding(20)
        .frame(width: 360)
    }
}

struct KeybindingsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        KeybindingsSettingsView(keybindingMode: .constant(.emacs))
    }
}

struct PresentationSettingsView: View {

    @Binding var showGridLines: Bool
    @Binding var showGridLabels: Bool
    @Binding var targetGridCellSideLength: Double
    @Binding var gridViewOverallContrast: Double
    @Binding var elementViewOverallContrast: Double

    let targetGridCellSideLengthConfig = UserSettings.Constants.Sliders.targetGridCellSideLength
    let gridViewOverallContrastConfig = UserSettings.Constants.Sliders.gridViewOverallContrast
    let elementViewOverallContrastConfig = UserSettings.Constants.Sliders.elementViewOverallContrast

    var body: some View {
        Form {
            Toggle("Show grid lines", isOn: $showGridLines)
            Toggle("Show grid labels", isOn: $showGridLabels)
            Slider(value: $targetGridCellSideLength, in: targetGridCellSideLengthConfig.range, step: targetGridCellSideLengthConfig.step) {
                Label("Grid Cell Size:", systemImage: "gear")
            }
            .labelStyle(TitleOnlyLabelStyle())
            Slider(value: $gridViewOverallContrast, in: gridViewOverallContrastConfig.range, step: gridViewOverallContrastConfig.step) {
                Label("Grid Contrast:", systemImage: "gear")
            }
            .labelStyle(TitleOnlyLabelStyle())
            Slider(value: $elementViewOverallContrast, in: elementViewOverallContrastConfig.range, step: elementViewOverallContrastConfig.step) {
                Label("Element Contrast:", systemImage: "gear")
            }
            .labelStyle(TitleOnlyLabelStyle())

        }
        .onChange(of: showGridLines) { newValue in
            OSLog.main.log("Toggled showGridLines to \(showGridLines).")
            (NSApp.delegate as? AppDelegate)?.inputWindow.redrawJumpViews()
        }
        .onChange(of: showGridLabels) { newValue in
            OSLog.main.log("Toggled showGridLabels to \(showGridLabels).")
            (NSApp.delegate as? AppDelegate)?.inputWindow.redrawJumpViews()
        }
        .onChange(of: targetGridCellSideLength) { newValue in
            OSLog.main.log("Changed targetGridCellSideLength to \(targetGridCellSideLength).")
            (NSApp.delegate as? AppDelegate)?.inputWindow.initializeCoreDataStructuresForGridBasedMovement()
            (NSApp.delegate as? AppDelegate)?.inputWindow.redrawJumpViews()
        }
        .onChange(of: gridViewOverallContrast) { [gridViewOverallContrast] newValue in
            OSLog.main.log("Changed gridViewOverallContrast to \(newValue) from \(gridViewOverallContrast).")
            (NSApp.delegate as? AppDelegate)?.inputWindow.updateGridViewContrast()
        }
        .onChange(of: elementViewOverallContrast) { [elementViewOverallContrast] newValue in
            OSLog.main.log("Changed elementViewOverallContrast to \(newValue) from \(elementViewOverallContrast).")
            (NSApp.delegate as? AppDelegate)?.inputWindow.updateElementViewContrast()
        }
        .padding(20)
        .frame(width: 360)
    }
}

struct PresentationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationSettingsView(
            showGridLines: .constant(false),
            showGridLabels: .constant(true),
            targetGridCellSideLength: .constant(60),
            gridViewOverallContrast: .constant(0.0),
            elementViewOverallContrast: .constant(0.0)
        )
    }
}
