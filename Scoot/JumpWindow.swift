import Cocoa

class JumpWindow: TransparentWindow {

    override func configureWindow() {
        super.configureWindow()

        level = .floating
    }

}
