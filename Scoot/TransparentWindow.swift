import Cocoa

class TransparentWindow: NSWindow {

    final override func awakeFromNib() {
        super.awakeFromNib()

        // These windows are loaded from AppKit storyboards on the main thread.
        MainActor.assumeIsolated {
            configureWindow()
        }
    }

    @MainActor
    func configureWindow() {
        backgroundColor = NSColor.clear

        isOpaque = false
        isMovable = false
        ignoresMouseEvents = true

        styleMask = .borderless
        collectionBehavior = [
            // The window exists on all Spaces simultaneously.
            // This prevents the OS (or tiling window managers) from forcefully
            // moving the window to the current display on activation.
            .canJoinAllSpaces,

            .fullScreenAuxiliary,
            // The window floats in Spaces and hides in Exposé.
            .transient,
        ]
    }
    
    // Overrides tell Macos to handle keyboard events despite window being borderless
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return true
    }

}
