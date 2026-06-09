import Foundation
import ServiceManagement

/// Registers/unregisters the app as a login item via SMAppService (macOS 13+).
/// Note: for login launch to actually fire, the .app must live in a stable location
/// such as /Applications.
enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func set(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("LaunchAtLogin error: \(error.localizedDescription)")
        }
    }
}
