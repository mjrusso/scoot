import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    public var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                return
            }

            hotKey.keyDownHandler = { [weak self] in
                guard let self = self else {
                    return
                }

                NSApplication.shared.orderedWindows
                  .filter {
                      $0 is Window
                  }
                  .forEach {
                      NSApplication.shared.activate(ignoringOtherApps: true)
                      $0.makeKeyAndOrderFront(self)
                      $0.makeKey()
                  }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.hotKey = HotKey(key: .j, modifiers: [.command, .shift])
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

}
