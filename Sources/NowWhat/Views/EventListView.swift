import SwiftUI
import EventKit

struct EventListView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var model: CalendarModel
    @EnvironmentObject var eventStore: EventStore

    @State private var events: [EKEvent] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selectedTitle)
                .font(.subheadline.bold())

            Group {
                switch eventStore.authorizationStatus {
                case .notDetermined:
                    Button("Connect to Calendar") { eventStore.requestAccess() }
                        .controlSize(.small)
                case .fullAccess:
                    eventList
                default:
                    accessDenied
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        // A constant height keeps the MenuBarExtra(.window) popover from resizing as the
        // selected day's event count changes — resizing makes it drift off the menu bar.
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 280)
        .task(id: listKey) {
            events = eventStore.events(on: model.selectedDate)
        }
    }

    /// Events to show. "Hide today's past events" only applies to today — it trims events that
    /// already ended, leaving what's still upcoming. Other days always show every event.
    private var visibleEvents: [EKEvent] {
        guard settings.hidePastEvents,
              Calendar.current.isDateInToday(model.selectedDate) else { return events }
        let now = Date()
        return events.filter { $0.endDate >= now }
    }

    @ViewBuilder
    private var eventList: some View {
        if visibleEvents.isEmpty {
            Text("No events")
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
        } else {
            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(visibleEvents.enumerated()), id: \.offset) { _, event in
                        EventRow(event: event)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }

    private var accessDenied: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Calendar access is off.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars") {
                    NSWorkspace.shared.open(url)
                }
            }
            .controlSize(.small)
        }
    }

    private var listKey: String {
        "\(model.selectedDate.timeIntervalSince1970)-\(eventStore.authorizationStatus.rawValue)-\(eventStore.changeToken)"
    }

    private var selectedTitle: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEE d MMMM")
        return formatter.string(from: model.selectedDate)
    }
}

struct EventRow: View {
    let event: EKEvent

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(calendarColor)
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title ?? "(No title)")
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(2)
                Text(timeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.06)))
    }

    private var calendarColor: Color {
        if let cg = event.calendar?.cgColor { return Color(cgColor: cg) }
        return .accentColor
    }

    private var timeText: String {
        if event.isAllDay { return "All day" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: event.startDate)) – \(formatter.string(from: event.endDate))"
    }
}
