import Cocoa

/*

 Implementation of methods in the `NSStandardKeyBindingResponding` protocol.

 Overriding these methods enables this app to support the system default
 keybindings (including Emacs keybindings). Of course, we're mapping shortcuts
 for document movement [0] to a 2d grid, so some liberties have been taken,
 however the (goal) is for the keybinds to be as intuitive as possible.

 From [1]:

 > Cool tricks with Key Bindings:
 >
 > - `defaults write -g NSRepeatCountBinding -string "^u"`
 >
 > Then:
 >
 > - In your `override func keyDown(with event: NSEvent)`, for any standard
 >   functionality, call `interpretKeyEvents[event])`
 >
 > - For basic moving/editing, have your `NSView` implement methods from
 >   `NSStandardKeyBindingResponding` (pre-10.14: `NSResponder`).
 >
 > Your view now supports whatever keybindings the user wishes! Including, by
 > default, Emacs-style.

 Also see: [2], [3].

 [0]: https://support.apple.com/en-ca/HT201236
 [1]: https://github.com/kengruven/guide/wiki/NSStandardKeyBindingResponding
 [2]: https://brettterpstra.com/2011/12/04/quick-tip-repeat-cocoa-text-actions-emacsvim-style/
 [3]: https://www.masteringemacs.org/article/effective-editing-movement

 */

extension KeyboardInputWindow {

    override func cancelOperation(_ sender: Any?) {
        defer {
            currentNode = nil
            isHoldingDownMouseButton = false
        }

        if isWalkingDecisionTree {
            flashFeedback(duration: 0.4)
        } else {
            appDelegate?.bringToBackground()
        }
    }

    override func moveLeft(_ sender: Any?) {
        mouse.move(.left, stepSize: stepWidth)
    }

    override func moveRight(_ sender: Any?) {
        mouse.move(.right, stepSize: stepWidth)
    }

    override func moveWordLeft(_ sender: Any?) {
        mouse.move(.left, stepSize: stepWidth, stepMultiple: numStepsPerCell)
    }

    override func moveWordRight(_ sender: Any?) {
        mouse.move(.right, stepSize: stepWidth, stepMultiple: numStepsPerCell)
    }

    override func moveToBeginningOfLine(_ sender: Any?) {
        mouse.move(to: .leftEdge)
    }

    override func moveToEndOfLine(_ sender: Any?) {
        mouse.move(to: .rightEdge)
    }

    override func moveUp(_ sender: Any?) {
        mouse.move(.up, stepSize: stepHeight)
    }

    override func moveDown(_ sender: Any?) {
        mouse.move(.down, stepSize: stepHeight)
    }

    override func moveToBeginningOfParagraph(_ sender: Any?) {
        mouse.move(.up, stepSize: stepHeight, stepMultiple: numStepsPerCell)
    }

    override func moveToEndOfParagraph(_ sender: Any?) {
        mouse.move(.down, stepSize: stepHeight, stepMultiple: numStepsPerCell)
    }

    override func scrollPageUp(_ sender: Any?) {
        mouse.move(.up, stepSize: stepHeight, stepMultiple: numStepsPerCell)
    }

    override func scrollPageDown(_ sender: Any?) {
        mouse.move(.down, stepSize: stepHeight, stepMultiple: numStepsPerCell)
    }

    override func moveToBeginningOfDocument(_ sender: Any?) {
        mouse.move(to: .topEdge)
    }

    override func moveToEndOfDocument(_ sender: Any?) {
        mouse.move(to: .bottomEdge)
    }

    override func centerSelectionInVisibleArea(_ sender: Any?) {
        // Mimic recenter-top-bottom behavior in Emacs.
        mouse.cycle()
    }

}
