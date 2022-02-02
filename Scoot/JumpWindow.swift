import Cocoa

class JumpWindow: TransparentWindow {

    override func awakeFromNib() {
        super.awakeFromNib()

        level = .floating
    }

}
