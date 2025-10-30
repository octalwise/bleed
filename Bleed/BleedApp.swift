import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var status: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.createWindow()
    }

    func createWindow() {
        let frame = NSScreen.main!.frame

        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: frame.width, height: frame.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        self.window.isOpaque = false
        self.window.backgroundColor = .clear
        self.window.ignoresMouseEvents = true

        self.window.level = .statusBar
        self.window.orderFrontRegardless()
        self.window.collectionBehavior = [.canJoinAllSpaces]

        let contentView = OverlayView(
            width: Double(frame.width),
            height: Double(frame.height)
        )
        self.window.contentView = NSHostingView(rootView: contentView)
    }
}

@main
struct BleedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Bleed", image: "Icon") {
            SettingsLink {
                Label("Settings…", systemImage: "gearshape")
            }
            .keyboardShortcut(",", modifiers: [.command])

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }

        Settings {
            SettingsView()
        }
    }
}
