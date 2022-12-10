import Cocoa
import Carbon.HIToolbox

// MARK: - Keyboard

extension KeyboardInputWindow {

    /// Returns true, if the character or keycode is specifically reserved for a keyboard shortcut.
    func isReserved(_ character: Character, or keycode: UInt16) -> Bool {
        let reservedCharacters: [Character] = ["\r", "[", "]", "=", "\\"]
        let reservedKeycodes: [Int] = [
            kVK_Return,
            kVK_Escape,
            kVK_UpArrow,
            kVK_DownArrow,
            kVK_LeftArrow,
            kVK_RightArrow
        ]
        return reservedCharacters.contains(character) ||
            reservedKeycodes.contains(Int(keycode))
    }

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(
            .deviceIndependentFlagsMask
        )

        guard let characters = event.charactersIgnoringModifiers else {
            return
        }

        let character = characters[characters.startIndex]

        let mode = UserSettings.shared.keybindingMode

        // Cancel, if user hits the escape key, or Control-G (Emacs: keyboard-quit).
        if event.keyCode == kVK_Escape || (modifiers, character) == (.control, "g") {
            cancelOperation(self)
            return
        }

        // FIXME: this logic would be better encoded as a state machine.

        if let tree = currentTree, modifiers.isEmpty && characters.count == 1 && !isReserved(character, or: event.keyCode) && !mode.isCharacterSpecial(character) {

            if let nextNode = (currentNode ?? tree.root).step(by: character) {
                if nextNode.isLeaf , let rect = nextNode.value {
                    mouse.move(to: CGPoint(x: rect.midX, y: rect.midY))
                    flashFeedback(at: rect, duration: 1.4)
                    currentNode = nil
                    return
                }
                self.currentNode = nextNode
            } else {
                // Provide visual feedback: an invalid key (not corresponding to
                // any valid sequence) was just typed by the user.
                flashFeedback(duration: 0.8)
            }
            return
        }

        switch (character, isHoldingDownLeftMouseButton, modifiers) {
        // Scoot is brought to the background before issuing any mouse-related
        // operation (like clicking). If the target window was focused ahead of
        // invoking Scoot, it will regain focus _before_ clicking, which
        // significantly improves reliability. For more context, see
        // <https://github.com/mjrusso/scoot/issues/28>.
        case ("\r", false, []):
            appDelegate?.bringToBackground()
            mouse.click(button: .left)
            return
        case ("\r", false, _), ("[", false, _), ("]", false, _):
            appDelegate?.bringToBackground()

            // Note that if a modifier is being held, it will "pass through" to
            // the corresponding click.
            switch character {
            case "\r":
                mouse.click(button: .left)
            case "[":
                mouse.click(button: .center)
            case "]":
                mouse.click(button: .right)
            default:
                break
            }
            return
        case ("\r", true, _):
            appDelegate?.bringToBackground()
            mouse.notifyDrag(.left)
            mouse.release(.left)
            isHoldingDownLeftMouseButton = false
            return
        case ("=", false, _):
            appDelegate?.bringToBackground()
            usleep(10000)
            mouse.pressDown(.left)
            isHoldingDownLeftMouseButton = true
            // Automatically bring Scoot to the foreground, so the user can
            // continue their drag operation.
            usleep(10000)
            appDelegate?.bringToForeground()
            return
        case ("\\", false, _):
            appDelegate?.bringToBackground()
            mouse.doubleClick(button: .left)
            return
        default:
            break
        }

        if modifiers.contains(.shift) {
            switch (mode, Int(event.keyCode), character) {
            case (_, kVK_UpArrow, _), (.emacs, _, "P"), (.vi, _, "B"):
                mouse.scroll(.up, stepSize: 20)
                return
            case (_, kVK_DownArrow, _), (.emacs, _, "N"), (.vi, _, "F"):
                mouse.scroll(.down, stepSize: 20)
                return
            case (_, kVK_LeftArrow, _), (.emacs, _, "B"), (.vi, _, "I"):
                mouse.scroll(.left, stepSize: 20)
                return
            case (_, kVK_RightArrow, _), (.emacs, _, "F"), (.vi, _, "A"):
                mouse.scroll(.right, stepSize: 20)
                return
            default:
                break
            }
        }

        // By default, we vend to the system directly (by calling `interpretKeyEvents`
        // with the input event). However, in some cases we need to override the
        // system behaviour: for example, Control-A maps to `moveToBeginningOfParagraph`,
        // but `moveToBeginningOfLine` is more appropriate here.

        switch (mode, modifiers, character) {

        case (.emacs, .control, "a"):
            // Emacs: move-beginning-of-line
            moveToBeginningOfLine(self)

        case (.emacs, .control, "e"):
            // Emacs: move-end-of-line
            moveToEndOfLine(self)

        case (.emacs, .option, "a"):
            // Emacs: backward-sentence
            moveToBeginningOfParagraph(self)

        case (.emacs, .option, "e"):
            // Emacs: forward-sentence
            moveToEndOfParagraph(self)

        case (.emacs, [.shift, .option], "<"):
            // Emacs: beginning-of-buffer
            moveToBeginningOfDocument(self)

        case (.emacs, [.shift, .option], ">"):
            // Emacs: end-of-buffer
            moveToEndOfDocument(self)

        case (.vi, [], "k"):
            moveUp(self)

        case (.vi, [], "j"):
            moveDown(self)

        case (.vi, [], "h"):
            moveLeft(self)

        case (.vi, [], "l"):
            moveRight(self)

        case (.vi, .control, "k"):
            moveToBeginningOfParagraph(self)

        case (.vi, .control, "j"):
            moveToEndOfParagraph(self)

        case (.vi, .control, "h"):
            moveWordLeft(self)

        case (.vi, .control, "l"):
            moveWordRight(self)

        case (.vi, .shift, "K"):
            moveToBeginningOfDocument(self)

        case (.vi, .shift, "J"):
            moveToEndOfDocument(self)

        case (.vi, .shift, "H"):
            moveToBeginningOfLine(self)

        case (.vi, .shift, "L"):
            moveToEndOfLine(self)

        case (.vi, .shift, "M"):
            centerSelectionInVisibleArea(self)

        // Allow the system to handle the event. We override methods in the
        // NSStandardKeyBindingResponding protocol, to enable many of the default
        // "document shortcuts" [0] that are built in to MacOS.
        //
        // [0]: https://support.apple.com/en-ca/HT201236
        default:
            interpretKeyEvents([event])
        }
    }

}
