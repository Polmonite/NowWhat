import SwiftUI

@main
struct NowWhatApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var eventStore = EventStore()
    @StateObject private var model = CalendarModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarRootView()
                .environmentObject(settings)
                .environmentObject(eventStore)
                .environmentObject(model)
        } label: {
            // Classic single-day calendar glyph with today's date inside.
            Image(nsImage: MenuBarIcon.image(day: model.currentDay))
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarRootView: View {
    var body: some View {
        CalendarView()
            .frame(width: 320)
    }
}
