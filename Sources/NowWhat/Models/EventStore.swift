import EventKit
import Combine
import Foundation

/// Wraps EventKit: requests access, fetches events for a day, and auto-detects the
/// system "Holidays" subscription calendar so holidays can be highlighted.
final class EventStore: ObservableObject {
    @Published private(set) var authorizationStatus: EKAuthorizationStatus
    /// Bumped whenever the underlying store changes, so views refetch instead of
    /// holding on to stale (faulted) EKEvent objects.
    @Published private(set) var changeToken = 0

    private let store = EKEventStore()
    private var holidayCalendarIDs: Set<String> = []

    init() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        NotificationCenter.default.addObserver(
            self, selector: #selector(storeChanged),
            name: .EKEventStoreChanged, object: store
        )
        refreshHolidayCalendars()
    }

    var hasAccess: Bool { authorizationStatus == .fullAccess }

    func requestAccess() {
        store.requestFullAccessToEvents { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
                self.refreshHolidayCalendars()
            }
        }
    }

    /// Events occurring on `day`, all-day first then chronological.
    func events(on day: Date) -> [EKEvent] {
        guard hasAccess else { return [] }
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).sorted { lhs, rhs in
            if lhs.isAllDay != rhs.isAllDay { return lhs.isAllDay && !rhs.isAllDay }
            return lhs.startDate < rhs.startDate
        }
    }

    /// For a grid of days, returns which days have events and which are holidays (with name).
    func markers(forDays days: [Date]) -> (eventDays: Set<Date>, holidays: [Date: String]) {
        guard hasAccess, let first = days.first, let last = days.last else { return ([], [:]) }
        let cal = Calendar.current
        let start = cal.startOfDay(for: first)
        guard let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: last)) else { return ([], [:]) }
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)

        var eventDays: Set<Date> = []
        var holidays: [Date: String] = [:]
        for event in store.events(matching: predicate) {
            let day = cal.startOfDay(for: event.startDate)
            eventDays.insert(day)
            if let id = event.calendar?.calendarIdentifier, holidayCalendarIDs.contains(id) {
                holidays[day] = event.title
            }
        }
        return (eventDays, holidays)
    }

    @objc private func storeChanged() {
        DispatchQueue.main.async {
            self.refreshHolidayCalendars()
            self.changeToken &+= 1
        }
    }

    /// Heuristic detection of the macOS subscribed holidays calendar across common locales.
    private func refreshHolidayCalendars() {
        guard hasAccess else { holidayCalendarIDs = []; return }
        let keywords = [
            "holiday", "holidays", "festività", "festivita", "feiertag",
            "feriado", "fête", "fete", "festivo", "feestdag", "helg", "vacance"
        ]
        holidayCalendarIDs = Set(
            store.calendars(for: .event)
                .filter { calendar in
                    let title = calendar.title.lowercased()
                    return keywords.contains { title.contains($0) }
                }
                .map { $0.calendarIdentifier }
        )
    }
}
