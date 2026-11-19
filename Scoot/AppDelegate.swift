import Cocoa
import Carbon
import OSLog
import SwiftUI

@main
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!

    var statusItem: NSStatusItem?

    var isProcessTrustedForAccessibilityAccess = false

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

        OSLog.main.log("Scoot: applicationDidFinishLaunching")

        #if DEBUG
        guard !isRunningTests && !isRunningSwiftUIPreviews else {
            return
        }
        #endif

        #if !DEBUG
        guard Accessibility.checkIfProcessIsTrusted(withPrompt: true) else {

            OSLog.main.log("Process is not trusted for AX.")

            func showAlert(completion: (Bool) -> Void) {
                let alert = NSAlert()
                alert.messageText = "Allow Scoot to Control Your Mac"
                alert.informativeText = "Grant access in your Mac’s privacy settings, then relaunch Scoot."
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
        isProcessTrustedForAccessibilityAccess = true
        #else
        if !Accessibility.checkIfProcessIsTrusted(withPrompt: false) {
            OSLog.main.warning("Process is **not** trusted for AX; some features will not work!")
        } else {
            isProcessTrustedForAccessibilityAccess = true
        }
        #endif

        Accessibility.enableEnhancedUserInterfaceForAllApps()

        GlobalKeybindings.synchronizeMenuBarItemsWithGlobalKeyboardShortcuts()
        GlobalKeybindings.registerGlobalKeyboardShortcuts()

        self.configureMenuBarExtra()

        OSLog.main.logDetailsForAllConnectedScreens()

        for screen in NSScreen.screens {
            self.spawnJumpWindow(on: screen)
        }

        OSLog.main.logDetailsForAllJumpWindows()

        OSLog.main.log("Using \(UserSettings.shared.keybindingMode.rawValue, privacy: .public) keybindings.")

        self.inputWindow.initializeCoreDataStructuresForGridBasedMovement()

        self.initializeChangeScreenParametersObserver()

        #if DEBUG
        self.bringToForeground(using: .element)
        #endif
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        #if DEBUG
        OSLog.main.log("Scoot: applicationWillTerminate")
        #endif

        // FIXME: Only remove `AXEnhancedUserInterface` attributes that Scoot
        // itself was responsible for adding.
        Accessibility.disableEnhancedUserInterfaceForAllApps()
    }

    func applicationWillBecomeActive(_ notification: Notification) {
        #if DEBUG
        OSLog.main.debug("AppDelegate: applicationWillBecomeActive")
        #endif
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        #if DEBUG
        OSLog.main.debug("AppDelegate: applicationDidBecomeActive")
        #endif
    }

    func applicationWillResignActive(_ notification: Notification) {
        #if DEBUG
        OSLog.main.debug("AppDelegate: applicationWillResignActive")
        #endif
    }

    // MARK: Handling Screen Changes

    func spawnJumpWindow(on screen: NSScreen) {
        let controller = JumpWindowController.spawn(on: screen)
        jumpWindowControllers.append(controller)
    }

    func closeJumpWindow(managedBy controller: JumpWindowController) {
        controller.close()
        jumpWindowControllers.removeAll(where: {
            $0 == controller
        })
    }

    func rebuildJumpWindows() {
        OSLog.main.log("Closing existing jump windows.")

        for windowController in jumpWindowControllers {
            closeJumpWindow(managedBy: windowController)
        }

        OSLog.main.log("Spawning new jump windows.")

        for screen in NSScreen.screens {
            spawnJumpWindow(on: screen)
        }

        OSLog.main.log("Finished spawning; logging updated state.")
        OSLog.main.logDetailsForAllJumpWindows()

        inputWindow.initializeCoreDataStructuresForGridBasedMovement()
    }

    func initializeChangeScreenParametersObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: NSApplication.shared,
            queue: OperationQueue.main
        ) { [weak self] notification in
            MainActor.assumeIsolated {
                OSLog.main.log("Received event: didChangeScreenParametersNotification.")

                guard let self = self else {
                    return
                }

                OSLog.main.logDetailsForAllConnectedScreens()

                // For simplicity (and instead of diffing the current window state),
                // always rebuild all jump windows.
                self.rebuildJumpWindows()

                OSLog.main.log("Finished responding to screen change.")
            }
        }
    }

    // MARK: Convenience

    func jumpWindowController(for screen: NSScreen) -> JumpWindowController? {
        self.jumpWindowControllers.first(where: {
            $0.assignedScreen == screen
        })
    }

    // MARK: Settings UI

    lazy var settingsView: SettingsView = {
        SettingsView()
    }()

    lazy var settingsWindowController: NSWindowController = {
        let hostingController = NSHostingController(rootView: self.settingsView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "Scoot Settings"

        return NSWindowController(window: window)
    }()

    // MARK: About UI

    lazy var aboutView: AboutView = {
        AboutView()
    }()

    lazy var aboutWindowController: NSWindowController = {
        let hostingController = NSHostingController(rootView: self.aboutView)

        let window = NSWindow(contentViewController: hostingController)
        window.styleMask = [.closable, .titled]
        window.titlebarAppearsTransparent = true
        window.title = ""

        window.center()

        return NSWindowController(window: window)
    }()

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
        self.statusItem?.button?.image = isProcessTrustedForAccessibilityAccess ?
            menuBarStatusItemOutlinedImage :
            menuBarStatusItemOutlinedImage?.withTintColor(.systemRed)
    }

    func updateMenuBarStatusItemForActiveState() {
        self.statusItem?.button?.image = isProcessTrustedForAccessibilityAccess ?
            menuBarStatusItemFilledImage :
            menuBarStatusItemFilledImage?.withTintColor(.systemRed)
    }

    // MARK: Activation

    func bringToForeground() {
        self.currentApp = NSWorkspace.shared.frontmostApplication

        OSLog.main.log("Scoot invoked with frontmost app: \(String(describing: self.currentApp?.localizedName ?? "<unknown>"), privacy: .private(mask: .hash))")

        let activeJumpMode = self.inputWindow.activeJumpMode

        if let app = self.currentApp , activeJumpMode == .element {
            self.scanElements(of: app)
        }

        OSLog.main.log("Using \(String(describing: activeJumpMode), privacy: .public) jump mode")

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
        // Hide the overlay explicitly. `NSApp.hide` alone can leave the labels on
        // screen: the jump windows are borderless, transparent and join all
        // Spaces, and the input window does not always resign main when the app
        // is hidden, so `windowDidResignMain` — the other place that hides the
        // labels — is skipped, and they stay stranded while the target window
        // moves underneath.
        inputWindow.hideJumpViews()
        jumpWindows.forEach { $0.orderOut(nil) }

        NSApp.hide(self)
    }

    /// Safety net: never leave the overlay up when Scoot is no longer active
    /// (for example when another app is activated without going through the
    /// click path).
    func applicationDidResignActive(_ notification: Notification) {

        #if DEBUG
        OSLog.main.debug("AppDelegate: applicationDidResignActive")
        #endif

        for viewController in jumpViewControllers {
            viewController.hideGrid()
            viewController.hideElements()
        }

        jumpWindows.forEach { $0.orderOut(nil) }
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

    @IBAction func settingsPressed(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController.showWindow(sender)
    }

    @IBAction func aboutPressed(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
        aboutWindowController.showWindow(sender)
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

    @IBAction func debugRebuildJumpWindows(_ sender: NSMenuItem) {
        OSLog.main.log("Debug: rebuilding all jump windows.")

        rebuildJumpWindows()

        bringToForeground()
    }

    @IBAction func toggleJumpWindowTint(_ sender: NSMenuItem) {
        OSLog.main.log("Debug: toggling tint of all jump windows.")

        jumpWindows.forEach {
            $0.backgroundColor = $0.backgroundColor == .clear ?
                UserSettings.shared.secondaryColor.withAlphaComponent(0.3) :
                .clear
        }
    }

    /// Scans the focused window for element-based navigation, retrying when
    /// Scoot has just woken the app's accessibility tree.
    ///
    /// Firefox and Chromium/Electron expose only a handful of untitled stub
    /// nodes for a moment (about two seconds in Zen) after
    /// `AXEnhancedUserInterface` is switched on, so a single synchronous scan
    /// can come back with no usable labels. Retrying keeps the overlay
    /// responsive (it is already on screen) while the labels fill in. Apps
    /// that already had the flag on are scanned once, so a window that really
    /// has few controls (a dialog) is not rescanned.
    func scanElements(of app: NSRunningApplication, attempt: Int = 1, waking: Bool? = nil) {

        guard inputWindow.activeJumpMode == .element else {
            return
        }

        let waking = waking ?? !Accessibility.enableEnhancedUserInterfaceIfNecessary(for: app)

        // For performance reasons, only traverse the accessibility tree if the
        // user is actually using element-based navigation.
        // See https://github.com/mjrusso/scoot/issues/26
        inputWindow.initializeCoreDataStructuresForElementBasedMovement(of: app)

        let count = jumpViewControllers.reduce(0) { $0 + $1.elements.count }
        let maximumAttempts = 8

        guard waking, count < 10, attempt < maximumAttempts, !inputWindow.isWalkingDecisionTree else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in

            // Stop as soon as the user starts typing, so a late scan can never
            // invalidate a half-entered sequence.
            guard let self,
                  self.currentApp === app,
                  self.inputWindow.activeJumpMode == .element,
                  !self.inputWindow.isWalkingDecisionTree else {
                return
            }

            self.scanElements(of: app, attempt: attempt + 1, waking: true)
            self.inputWindow.redrawJumpViews()
        }
    }

    // MARK: Testing and Previewing

    var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    var isRunningSwiftUIPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}
