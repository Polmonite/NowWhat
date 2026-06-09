import AppKit
import SwiftUI

/// Manages a standalone settings window. The SwiftUI `Settings` scene is unreliable for
/// menu-bar-only (accessory) apps, so we create and show a real NSWindow on demand.
@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()
    private var window: NSWindow?

    func show(settings: AppSettings) {
        if window == nil {
            let hosting = NSHostingController(rootView: SettingsView().environmentObject(settings))
            let win = NSWindow(contentViewController: hosting)
            win.title = "Now What Settings"
            win.styleMask = [.titled, .closable]
            win.isReleasedWhenClosed = false
            win.center()
            window = win
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
