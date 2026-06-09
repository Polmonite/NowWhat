import SwiftUI
import AppKit

struct CalendarView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var model: CalendarModel

    var body: some View {
        VStack(spacing: 8) {
            header
            WeekdayHeaderView()
            MonthGridView()
            Divider()
            EventListView()
        }
        .padding(10)
        .background(backgroundView)
        .onDisappear {
            // When the popover closes, reset to today unless the user opted to remember.
            if !settings.rememberSelectedDay { model.goToToday() }
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if settings.translucentBackground {
            WindowConfigurator().ignoresSafeArea()
        } else {
            Color(nsColor: .windowBackgroundColor).ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            navButton("chevron.left", help: "Previous month") { model.changeMonth(by: -1) }
            Spacer(minLength: 4)
            Button(action: { model.goToToday() }) {
                Text(monthName).font(.headline).foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .help("Jump to today")
            yearMenu
            Spacer(minLength: 4)
            navButton("chevron.right", help: "Next month") { model.changeMonth(by: 1) }
            Button(action: openSettings) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.borderless)
            .help("Settings")
        }
    }

    private var yearMenu: some View {
        Menu {
            ForEach(yearRange, id: \.self) { year in
                Button(String(year)) { model.setYear(year) }
            }
        } label: {
            Text(String(model.displayedYear)).font(.headline)
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .help("Select year")
    }

    private func navButton(_ symbol: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol) }
            .buttonStyle(.borderless)
            .help(help)
    }

    private var yearRange: [Int] {
        let year = model.displayedYear
        return Array((year - 10)...(year + 10))
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("LLLL")
        return formatter.string(from: model.displayedMonth)
    }

    private func openSettings() {
        SettingsWindowController.shared.show(settings: settings)
    }
}
