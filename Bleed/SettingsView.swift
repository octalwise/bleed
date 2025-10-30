import SwiftUI

struct SettingsView: View {
    @AppStorage("testingMode")  var testingMode = false
    @AppStorage("chargingHide") var chargingHide = true

    @AppStorage("enableAnim")  var enableAnim = true
    @AppStorage("enablePulse") var enablePulse = true

    @AppStorage("startPercent") var startPercent = 10.0
    @AppStorage("strengthMult") var strengthMult = 100.0

    @AppStorage("effectColor") var colorHex = 0xff0000
    @State var color = Color(red: 1.0, green: 0.0, blue: 0.0)

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
                            Toggle("Testing mode", isOn: self.$testingMode)
                           Toggle("Hide when charging", isOn: self.$chargingHide)
                        }
                    }
                    .padding(.bottom, 8)

                    LabeledContent("Animation:") {
                        VStack(alignment: .leading) {
                            Toggle("Enable all", isOn: self.$enableAnim)

                            Toggle("Enable pulsing", isOn: self.$enablePulse)
                                .disabled(!self.enableAnim)
                        }
                    }
                    .padding(.bottom, 8)

                    LabeledContent("Color:") {
                        HStack {
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { self.color },
                                    set: { val in
                                        var r: CGFloat = 0
                                        var g: CGFloat = 0
                                        var b: CGFloat = 0
                                        var a: CGFloat = 0

                                        NSColor(val).getRed(&r, green: &g, blue: &b, alpha: &a)

                                        self.color = val
                                        self.colorHex =
                                            (Int(r * 255) << 16) |
                                            (Int(g * 255) << 8) |
                                            (Int(b * 255))
                                    }
                                ),
                                supportsOpacity: false
                            )
                            .labelsHidden()
                            .onAppear {
                                let r = Double((self.colorHex >> 16) & 0xff) / 255
                                let g = Double((self.colorHex >> 8) & 0xff) / 255
                                let b = Double(self.colorHex & 0xff) / 255

                                self.color = Color(red: r, green: g, blue: b)
                            }

                            Button("Reset", action: {
                                self.colorHex = 0xff0000
                                self.color = Color(red: 1.0, green: 0.0, blue: 0.0)
                            })
                        }
                    }
                    .padding(.bottom, 8)
                }
            }

            VStack(alignment: .leading) {
                Text("Start Percentage:")
                    .font(.headline)

                Slider(value: self.$startPercent, in: 1...25, step: 1)

                Text("\(self.startPercent, specifier: "%.0f")%")
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            VStack(alignment: .leading) {
                Text("Strength Multiplier:")
                    .font(.headline)

                Slider(value: Binding(
                    get: {
                        if self.strengthMult <= 100 {
                            (self.strengthMult - 25) * (50 / 75)
                        } else {
                            50 + (self.strengthMult - 100) * (50 / 25)
                        }
                    },
                    set: { val in
                        if abs(val - 50) < 3 {
                            self.strengthMult = 100
                        } else if val <= 50 {
                            self.strengthMult = 25 + val * (75 / 50)
                        } else {
                            self.strengthMult = 100 + (val - 50) * (25 / 50)
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
        }
        .scenePadding()
        .frame(width: 325)
    }
}
