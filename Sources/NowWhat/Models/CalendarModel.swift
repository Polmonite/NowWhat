import Foundation
import Combine

/// Holds the calendar's navigation state: which month is displayed, which day is
/// selected, and today's date (kept current by a timer so the view rolls over at midnight).
final class CalendarModel: ObservableObject {
    @Published var displayedMonth: Date
    @Published var selectedDate: Date
    @Published private(set) var today: Date

    private var timer: Timer?

    init() {
        let start = Calendar.current.startOfDay(for: Date())
        today = start
        selectedDate = start
        displayedMonth = start
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            let now = Calendar.current.startOfDay(for: Date())
            if now != self.today { self.today = now }
        }
    }

    /// Day-of-month shown inside the menu bar icon.
    var currentDay: Int { Calendar.current.component(.day, from: today) }

    /// Year currently displayed in the grid.
    var displayedYear: Int { Calendar.current.component(.year, from: displayedMonth) }

    func goToToday() {
        displayedMonth = today
        selectedDate = today
    }

    func select(_ date: Date) { selectedDate = date }

    func changeMonth(by value: Int) {
        if let date = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = date
        }
    }

    /// Set the displayed year, keeping the current month/day.
    func setYear(_ year: Int) {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: displayedMonth)
        comps.year = year
        if let date = cal.date(from: comps) { displayedMonth = date }
    }
}
