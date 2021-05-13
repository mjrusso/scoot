import Cocoa
import Carbon.HIToolbox

// MARK: - Keyboard

extension ViewController {

    override func keyDown(with event: NSEvent) {
        let modifiers = event.modifierFlags.intersection(
            .deviceIndependentFlagsMask
        )

        guard let characters = event.charactersIgnoringModifiers else {
            return
        }

        // Cancel, if user hits the escape key, or Control-G (Emacs: keyboard-quit).
        if event.keyCode == kVK_Escape || (modifiers, characters) == (.control, "g") {
            cancelOperation(self)
            return
        }

        // FIXME: this logic would be better encoded as a state machine.

        if modifiers.isEmpty && characters.count == 1 {
            let character = characters[characters.startIndex]

            if let nextNode = (currentNode ?? tree.root).step(by: character) {
                if nextNode.isLeaf , let rect = nextNode.value {
                    mouse.move(to: CGPoint(x: rect.midX, y: rect.midY))
                    currentNode = nil
                    return
                }
                self.currentNode = nextNode
            }
        }

        if isWalkingDecisionTree {
            // Ignore all other keypresses while we're walking the decision tree.
            return
        }

        if event.keyCode == kVK_Return {
            switch (isHoldingDownMouseButton, modifiers) {
            case (false, []):
                mouse.click()
            case (false, .command):
                mouse.pressDown()
                isHoldingDownMouseButton = true
            case (false, .shift):
                mouse.doubleClick()
            case (true, _):
                mouse.notifyDrag()
                mouse.release()
                isHoldingDownMouseButton = false
            default:
                break
            }
            return
        }

        // By default, we vend to the system directly (by calling `interpretKeyEvents`
        // with the input event). However, in some cases we need to override the
        // system behaviour: for example, Control-A maps to `moveToBeginningOfParagraph`,
        // but `moveToBeginningOfLine` is more appropriate here.

        switch (modifiers, characters) {

        case (.control, "a"): // Emacs: move-beginning-of-line
            moveToBeginningOfLine(self)

        case (.control, "e"): // Emacs: move-end-of-line
            moveToEndOfLine(self)

        case (.option, "a"): // Emacs: backward-sentence
            moveToBeginningOfParagraph(self)

        case (.option, "e"): // Emacs: forward-sentence
            moveToEndOfParagraph(self)

        case ([.shift, .option], "<"): // Emacs: beginning-of-buffer
            moveToBeginningOfDocument(self)

        case ([.shift, .option], ">"): // Emacs: end-of-buffer
            moveToEndOfDocument(self)

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
