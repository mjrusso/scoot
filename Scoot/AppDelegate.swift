import Cocoa
import Carbon
import HotKey
import OSLog

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    var statusItem: NSStatusItem?

    @IBOutlet weak var hideMenuItem: NSMenuItem!

    @IBOutlet weak var useElementBasedNavigationMenuItem: NSMenuItem!

    @IBOutlet weak var useGridBasedNavigationMenuItem: NSMenuItem!

    @IBOutlet weak var useFreestyleNavigationMenuItem: NSMenuItem!

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

    public var useElementBasedNavigationHotKey: HotKey? {
        didSet {
            useElementBasedNavigationHotKey?.keyDownHandler = { [weak self] in
                self?.bringToForeground(using: .element)
            }
        }
    }

    public var useGridBasedNavigationHotKey: HotKey? {
        didSet {
            useGridBasedNavigationHotKey?.keyDownHandler = { [weak self] in
                self?.bringToForeground(using: .grid)
            }
        }
    }

    public var useFreestyleNavigationHotKey: HotKey? {
        didSet {
            useFreestyleNavigationHotKey?.keyDownHandler = { [weak self] in
                self?.bringToForeground(using: .freestyle)
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

        OSLog.main.log("Scoot: applicationDidFinishLaunching.")

        guard Accessibility.checkIfProcessIsTrusted(withPrompt: !isRunningTests) else {

            OSLog.main.log("Process is not trusted for AX.")

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
                    OSLog.main.log("Terminating because not trusted as an AX process.")
                    NSApp.terminate(self)
                }
            }
            return
        }

        self.useElementBasedNavigationHotKey = HotKey(key: .j, modifiers: [.command, .shift])

        self.useGridBasedNavigationHotKey = HotKey(key: .k, modifiers: [.command, .shift])

        self.useFreestyleNavigationHotKey = HotKey(key: .l, modifiers: [.command, .shift])

        self.configureMenuBarExtra()

        OSLog.main.log("For reference: the primary screen is at index 0, contains the menu bar, and has origin (0,0).")

        OSLog.main.logDetailsForAllConnectedScreens()

        for screen in NSScreen.screens {
            self.spawnJumpWindow(on: screen)
        }

        OSLog.main.logDetailsForAllJumpWindows()

        OSLog.main.log("Using \(UserSettings.shared.keybindingMode.rawValue, privacy: .public) keybindings.")

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

            OSLog.main.log("Scoot: received didChangeScreenParametersNotification.")

            OSLog.main.logDetailsForAllConnectedScreens()

            guard let self = self else {
                return
            }

            var mustReinitialize = false

            for windowController in self.jumpWindowControllers {
                guard let screen = windowController.assignedScreen,
                    NSScreen.screens.contains(screen),
                    let window = windowController.window
                else {
                    OSLog.main.log("> Screen has gone away: \(windowController.assignedScreen?.localizedName ?? "<unknown>", privacy: .private(mask: .hash))")
                    self.closeJumpWindow(managedBy: windowController)
                    mustReinitialize = true
                    continue
                }

                guard window.frame == screen.frame else {
                    OSLog.main.log("> Screen frame has changed: \(screen.localizedName, privacy: .private(mask: .hash)) \(String(describing: screen.frame), privacy: .public)")
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
                OSLog.main.log("> Screen was added: \(screen.localizedName, privacy: .private(mask: .hash)) \(String(describing: screen.frame), privacy: .public)")
                self.spawnJumpWindow(on: screen)
                mustReinitialize = true
            }

            OSLog.main.logDetailsForAllJumpWindows()

            if mustReinitialize {
                OSLog.main.log("Re-initializing relevant data structures...")
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
        item.button?.image = menuBarStatusItemOutlinedImage
        item.menu = menu
        self.statusItem = item
    }

    lazy var menuBarStatusItemFilledImage: NSImage? = {
        let image = NSImage(named: "MenuIcon-Filled")
        image?.size = NSSize(width: 18.0, height: 18.0)
        image?.isTemplate = true
        return image
    }()

    lazy var menuBarStatusItemOutlinedImage: NSImage? = {
        let image = NSImage(named: "MenuIcon-Outlined")
        image?.size = NSSize(width: 18.0, height: 18.0)
        image?.isTemplate = true
        return image
    }()

    func updateMenuBarStatusItemForInactiveState() {
        self.statusItem?.button?.image = menuBarStatusItemOutlinedImage
    }

    func updateMenuBarStatusItemForActiveState() {
        self.statusItem?.button?.image = menuBarStatusItemFilledImage
    }

    // MARK: Activation

    func bringToForeground() {
        self.currentApp = NSWorkspace.shared.frontmostApplication

        if let app = self.currentApp {
            OSLog.main.log("Scoot invoked with frontmost app: \(String(describing: app.localizedName ?? "<unknown>"), privacy: .private(mask: .hash))")
            self.inputWindow.initializeCoreDataStructuresForElementBasedMovement(of: app)
        }

        OSLog.main.log("Using \(String(describing: self.inputWindow.activeJumpMode), privacy: .public) jump mode")

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

    @IBAction func useElementBasedNavigationPressed(_ sender: NSMenuItem) {
        bringToForeground(using: .element)
    }

    @IBAction func useGridBasedNavigationPressed(_ sender: NSMenuItem) {
        bringToForeground(using: .grid)
    }

    @IBAction func useFreestyleNavigationPressed(_ sender: NSMenuItem) {
        bringToForeground(using: .freestyle)
    }

    @IBAction func aboutPressed(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(sender)
    }

    @IBAction func helpPressed(_ sender: NSMenuItem) {
        NSWorkspace.shared.open(URL(string: "https://github.com/mjrusso/scoot")!)
    }

    @IBAction func installationHelpRequested(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/mjrusso/scoot#installation")!)
    }

    // MARK: Debug Actions

    @IBAction func logScreenConfigurationAndUserInterfaceState(_ sender: NSMenuItem) {
        OSLog.main.log("Debug: logging screen configuration and UI state.")
        OSLog.main.logDetailsForAllConnectedScreens()
        OSLog.main.logDetailsForAllJumpWindows()
    }

    @IBAction func rebuildJumpWindows(_ sender: NSMenuItem) {
        OSLog.main.log("Debug: rebuilding all jump windows.")

        for windowController in jumpWindowControllers {
            closeJumpWindow(managedBy: windowController)
        }

        for screen in NSScreen.screens {
            spawnJumpWindow(on: screen)
        }

        inputWindow.initializeCoreDataStructuresForGridBasedMovement()

        bringToForeground()
    }

    @IBAction func toggleJumpWindowTint(_ sender: NSMenuItem) {
        OSLog.main.log("Debug: toggling tint of all jump windows.")

        jumpWindows.forEach {
            $0.backgroundColor = $0.backgroundColor == .clear ?
                .systemPurple.withAlphaComponent(0.3) :
                .clear
        }
    }

    // MARK: Testing

    var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

}
