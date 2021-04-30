import Cocoa

class ViewController: NSViewController {

    var grid: Grid?

    var mouse: Mouse?

    var window: NSWindow? {
        view.window
    }

    @IBOutlet var gridView: GridView!

    var isDisplayingGrid: Bool = false {
        didSet {
            gridView.redraw()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        gridView.viewController = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        guard let screen = NSScreen.main else {
            return
        }

        self.mouse = Mouse(screen: screen)

        self.grid = Grid(
            gridSize: screen.frame.size,
            targetStepSize: CGSize(width: 60.0, height: 60.0))

        isDisplayingGrid = true
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        window?.makeFirstResponder(self)
    }

}

// MARK: - Keyboard

extension ViewController {

    // By default, we vend to the system directly (by calling `interpretKeyEvents`
    // with the input event). However, in some cases we need to override the
    // system behaviour: for example, Control-A maps to `moveToBeginningOfParagraph`,
    // but `moveToBeginningOfLine` is more appropriate here.

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

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
            mouse?.move(to: .topLeft)

        case ([.shift, .option], ">"): // Emacs: end-of-buffer
            mouse?.move(to: .bottomRight)

        case (.command, "c"): // Click
            mouse?.click()
            NSApplication.shared.hide(self)

        case (.command, "d"): // Drag
            mouse?.drag(.right, distance: 200)
            NSApplication.shared.hide(self)

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

