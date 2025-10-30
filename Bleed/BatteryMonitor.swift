import SwiftUI
import IOKit.ps

final class BatteryMonitor: ObservableObject {
    var percentage = 1.0
    var isCharging = false

    var last = 1.0
    var lastUpdate = Date()

    @AppStorage("chargingHide") var chargingHide = true

    private var runLoopSource: Unmanaged<CFRunLoopSource>?

    init() {
        update()

        runLoopSource = IOPSNotificationCreateRunLoopSource(
            { context in
                let monitor = Unmanaged<BatteryMonitor>.fromOpaque(context!).takeUnretainedValue()
                monitor.update()
            },
            Unmanaged.passUnretained(self).toOpaque()
        )

        if let src = runLoopSource?.takeRetainedValue() {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), src, .defaultMode)
        }
    }

    deinit {
        if let src = runLoopSource?.takeUnretainedValue() {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), src, .defaultMode)
        }
    }

    func update() {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        guard let source = sources.first else { return }

        let info =
            IOPSGetPowerSourceDescription(snapshot, source)
                .takeUnretainedValue() as! [String: AnyObject]

        let capacity = info[kIOPSCurrentCapacityKey] as! Double
        let max = info[kIOPSMaxCapacityKey] as! Double

        let charging =
            info[kIOPSIsChargingKey] as? Bool ??
                ((info[kIOPSPowerSourceStateKey] as? String) == kIOPSACPowerValue)

        DispatchQueue.main.async {
            self.last = self.getDisplayed()
            self.lastUpdate = Date()

            self.percentage = self.chargingHide && charging ? 1.0 : capacity / max
            self.isCharging = charging
        }
    }

    func getDisplayed() -> Double {
        let secs = 3.0
        let elapsed = min(-self.lastUpdate.timeIntervalSinceNow, secs) / secs

        return self.last + self.fade(elapsed) * (self.percentage - self.last)
    }

    func fade(_ x: Double) -> Double {
        return x * x * x * (x * (x * 6 - 15) + 10)
    }
}
