import Cocoa

class FeedbackView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    func commonInit() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.systemPurple.withAlphaComponent(0.4).cgColor

        self.isHidden = true
    }

    func flash(duration: TimeInterval = 0.15) {
        self.isHidden = false
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            self.animator().alphaValue = 0
        } completionHandler: {
            self.isHidden = true
            self.alphaValue = 1
        }
    }

}
