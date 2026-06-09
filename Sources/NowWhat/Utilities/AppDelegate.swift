import AppKit

/// MenuBarExtra only opens its window on left-click. This watches for a right-click on
/// our status bar button and replays it as a normal click, so both buttons open the
/// calendar. If the button can't be located on some future macOS, left-click still works.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private weak var statusButton: NSStatusBarButton?
    private var monitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        locateStatusButton(attemptsLeft: 30)
    }

    deinit {
        if let monitor { NSEvent.removeMonitor(monitor) }
    }

    /// The status item isn't created until the MenuBarExtra scene installs, so retry briefly.
    private func locateStatusButton(attemptsLeft: Int) {
        if let button = Self.findStatusButton() {
            statusButton = button
            installRightClickMonitor()
            return
        }
        guard attemptsLeft > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.locateStatusButton(attemptsLeft: attemptsLeft - 1)
        }
    }

    private func installRightClickMonitor() {
        monitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) { [weak self] event in
            guard let self, let button = self.statusButton, event.window === button.window else {
                return event
            }
            button.performClick(nil)
            return nil
        }
    }

    private static func findStatusButton() -> NSStatusBarButton? {
        for window in NSApp.windows {
            if let button = search(window.contentView) { return button }
        }
        return nil
    }

    private static func search(_ view: NSView?) -> NSStatusBarButton? {
        guard let view else { return nil }
        if let button = view as? NSStatusBarButton { return button }
        for subview in view.subviews {
            if let button = search(subview) { return button }
        }
        return nil
    }
}
