import SwiftUI
import AppKit

/// MenuBarExtra(.window) installs its own opaque NSVisualEffectView as the window's
/// backing. To make the popover translucent we must reconfigure *that* backing view
/// (and clear the window) rather than layering another effect view on top.
struct WindowConfigurator: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .hudWindow

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { configure(from: view) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { configure(from: nsView) }
    }

    private func configure(from view: NSView) {
        guard let window = view.window else { return }
        window.isOpaque = false
        window.backgroundColor = .clear
        if let content = window.contentView { applyTransparent(content) }
    }

    private func applyTransparent(_ view: NSView) {
        if let effect = view as? NSVisualEffectView {
            effect.material = material
            effect.blendingMode = .behindWindow
            effect.state = .active
        }
        for subview in view.subviews { applyTransparent(subview) }
    }
}
