import Cocoa

class MainWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Clearance"
        window.minSize = NSSize(width: 860, height: 580)
        window.center()
        window.isRestorable = false
        self.init(window: window)
        self.contentViewController = WebViewController()
    }
}
