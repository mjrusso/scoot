import SwiftUI
import OSLog
import KeyboardShortcuts

struct SettingsView: View {

    private enum Tabs: Hashable {
        case keybindings
    }

    var body: some View {
        TabView {
            KeybindingsSettingsView()
                .tabItem {
                    Label("Keybindings", systemImage: "keyboard")
                }
                .tag(Tabs.keybindings)
        }
        .padding(20)
        .frame(width: 400, height: 220)
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
            }.onChange(of: keybindingMode) { newValue in
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
        .frame(width: 360, height: 160)
    }
}

struct KeybindingsSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        KeybindingsSettingsView()
    }
}
