import Cocoa
import Carbon
import HotKey
import OSLog

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    var statusItem: NSStatusItem?

    @IBOutlet weak var hideMenuItem: NSMenuItem!

    @IBOutlet weak var showElementsMenuItem: NSMenuItem!

    @IBOutlet weak var showGridMenuItem: NSMenuItem!

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

    public var showElementsHotKey: HotKey? {
        didSet {
            showElementsHotKey?.keyDownHandler = { [weak self] in
                self?.bringToForeground(using: .element)
            }
        }
    }

    public var showGridHotKey: HotKey? {
        didSet {
            showGridHotKey?.keyDownHandler = { [weak self] in
                self?.bringToForeground(using: .grid)
            }
        }
    }

    /// The frontmost application at the moment when Scoot was most recently
    /// invoked. (If Scoot happens to be the frontmost app when it is invoked,
    /// the previous frontmost app is returned.)
    var currentApp: NSRunningApplication? {
        didSet {
            // Don't allow Scoot to be set as the current app; instead, retain
            // the previous value. (This behaviour provides a simple mechanism
            // for recomputing available elements when using element-based
            // navigation: simply re-invoke Scoot, even if it is frontmost.)
            guard currentApp != .current else {
                currentApp = oldValue
                return
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
                    Logger().log("Terminating because not trusted as an AX process.")
                    NSApp.terminate(self)
                }
            }
            return
        }

        self.showElementsHotKey = HotKey(key: .j, modifiers: [.command, .shift])

        self.showGridHotKey = HotKey(key: .k, modifiers: [.command, .shift])

        self.configureMenuBarExtra()

        Logger().log("Lauching Scoot (connected screens: \(NSScreen.screens.count))")

        for screen in NSScreen.screens {
            self.spawnJumpWindow(on: screen)
            Logger().log("* Screen: \(screen.localizedName) \(String(describing: screen.frame))")
        }

        self.inputWindow.initializeCoreDataStructuresForGridBasedMovement()

        self.initializeChangeScreenParametersObserver()

        self.bringToForeground(using: .element)
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

            Logger().log("Received didChangeScreenParametersNotification (connected screens: \(NSScreen.screens.count))")
            for screen in NSScreen.screens {
                Logger().log("* Screen: \(screen.localizedName) \(String(describing: screen.frame))")
            }

            guard let self = self else {
                return
            }

            var mustReinitialize = false

            for windowController in self.jumpWindowControllers {
                guard let screen = windowController.assignedScreen,
                    NSScreen.screens.contains(screen),
                    let window = windowController.window
                else {
                    Logger().log("> Screen has gone away: \(windowController.assignedScreen?.localizedName ?? "<unknown>")")
                    self.closeJumpWindow(managedBy: windowController)
                    mustReinitialize = true
                    continue
                }

                guard window.frame == screen.frame else {
                    Logger().log("> Screen frame has changed: \(screen.localizedName) \(String(describing: screen.frame))")
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
                Logger().log("> Screen was added: \(screen.localizedName) \(String(describing: screen.frame))")
                self.spawnJumpWindow(on: screen)
                mustReinitialize = true
            }

            if mustReinitialize {
                Logger().log("Re-initializing relevant data structures...")
                self.inputWindow.initializeCoreDataStructuresForGridBasedMovement()
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
        self.currentApp = NSWorkspace.shared.frontmostApplication

        if let app = self.currentApp {
            Logger().log("Scoot invoked with frontmost app: \(String(describing: app.localizedName ?? "<unknown>"))")
            self.inputWindow.initializeCoreDataStructuresForElementBasedMovement(of: app)
        }

        self.inputWindow.showAppropriateJumpView()

        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async {
            self.jumpWindows.forEach { window in
                window.orderFront(self)
            }
            self.inputWindow.makeMain()
            self.inputWindow.makeKeyAndOrderFront(self)
        }
    }

    func bringToForeground(using jumpMode: JumpMode) {
        inputWindow.activeJumpMode = jumpMode
        bringToForeground()
    }

    // MARK: Deactivation

    func bringToBackground() {
        NSApp.hide(self)
    }

    // MARK: Actions

    @IBAction func hidePressed(_ sender: NSMenuItem) {
        bringToBackground()
    }

    @IBAction func showElementsPressed(_ sender: NSMenuItem) {
        bringToForeground(using: .element)
    }

    @IBAction func showGridPressed(_ sender: NSMenuItem) {
        bringToForeground(using: .grid)
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
