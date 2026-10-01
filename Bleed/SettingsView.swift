import SwiftUI
import ServiceManagement
import Combine

enum AppEvents {
    static let openAllowedChanged = PassthroughSubject<Void, Never>()
}

func promptAllow() {
    let alert = NSAlert()

    alert.messageText = "Open at Login?"
    alert.informativeText = "Allow Bleed to start automatically when you log in."

    alert.addButton(withTitle: "Allow")
    alert.addButton(withTitle: "Later")

    let response = alert.runModal()

    if response == .alertFirstButtonReturn {
        do {
            try SMAppService.mainApp.register()
        } catch {}
    }

    AppEvents.openAllowedChanged.send()
}

struct SettingsView: View {
    @AppStorage("testingMode")  var testingMode = false
    @AppStorage("chargingHide") var chargingHide = true
    @AppStorage("enableAnim")   var enableAnim = true
    @AppStorage("enablePulse")  var enablePulse = true
    @AppStorage("startPercent") var startPercent = 10.0
    @AppStorage("strengthMult") var strengthMult = 100.0

    @AppStorage("effectColor") var colorHex = 0xff0000
    @State var color = Color(red: 1.0, green: 0.0, blue: 0.0)

    @State var openAllowed = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("General:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)

                Form {
                    LabeledContent("Conditions:") {
                        VStack(alignment: .leading) {
                            Toggle("Testing mode", isOn: $testingMode)
                           Toggle("Hide when charging", isOn: $chargingHide)
                        }
                    }
                    .padding(.bottom, 8)

                    LabeledContent("Animation:") {
                        VStack(alignment: .leading) {
                            Toggle("Enable all", isOn: $enableAnim)

                            Toggle("Enable pulsing", isOn: $enablePulse)
                                .disabled(!enableAnim)
                        }
                    }
                    .padding(.bottom, 8)

                    LabeledContent("Color:") {
                        HStack {
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { color },
                                    set: { val in
                                        var r: CGFloat = 0
                                        var g: CGFloat = 0
                                        var b: CGFloat = 0
                                        var a: CGFloat = 0

                                        NSColor(val).getRed(&r, green: &g, blue: &b, alpha: &a)

                                        color = val
                                        colorHex =
                                            (Int(r * 255) << 16) |
                                            (Int(g * 255) << 8) |
                                            (Int(b * 255))
                                    }
                                ),
                                supportsOpacity: false
                            )
                            .labelsHidden()
                            .onAppear {
                                let r = Double((colorHex >> 16) & 0xff) / 255
                                let g = Double((colorHex >> 8) & 0xff) / 255
                                let b = Double(colorHex & 0xff) / 255

                                color = Color(red: r, green: g, blue: b)
                            }

                            Button("Reset", action: {
                                colorHex = 0xff0000
                                color = Color(red: 1.0, green: 0.0, blue: 0.0)
                            })
                        }
                    }
                    .padding(.bottom, 8)
                }
            }

            VStack(alignment: .leading) {
                Text("Start Percentage:")
                    .font(.headline)

                Slider(value: $startPercent, in: 1...25, step: 1)

                Text("\(startPercent, specifier: "%.0f")%")
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            VStack(alignment: .leading) {
                Text("Strength Multiplier:")
                    .font(.headline)

                Slider(value: Binding(
                    get: {
                        if strengthMult <= 100 {
                            (strengthMult - 25) * (50 / 75)
                        } else {
                            50 + (strengthMult - 100) * (50 / 25)
                        }
                    },
                    set: { val in
                        if abs(val - 50) < 3 {
                            strengthMult = 100
                        } else if val <= 50 {
                            strengthMult = 25 + val * (75 / 50)
                        } else {
                            strengthMult = 100 + (val - 50) * (25 / 50)
                        }
                    }
                ), in: 0...100)

                HStack {
                    HStack {
                        Text("25%")
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("100%")
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("125%")
                    }
                }
            }

            HStack {
                Button("Open at Login", action: promptAllow)
                    .disabled(openAllowed)

                if openAllowed {
                    Image(systemName: "checkmark")
                }

                Spacer()
            }
            .onReceive(NSApplication.shared.publisher(for: \.isActive)) { _ in
                updateOpenAllowed()
            }
            .onReceive(AppEvents.openAllowedChanged) { _ in
                updateOpenAllowed()
            }
            .padding(.top, 5)
        }
        .scenePadding()
        .frame(width: 325)
    }

    func updateOpenAllowed() {
        openAllowed = SMAppService.mainApp.status == .enabled
    }
}
