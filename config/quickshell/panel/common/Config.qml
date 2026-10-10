pragma Singleton

import QtQuick
import Quickshell

// ============================================================================
// Panel configuration — the one file to edit for layout changes.
// ============================================================================
Singleton {
    // Tabs shown at the top of the panel. Each tab is a list of rows:
    //   row:  { height: fraction of the tab's height, cells: [...] }
    //   cell: { width: fraction of its row, zones: [...] }   zones stack top → bottom
    //   zone: "Name", or { zone: "Name", height, props, link: "Tab" }
    //         link: clicking the zone opens that tab and highlights the same
    //         zone there (e.g. Overview's Profile → Controls' Profile)
    //     or: { width: fraction of its row, cells: [...] }   a nested row of cells
    // In a stack the last zone fills the leftover height. Each zone name is a
    // file in zones/ (without .qml).
    readonly property var tabs: [
        {
            name: "Notifications", icon: "\uf0f3",
            rows: [
                { height: 1, cells: [{ width: 1, zones: ["NotificationListZone"] }] }
            ]
        },
        {
            name: "Media", icon: "\uf001",
            rows: [
                { height: 1, cells: [{ width: 1, zones: ["MediaZone"] }] }
            ]
        },
        {
            name: "Weather", icon: "\uf0c2",
            rows: [
                { height: 1, cells: [
                    { width: 0.58, zones: [
                        { zone: "TemperatureChartZone", height: 0.64 },
                        { zone: "HourlyForecastZone", height: 0.36 }
                    ] },
                    { width: 0.42, zones: ["WeatherCurrentZone", "DailyForecastZone"] }
                ] }
            ]
        },
        {
            name: "Overview", icon: "\uf009",
            // The profile is centered under the "Overview" tab (the middle of 7
            // tabs = the middle of the panel), with weather/clock and
            // notifications equally wide on each side; the right column below
            // lines up with notifications.
            rows: [
                { height: 0.25, cells: [
                    { width: 0.3957, zones: ["NowZone"] },
                    { width: 0.2086, zones: [{ zone: "ProfileZone", link: "Controls" }] },
                    { width: 0.3957, zones: ["NotificationsZone"] }
                ] },
                { height: 0.75, cells: [
                    // monthFraction keeps the month grid the same size as before;
                    // the narrower card takes the space from the day's events
                    { width: 0.6076, zones: [{ zone: "CalendarZone", props: { monthFraction: 0.63 } }] },
                    { width: 0.3924, zones: [{ zone: "SystemZone", link: "Controls" }, "MediaMiniZone"] }
                ] }
            ]
        },
        {
            name: "Calendar", icon: "\uf073",
            rows: [
                { height: 1, cells: [
                    { width: 0.40, zones: [{ zone: "CalendarZone", props: { showDayEvents: false } }] },
                    { width: 0.32, zones: ["AgendaZone"] },
                    { width: 0.28, zones: ["TodoZone"] }
                ] }
            ]
        },
        {
            name: "Wallpapers", icon: "\uf03e",
            rows: [
                { height: 1, cells: [{ width: 1, zones: ["WallpapersZone"] }] }
            ]
        },
        {
            name: "Controls", icon: "\uf1de",
            // One composite zone: identity bar, toggles, sliders, detail pane,
            // and the Settings view behind ⚙ (zones/ControlCenter.qml)
            rows: [
                { height: 1, cells: [{ width: 1, zones: ["ControlCenter"] }] }
            ]
        }
    ]

    // Values below that the user can change live in Settings (common/Settings.qml)

    // Tab shown when the panel opens (by name)
    readonly property string defaultTab: Settings.v.openTab

    // Panel size as a fraction of the usable screen area (screen minus
    // waybar/reserved space). 0.5 wide = 25% free on each side.
    readonly property real widthFraction: Settings.v.width / 100
    readonly property real heightFraction: Settings.v.height / 100
    readonly property int topMargin: 6       // gap below the bar
    readonly property int spacing: 8         // gap between zones

    // Commands used by the lock / power buttons (Controls identity bar, System zone)
    readonly property string lockCmd: "$HOME/.config/hypr/scripts/LockScreen.sh"
    readonly property string powerCmd: "$HOME/.config/hypr/scripts/Wlogout.sh"   // power menu (hold-to-confirm)

    // Weather data comes from the existing waybar weather script (Open-Meteo)
    readonly property string weatherScript: "$HOME/dotfiles/scripts/lib/Weather.py"
    readonly property int weatherIntervalMs: 10 * 60 * 1000

    // Calendar events (scripts/events.py): Evolution webcal subscriptions +
    // ~/.config/lagos/calendars/*.ics, parsed in this Python venv
    readonly property string eventsPython: "$HOME/.local/share/quickshell-panel/venv/bin/python"
    readonly property int eventsIntervalMs: Settings.v.calRefresh * 60 * 1000
    readonly property int firstWeekday: Settings.v.weekStart    // 0 = Sunday, 1 = Monday

    // Wallpapers tab: folder to browse and the command that applies a file
    // (the same script as SUPER W, which also runs wallust and refreshes bars)
    readonly property string wallpaperDir: "$HOME/Pictures/wallpapers"
    readonly property string wallpaperApplyCmd: "$HOME/dotfiles/scripts/wm/WallpaperSelect.sh"
}
