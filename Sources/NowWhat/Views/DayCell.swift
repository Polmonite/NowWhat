import SwiftUI

struct DayCell: View {
    @EnvironmentObject var settings: AppSettings

    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let hasEvents: Bool
    let holidayName: String?

    var body: some View {
        let cal = Calendar.current
        let isWeekend = cal.isDateInWeekend(date)
        let dayNumber = cal.component(.day, from: date)

        VStack(spacing: 2) {
            Text("\(dayNumber)")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundStyle(textColor(isWeekend: isWeekend))
            Circle()
                .fill(dotColor)
                .frame(width: 5, height: 5)
        }
        .frame(maxWidth: .infinity, minHeight: 36)
        .background(circleBackground)
        .help(holidayName ?? "")
    }

    private var showDot: Bool { hasEvents && settings.showEventDots }

    private var dotColor: Color {
        guard showDot else { return .clear }
        return isSelected ? .white : .accentColor
    }

    /// Filled circle marks the selected day; an outline ring marks today.
    private var circleBackground: some View {
        GeometryReader { geo in
            let diameter = min(geo.size.width, geo.size.height)
            ZStack {
                if isSelected {
                    Circle().fill(Color.accentColor).frame(width: diameter, height: diameter)
                }
                if isToday {
                    Circle().strokeBorder(Color.accentColor, lineWidth: 1.5).frame(width: diameter, height: diameter)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func textColor(isWeekend: Bool) -> Color {
        if isSelected { return .white }
        if !isCurrentMonth { return Color.secondary.opacity(0.4) }
        if settings.highlightHolidays, holidayName != nil { return .green }
        if settings.greyWeekends, isWeekend { return .secondary }
        return .primary
    }
}
