import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var windows: [Window] {
        NSApplication.shared.orderedWindows
            .compactMap {
                $0 as? Window
            }
    }

    public var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                return
            }

            hotKey.keyDownHandler = { [weak self] in
                guard let self = self else {
                    return
                }

                NSApp.activate(ignoringOtherApps: true)

                self.windows.forEach { window in
                    window.makeKeyAndOrderFront(self)
                    window.makeKey()
                }
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.hotKey = HotKey(key: .j, modifiers: [.command, .shift])
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    // MARK: Actions

    @IBAction func hidePressed(_ sender: NSMenuItem) {
        NSApp.hide(self)
    }

    @IBAction func helpPressed(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/mjrusso/scoot")!)
    }

}
