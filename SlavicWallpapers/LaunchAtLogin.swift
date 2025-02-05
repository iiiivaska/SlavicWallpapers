import Foundation
import ServiceManagement

class LaunchAtLogin {
    static func enable() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        } else {
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            SMLoginItemSetEnabled(bundleId as CFString, true)
        }
    }

    static func disable() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.unregister()
        } else {
            let bundleId = Bundle.main.bundleIdentifier ?? ""
            SMLoginItemSetEnabled(bundleId as CFString, false)
        }
    }
}
