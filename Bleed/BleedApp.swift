import SwiftUI
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    @AppStorage("launchSettings") var launchSettings = true
    @Environment(\.openSettings) var openSettings

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.removeObject(forKey: "disable")
        createWindow()

        if launchSettings {
            openSettings()
            promptAllow()

            launchSettings = false
        }
    }

    func createWindow() {
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
}

@main
struct BleedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openSettings) private var openSettings

    @AppStorage("disable") var disable = false

    var body: some Scene {
        MenuBarExtra("Bleed", image: disable ? "Disabled" : "Icon") {
            Toggle("Pause", isOn: $disable)

            Button {
                NSApp.activate(ignoringOtherApps: true)
                openSettings()
            } label: {
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
        .windowLevel(.floating)
    }
}
