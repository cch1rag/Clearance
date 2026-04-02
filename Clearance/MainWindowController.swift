import Cocoa

class MainWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Clearance"
        window.titlebarAppearsTransparent = true
        window.minSize = NSSize(width: 860, height: 580)
        window.center()
        self.init(window: window)
        self.contentViewController = WebViewController()
    }
}
