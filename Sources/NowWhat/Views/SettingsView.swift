import SwiftUI
import AppKit

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var updateChecker = UpdateChecker()

    var body: some View {
        VStack(spacing: 0) {
            settingsForm
            footer
        }
        .frame(width: 420, height: 600)
    }

    private var settingsForm: some View {
        Form {
            Section("General") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Picker("Week starts on", selection: $settings.firstWeekday) {
                    ForEach(weekdayOptions, id: \.value) { option in
                        Text(option.name).tag(option.value)
                    }
                }
                Picker("When closed", selection: $settings.rememberSelectedDay) {
                    Text("Reset to today").tag(false)
                    Text("Remember selected day").tag(true)
                }
            }

            Section("Appearance") {
                Toggle("Translucent background", isOn: $settings.translucentBackground)
                Toggle("Grey out weekends", isOn: $settings.greyWeekends)
                Toggle("Show which days have events", isOn: $settings.showEventDots)
                VStack(alignment: .leading, spacing: 2) {
                    Toggle("Highlight holidays", isOn: $settings.highlightHolidays)
                    Text("Uses your macOS Holidays calendar, if subscribed.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Events") {
                Toggle("Hide past events", isOn: $settings.hidePastEvents)
            }

            Section("Updates") {
                LabeledContent("Version", value: updateChecker.currentVersion)
                HStack {
                    Button("Check for Updates…") { updateChecker.check() }
                        .disabled(updateChecker.status == .checking)
                    Spacer()
                    updateStatus
                }
            }

            Section {
                Button("Quit Now What") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .formStyle(.grouped)
    }

    @ViewBuilder
    private var updateStatus: some View {
        switch updateChecker.status {
        case .idle:
            EmptyView()
        case .checking:
            ProgressView().controlSize(.small)
        case .upToDate:
            Label("Up to date", systemImage: "checkmark.circle")
                .font(.caption)
                .foregroundStyle(.secondary)
        case .updateAvailable(let version, let url):
            Button("Get \(version)") { NSWorkspace.shared.open(url) }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        case .failed(let message):
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var footer: some View {
        VStack(spacing: 2) {
            Text("Made by Polmonite")
            Text("Copyright © 2026")
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.vertical, 12)
    }

    private var weekdayOptions: [(value: Int, name: String)] {
        let symbols = Calendar.current.weekdaySymbols // index 0 == Sunday
        return (0..<7).map { (value: $0 + 1, name: symbols[$0]) }
    }
}
