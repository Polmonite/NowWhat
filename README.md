# Now What

A tiny, fast macOS menu bar calendar. No dock icon — it lives in the menu bar and
opens a small month calendar with the events for the selected day.

## Features

- **Month calendar** in a menu bar popover: full month, one week per row, with quick
  navigation by month (`‹ ›`) and year (`‹‹ ››`). Days outside the current month are
  greyed out. Click the month title to jump back to today.
- **macOS Calendar integration** via EventKit: shows events for the selected day in a
  small scrollable list. Days with events show a dot. (No notifications.)
- **Focused on today** by default; click any day to see its events below.
- **Settings** (gear icon):
  - Launch at login
  - Day the week starts on (default: Monday)
  - Grey out weekend days (default: off)
  - Highlight holidays from your macOS Holidays calendar (default: off)

## Requirements

- macOS 14 (Sonoma) or later
- Swift toolchain (Xcode Command Line Tools: `xcode-select --install`)

## Build & run

```sh
./build.sh --release --run
```

This compiles, assembles `build/Now What.app`, ad-hoc signs it (needed so calendar
access and login-item registration work), and launches it. A 📅 icon with today's
weekday/date appears in the menu bar — click it.

The first time you open the events list, click **Connect to Calendar** and grant access.

### Installing

To make *Launch at login* fire reliably, move the app to `/Applications`:

```sh
./build.sh --release
cp -R "build/Now What.app" /Applications/
open "/Applications/Now What.app"
```

## Releasing

Releases are published to GitHub by **pushing a version tag** — a GitHub Actions
workflow (`.github/workflows/release.yml`) builds on a macOS runner and attaches the
zipped app to a new release.

```sh
git tag v1.1
git push origin v1.1
```

The workflow stamps the app's version from the tag (so `v1.1` → `CFBundleShortVersionString = 1.1`),
builds, zips `Now What.app`, and creates the release with auto-generated notes. You only
manage the tag — no manual version bumping needed.

### Check for updates

Settings ▸ **Updates** shows the running version and a **Check for Updates…** button. It
queries the latest GitHub release of `Polmonite/NowWhat`, compares versions, and offers a
button to open the release page if a newer one exists.

### Installing a downloaded release

The app is ad-hoc signed (not notarized), so Gatekeeper will warn on first open. Either
right-click the app ▸ **Open**, or strip the quarantine flag:

```sh
xattr -dr com.apple.quarantine "Now What.app"
```

## Notes

- **Holidays** are detected automatically from a subscribed macOS Holidays calendar
  (matched by name across common locales). If you don't have one subscribed, the
  highlight option simply has nothing to mark. Subscribe in Calendar.app via
  *File ▸ New Holiday Calendar* (or it may already be present).
- The app is unsandboxed and ad-hoc signed for local use. For distribution you'd add a
  Developer ID signature and notarization.

## Project layout

```
Sources/NowWhat/
  NowWhatApp.swift          App entry, MenuBarExtra, calendar/settings switch
  Models/                   AppSettings, CalendarModel, EventStore (EventKit)
  Utilities/                LaunchAtLogin (SMAppService), CalendarGrid (layout math)
  Views/                    CalendarView, MonthGridView, DayCell, EventListView, SettingsView, …
Resources/Info.plist        Bundle metadata (LSUIElement, calendar usage strings)
build.sh                    Builds and signs the .app bundle
```
