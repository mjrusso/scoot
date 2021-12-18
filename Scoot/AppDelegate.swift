import Cocoa
import Carbon
import HotKey

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    var statusItem: NSStatusItem?

    @IBOutlet weak var hideMenuItem: NSMenuItem!

    @IBOutlet weak var showMenuItem: NSMenuItem!

    lazy var inputWindow: KeyboardInputWindow = {
        NSApp.orderedWindows.compactMap({ $0 as? KeyboardInputWindow }).first!
    }()

    var jumpWindowControllers = [JumpWindowController]()

    var jumpWindows: [JumpWindow] {
        jumpWindowControllers.compactMap { $0.window as? JumpWindow }
    }

    var jumpViewControllers: [JumpViewController] {
        jumpWindowControllers.compactMap { $0.contentViewController as? JumpViewController }
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

        guard Accessibility.checkIfProcessIsTrusted(withPrompt: !isRunningTests) else {
            func showAlert(completion: (Bool) -> Void) {
                let alert = NSAlert()
                alert.messageText = "Accessibility Permission Required"
                alert.informativeText = "Please re-launch Scoot after authorizing."
                alert.alertStyle = .critical
                alert.addButton(withTitle: "View Documentation")
                alert.addButton(withTitle: "Exit")
                completion(alert.runModal() == .alertFirstButtonReturn)
            }

            showAlert { viewDocumentation in
                if viewDocumentation {
                    self.installationHelpRequested(self)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    print("Terminating because not trusted as an AX process.")
                    NSApp.terminate(self)
                }
            }
            return
        }

        self.hotKey = HotKey(key: .j, modifiers: [.command, .shift])

        self.configureMenuBarExtra()

        for screen in NSScreen.screens {
            self.spawnJumpWindow(on: screen)
        }

        self.inputWindow.initializeCoreDataStructures()

        self.initializeChangeScreenParametersObserver()

        self.bringToForeground()
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    // MARK: Handling Screen Changes

    func spawnJumpWindow(on screen: NSScreen) {
        let controller = JumpWindowController.spawn(on: screen)
        jumpWindowControllers.append(controller)
    }

    func resizeJumpWindow(managedBy controller: JumpWindowController, to size: NSRect) {
        controller.setWindowFrame(size)
    }

    func closeJumpWindow(managedBy controller: JumpWindowController) {
        controller.close()
        jumpWindowControllers.removeAll(where: {
            $0 == controller
        })
    }

    func initializeChangeScreenParametersObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main
        ) { [weak self] notification in

            guard let self = self else {
                return
            }

            var mustReinitialize = false

            for windowController in self.jumpWindowControllers {
                guard let screen = windowController.assignedScreen,
                    NSScreen.screens.contains(screen),
                    let window = windowController.window
                else {
                    self.closeJumpWindow(managedBy: windowController)
                    mustReinitialize = true
                    continue
                }

                guard window.frame == screen.frame else {
                    // Resize the window: screen dimensions have changed.
                    self.resizeJumpWindow(managedBy: windowController, to: screen.visibleFrame)
                    mustReinitialize = true
                    continue
                }
            }

            let assignedScreens = self.jumpWindowControllers.compactMap {
                $0.assignedScreen
            }

            let addedScreens = Set(NSScreen.screens).subtracting(assignedScreens)

            for screen in addedScreens {
                self.spawnJumpWindow(on: screen)
                mustReinitialize = true
            }

            if mustReinitialize {
                self.inputWindow.initializeCoreDataStructures()
            }
        }
    }

    // MARK: Convenience

    func jumpWindowController(for screen: NSScreen) -> JumpWindowController? {
        self.jumpWindowControllers.first(where: {
            $0.assignedScreen == screen
        })
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

        DispatchQueue.main.async {
            self.jumpWindows.forEach { window in
                window.orderFront(self)
            }
            self.inputWindow.makeMain()
            self.inputWindow.makeKeyAndOrderFront(self)
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

    @IBAction func installationHelpRequested(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/mjrusso/scoot#installation")!)
    }

    // MARK: Testing

    var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

}
