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
            // Don't let SwiftUI drive the window size: a grouped Form reports an unreliable
            // preferred height (notably on macOS 26), which collapses the window. Pin the
            // content size to match SettingsView's frame instead.
            hosting.sizingOptions = []
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 740),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false)
            win.contentViewController = hosting
            win.title = "Now What Settings"
            win.isReleasedWhenClosed = false
            win.center()
            window = win
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
