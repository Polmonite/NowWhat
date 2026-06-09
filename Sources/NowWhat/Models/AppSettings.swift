import Foundation
import Combine

/// User preferences, persisted in UserDefaults. `launchAtLogin` is backed by SMAppService.
final class AppSettings: ObservableObject {
    /// 1 = Sunday ... 7 = Saturday (matches `Calendar.firstWeekday`). Default Monday (2).
    @Published var firstWeekday: Int { didSet { defaults.set(firstWeekday, forKey: Keys.firstWeekday) } }
    @Published var greyWeekends: Bool { didSet { defaults.set(greyWeekends, forKey: Keys.greyWeekends) } }
    @Published var highlightHolidays: Bool { didSet { defaults.set(highlightHolidays, forKey: Keys.highlightHolidays) } }
    @Published var launchAtLogin: Bool { didSet { LaunchAtLogin.set(launchAtLogin) } }

    /// Semitransparent (vibrant) popover background. Default off (solid).
    @Published var translucentBackground: Bool { didSet { defaults.set(translucentBackground, forKey: Keys.translucentBackground) } }
    /// When the popover closes: keep the selected day (true) or jump back to today (false, default).
    @Published var rememberSelectedDay: Bool { didSet { defaults.set(rememberSelectedDay, forKey: Keys.rememberSelectedDay) } }
    /// Show the dot under days that have events. Default on.
    @Published var showEventDots: Bool { didSet { defaults.set(showEventDots, forKey: Keys.showEventDots) } }
    /// Hide events that already ended (before the current date/time). Default on.
    @Published var hidePastEvents: Bool { didSet { defaults.set(hidePastEvents, forKey: Keys.hidePastEvents) } }

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let firstWeekday = "firstWeekday"
        static let greyWeekends = "greyWeekends"
        static let highlightHolidays = "highlightHolidays"
        static let translucentBackground = "translucentBackground"
        static let rememberSelectedDay = "rememberSelectedDay"
        static let showEventDots = "showEventDots"
        static let hidePastEvents = "hidePastEvents"
    }

    init() {
        // didSet observers do not fire for assignments inside init.
        if defaults.object(forKey: Keys.firstWeekday) == nil {
            firstWeekday = 2 // Monday
        } else {
            firstWeekday = defaults.integer(forKey: Keys.firstWeekday)
        }
        greyWeekends = defaults.bool(forKey: Keys.greyWeekends)             // default false
        highlightHolidays = defaults.bool(forKey: Keys.highlightHolidays)   // default false
        translucentBackground = defaults.bool(forKey: Keys.translucentBackground) // default false
        rememberSelectedDay = defaults.bool(forKey: Keys.rememberSelectedDay)     // default false
        showEventDots = defaults.object(forKey: Keys.showEventDots) == nil ? true : defaults.bool(forKey: Keys.showEventDots)
        hidePastEvents = defaults.object(forKey: Keys.hidePastEvents) == nil ? true : defaults.bool(forKey: Keys.hidePastEvents)
        launchAtLogin = LaunchAtLogin.isEnabled
    }
}
