import SwiftUI
import Foundation

struct OverlayView: View {
    let width: Double
    let height: Double

    @StateObject var battery = BatteryMonitor()

    @AppStorage("testingMode")  var testingMode = false
    @AppStorage("chargingHide") var chargingHide = true
    @AppStorage("enableAnim")   var enableAnim = true
    @AppStorage("enablePulse")  var enablePulse = true
    @AppStorage("startPercent") var startPercent = 10.0
    @AppStorage("strengthMult") var strengthMult = 100.0
    @AppStorage("effectColor")  var colorHex = 0xff0000

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let clock = Date()

    var body: some View {
        TimelineView(.animation) { context in
            let displayed = testingMode ? 0.01 : battery.getDisplayed()
            let start = startPercent / 100.0

            if displayed <= start {
                let strength = 1.0 - ((displayed - 0.01) / start)

                let r = Double((self.colorHex >> 16) & 0xff) / 255.0
                let g = Double((self.colorHex >> 8) & 0xff) / 255.0
                let b = Double(self.colorHex & 0xff) / 255.0

                let color = Color(red: r, green: g, blue: b)

                Rectangle()
                    .colorEffect(ShaderLibrary.frag(
                        .float2(self.width, self.height),
                        .float(enableAnim && !reduceMotion ? self.clock.timeIntervalSinceNow : 0.0),
                        .float(strength * self.strengthMult / 100.0),
                        .float(self.enablePulse ? 1.0 : 0.0),
                        .color(color)
                    ))
            } else {
                Color.clear
            }
        }
        .onChange(of: chargingHide) {
            battery.update()
        }
    }
}
