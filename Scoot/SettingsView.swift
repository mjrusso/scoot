import SwiftUI
import OSLog
import KeyboardShortcuts

struct SettingsView: View {

    private enum Tabs: Hashable {
        case keybindings
        case presentation
    }

    var body: some View {
        TabView {
            PresentationSettingsView()
                .tabItem {
                    Label("Presentation", systemImage: "scribble.variable")
                }
                .tag(Tabs.presentation)
            KeybindingsSettingsView()
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
    @AppStorage(UserSettings.Constants.keybindingMode) private var keybindingMode = KeybindingMode.emacs

    var body: some View {
        Form {
            Picker("Keybinding Mode:", selection: $keybindingMode) {
                Text("Emacs/ MacOS").tag(KeybindingMode.emacs)
                Text("vi").tag(KeybindingMode.vi)
            }
            .onChange(of: keybindingMode) { newValue in
                UserSettings.shared.keybindingMode = newValue

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
        KeybindingsSettingsView()
    }
}

struct PresentationSettingsView: View {

    @AppStorage(UserSettings.Constants.showGridLines) private var showGridLines = true
    @AppStorage(UserSettings.Constants.showGridLabels) private var showGridLabels = true

    var body: some View {
        Form {
            Toggle("Show grid lines", isOn: $showGridLines)
            Toggle("Show grid labels", isOn: $showGridLabels)
        }
        .onChange(of: showGridLines) { newValue in
            UserSettings.shared.showGridLines = newValue
            (NSApp.delegate as? AppDelegate)?.inputWindow.redrawJumpViews()
            OSLog.main.log("Toggled showGridLines to \(showGridLines).")
        }
        .onChange(of: showGridLabels) { newValue in
            UserSettings.shared.showGridLabels = newValue
            (NSApp.delegate as? AppDelegate)?.inputWindow.redrawJumpViews()
            OSLog.main.log("Toggled showGridLabels to \(showGridLabels).")
        }
        .padding(20)
        .frame(width: 360)
    }
}

struct PresentationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PresentationSettingsView()
    }
}
