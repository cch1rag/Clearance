import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenuBar()
        windowController = MainWindowController()
        NSApp.activate(ignoringOtherApps: true)
        windowController?.window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - Menu bar

    private func buildMenuBar() {
        let bar = NSMenu()

        // Clearance (app) menu
        let appItem = NSMenuItem()
        bar.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        let aboutItem = appMenu.addItem(withTitle: "About Clearance", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit Clearance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        // File menu
        let fileItem = NSMenuItem()
        bar.addItem(fileItem)
        let fileMenu = NSMenu(title: "File")
        fileItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "Open Database\u{2026}", action: #selector(WebViewController.openDatabase(_:)), keyEquivalent: "o")
        fileMenu.addItem(withTitle: "Reload", action: #selector(WebViewController.reloadPage(_:)), keyEquivalent: "r")

        // Help menu
        let helpItem = NSMenuItem()
        bar.addItem(helpItem)
        let helpMenu = NSMenu(title: "Help")
        helpItem.submenu = helpMenu
        let githubItem = helpMenu.addItem(withTitle: "View on GitHub", action: #selector(openGitHub), keyEquivalent: "")
        githubItem.target = self

        NSApp.mainMenu = bar
    }

    @objc private func showAbout() {
        AboutWindowController.shared.show()
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(URL(string: "https://github.com/cch1rag/clearance")!)
    }
}
