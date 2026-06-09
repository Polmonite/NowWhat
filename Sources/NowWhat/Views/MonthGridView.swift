import SwiftUI

struct MonthGridView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var model: CalendarModel
    @EnvironmentObject var eventStore: EventStore

    @State private var eventDays: Set<Date> = []
    @State private var holidays: [Date: String] = [:]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        let days = CalendarGrid.days(for: model.displayedMonth, firstWeekday: settings.firstWeekday)
        let cal = Calendar.current
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \.self) { day in
                let startOfDay = cal.startOfDay(for: day)
                DayCell(
                    date: day,
                    isCurrentMonth: CalendarGrid.isSameMonth(day, model.displayedMonth),
                    isToday: startOfDay == model.today,
                    isSelected: cal.isDate(day, inSameDayAs: model.selectedDate),
                    hasEvents: eventDays.contains(startOfDay),
                    holidayName: holidays[startOfDay]
                )
                .contentShape(Rectangle())
                .onTapGesture { model.select(day) }
            }
        }
        .task(id: markerKey(days)) {
            let markers = eventStore.markers(forDays: days)
            eventDays = markers.eventDays
            holidays = markers.holidays
        }
    }

    /// Refetch markers when the month changes, access is (re)granted, or the store changes.
    private func markerKey(_ days: [Date]) -> String {
        let first = days.first?.timeIntervalSince1970 ?? 0
        return "\(first)-\(eventStore.authorizationStatus.rawValue)-\(eventStore.changeToken)"
    }
}
