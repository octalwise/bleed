import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    @Environment(\.openSettings) var openSettings

    func applicationDidFinishLaunching(_ notification: Notification) {
        let frame = NSScreen.main!.frame

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: frame.width, height: frame.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.ignoresMouseEvents = true

        window.level = .statusBar
        window.orderFrontRegardless()
        window.collectionBehavior = [.canJoinAllSpaces]

        let contentView = OverlayView(
            width: Double(frame.width),
            height: Double(frame.height)
        )
        window.contentView = NSHostingView(rootView: contentView)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            sender.windows.first?.makeKeyAndOrderFront(nil)
        }

        openSettings()

        return true
    }
}

@main
struct BleedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
