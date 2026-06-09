import SwiftUI

struct WeekdayHeaderView: View {
    @EnvironmentObject var settings: AppSettings

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        let symbols = CalendarGrid.weekdaySymbols(firstWeekday: settings.firstWeekday)
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(symbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
