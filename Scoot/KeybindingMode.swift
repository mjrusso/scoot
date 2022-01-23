import Foundation

enum KeybindingMode: String {

    // Emacs (and MacOS system) keybindings.
    case emacs

    // Vi-style keybindings.
    case vi

}

extension KeybindingMode {

    /// A list of special alphabetical characters (if any) that can conflict
    /// with the characters used to build sequences in the character-based
    /// decision tree.
    var specialAlphas: [Character] {
        switch self {
        case .vi:
            return ["j", "k", "h", "l"]
        default:
            return []
        }
    }

    /// Returns true, if the character may conflict with the set of characters
    /// available for building sequences in the character-based decision tree.
    func isCharacterSpecial(_ character: Character) -> Bool {
        self.specialAlphas.contains(character)
    }

}
