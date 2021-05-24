import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    var statusItem: NSStatusItem?

    @IBOutlet weak var hideMenuItem: NSMenuItem!

    @IBOutlet weak var showMenuItem: NSMenuItem!

    var windows: [Window] {
        NSApp.orderedWindows.compactMap { $0 as? Window }
    }

    public var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                return
            }

            hotKey.keyDownHandler = { [weak self] in
                self?.bringToForeground()
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.hotKey = HotKey(key: .j, modifiers: [.command, .shift])
        self.configureMenuBarExtra()
        self.bringToForeground()
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    // MARK: Menu Bar

    func configureMenuBarExtra() {
        let item = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.squareLength
        )

        let image = NSImage(named: "MenuIcon")
        image?.isTemplate = true

        item.button?.image = image
        item.button?.image?.size = NSSize(width: 18.0, height: 18.0)

        item.menu = menu

        self.statusItem = item
    }

    // MARK: Activation

    func bringToForeground() {
        NSApp.activate(ignoringOtherApps: true)

        self.windows.forEach { window in
            window.makeKeyAndOrderFront(self)
            window.makeKey()
        }
    }

    // MARK: Deactivation

    func bringToBackground() {
        NSApp.hide(self)
    }

    // MARK: Actions

    @IBAction func hidePressed(_ sender: NSMenuItem) {
        bringToBackground()
    }

    @IBAction func showPressed(_ sender: NSMenuItem) {
        bringToForeground()
    }

    @IBAction func helpPressed(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/mjrusso/scoot")!)
    }

}
