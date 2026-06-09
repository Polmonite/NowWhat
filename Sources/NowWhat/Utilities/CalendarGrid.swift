import Foundation

/// Pure helpers for laying out a month as a 6×7 grid and ordering weekday headers.
enum CalendarGrid {
    static func calendar(firstWeekday: Int) -> Calendar {
        var cal = Calendar.current
        cal.firstWeekday = firstWeekday
        return cal
    }

    /// The 42 days (6 weeks) covering `month`, including leading/trailing days from
    /// adjacent months so the grid is always a stable rectangle.
    static func days(for month: Date, firstWeekday: Int) -> [Date] {
        let cal = calendar(firstWeekday: firstWeekday)
        guard let monthInterval = cal.dateInterval(of: .month, for: month) else { return [] }
        let firstOfMonth = monthInterval.start
        let weekday = cal.component(.weekday, from: firstOfMonth)
        let offset = (weekday - firstWeekday + 7) % 7
        guard let start = cal.date(byAdding: .day, value: -offset, to: firstOfMonth) else { return [] }
        return (0..<42).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    /// Localized short weekday symbols ordered to start at `firstWeekday`.
    static func weekdaySymbols(firstWeekday: Int) -> [String] {
        let symbols = Calendar.current.shortWeekdaySymbols // index 0 == Sunday
        let start = firstWeekday - 1
        return (0..<7).map { symbols[(start + $0) % 7] }
    }

    static func isSameMonth(_ a: Date, _ b: Date) -> Bool {
        let cal = Calendar.current
        return cal.component(.month, from: a) == cal.component(.month, from: b)
            && cal.component(.year, from: a) == cal.component(.year, from: b)
    }
}
