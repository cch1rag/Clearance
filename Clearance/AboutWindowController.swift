import Cocoa

class AboutWindowController: NSWindowController {
    static let shared = AboutWindowController()

    private init() {
        let w: CGFloat = 320
        let h: CGFloat = 290
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: w, height: h),
            styleMask: [.titled, .closable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.title = "About Clearance"
        panel.hidesOnDeactivate = false
        super.init(window: panel)
        buildUI(width: w)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func buildUI(width: CGFloat) {
        guard let v = window?.contentView else { return }

        // App icon
        let icon = NSImageView(frame: NSRect(x: (width - 64) / 2, y: 210, width: 64, height: 64))
        icon.image = NSApp.applicationIconImage
        v.addSubview(icon)

        // App name
        v.addSubview(makeLabel("Clearance", fontSize: 16, weight: .semibold, y: 178, width: width))

        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        v.addSubview(makeLabel("Version \(version)", fontSize: 12, color: .secondaryLabelColor, y: 154, width: width))

        // Tagline
        v.addSubview(makeLabel("A macOS privacy permission manager.", fontSize: 12, color: .secondaryLabelColor, y: 120, width: width))

        // Author
        v.addSubview(makeLabel("Built by Chirag Chopra", fontSize: 12, color: .secondaryLabelColor, y: 96, width: width))

        // Privacy note
        v.addSubview(makeLabel("100% local — no data leaves your Mac.", fontSize: 11, color: .tertiaryLabelColor, y: 70, width: width))

        // GitHub link button
        let link = NSButton(frame: NSRect(x: 0, y: 40, width: width, height: 22))
        link.title = "github.com/cch1rag/clearance"
        link.bezelStyle = .inline
        link.isBordered = false
        link.contentTintColor = .linkColor
        link.font = NSFont.systemFont(ofSize: 11)
        link.target = self
        link.action = #selector(openGitHub)
        link.alignment = .center
        v.addSubview(link)

        // Copyright
        v.addSubview(makeLabel("MIT License · © 2026 Chirag Chopra", fontSize: 10, color: .quaternaryLabelColor, y: 16, width: width))
    }

    private func makeLabel(_ text: String,
                            fontSize: CGFloat,
                            weight: NSFont.Weight = .regular,
                            color: NSColor = .labelColor,
                            y: CGFloat,
                            width: CGFloat) -> NSTextField {
        let tf = NSTextField(labelWithString: text)
        tf.font = NSFont.systemFont(ofSize: fontSize, weight: weight)
        tf.textColor = color
        tf.alignment = .center
        tf.frame = NSRect(x: 0, y: y, width: width, height: 22)
        return tf
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(URL(string: "https://github.com/cch1rag/clearance")!)
    }

    func show() {
        window?.center()
        showWindow(nil)
        window?.makeKeyAndOrderFront(nil)
    }
}
