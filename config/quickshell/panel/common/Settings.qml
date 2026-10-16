pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// User settings (Controls → ⚙ Settings): one JSON file, defaults in code.
//   Settings.v.<key>            current value (bind to it)
//   Settings.set(key, value)    change + save (undo with Settings.undo())
//   Settings.reset(sectionId)   back to the defaults of one section
// `sections` is the schema the Settings view is generated from: adding a
// setting = a default below + a row in its section. Rows marked `system` change
// files outside the panel (hypridle, BatteryNotify.sh…); services/SystemSettings.qml
// applies them.
// File: ~/.config/lagos/panel-settings.json (outside the repo, like todo.json).
Singleton {
    id: root

    readonly property var defaults: ({
        // Appearance (the theme is also set from Controls → Dark mode)
        alertMark: "auto", alertShape: "pill",                   // how warnings stand out (Theme.markOf)
        mode: "system", inverted: false, themeScope: "both", themeLaunchers: ["all"], opacity: 72, blur: true, animations: true, rofiPosition: "bottom",
        // Panel
        openTab: "Overview", closeOutside: true, dimHover: true, width: 50, height: 50,
        // Notifications
        dndSched: false, dndWindow: "23:00-07:00", critical: true, popupSecs: 6, history: 100,
        // Where popups appear, per type (services/Notifs.qml placeKind)
        posLevel: "top", posBrightness: "island", posSystem: "top", posMessage: "bottom-right", posMedia: "top-right", posApp: "top-right",
        posCall: "top-left", posSecurity: "top", posReminder: "top-right", posProgress: "top-right",
        maxPopups: 3, groupMessages: true, msgPicture: "photo", callsThroughDnd: true, downloadsThroughDnd: true, notifTheme: "panel",
        appRules: ({}),                                           // appName → place | "off" | "mute"
        // Power & idle (system)
        dim: 300, warn: 540, lock: 600, screenOff: 630, suspend: 1200, mediaGuard: true,
        lidBattery: "suspend", lidAc: "lock", lidDocked: "nothing",  // scripts/wm/LaptopLid.sh
        battery: [50, 20, 10, 5], loginProfile: "keep",
        // Weather & calendar
        weekStart: 0, calRefresh: 30, agendaView: "list",
        dueStages: [4320, 1440, 180, 60], briefOn: true, briefHour: 7, soonEvent: 30, soonDue: 6,  // services/Events.qml
        // Wallpaper
        wallust: true, rotate: false, rotateMin: 30,
        // Not shown in Settings (set from Controls)
        nightTemp: 4500,
        recTarget: "screen", recAudio: "system", recFps: 60,     // screen recording (services/Recorder.qml)
        mediaMode: "player", radioStation: "Radio BUAP",         // Media tab: player / radio / library view (services/Radio.qml)
        mediaLyrics: false,                                      // Media tab: lyrics instead of the big title (services/Lyrics.qml)
        // Top bar (TopBar.qml, bar/, services/BarState.qml)
        barEnabled: true, barStyle: "islands", barHeight: 36, barAccent: "auto",
        barLeft: ["logo", "tray", "workspaces", "window"], barCenter: ["bell", "island", "caffeine"],
        barRight: ["glance", "cpu", "ram", "disk", "temp", "wifi", "bluetooth", "battery", "power"],
        barDetailGap: 200, barScroll: "always",
        barBellCount: true, barBellEvery: 5, barBellFor: 1000,   // the bell shows the count now and then
        barEmptyWs: "show", barWsIcons: true, barDate: true, bar24h: true, barIslandMessages: true,
        // Comms dock (services/Comms.qml): apps kept hidden, shown above the dock by SUPER Y
        commsApps: ["name:WhatsApp Web", "net.thunderbird.Thunderbird", "com.github.IsmaelMartinez.teams_for_linux"]
    })

    property var v: defaults
    property bool loaded: false
    property var lastSnapshot: null           // for undo
    signal changed(string key)

    function set(key, value) {
        if (JSON.stringify(v[key]) === JSON.stringify(value)) return;
        lastSnapshot = v;
        const o = Object.assign({}, v);
        o[key] = value;
        v = o;
        save.restart();
        changed(key);
    }
    function undo() {
        if (!lastSnapshot) return;
        const before = v;
        v = lastSnapshot;
        lastSnapshot = null;
        save.restart();
        for (const k in v) if (JSON.stringify(v[k]) !== JSON.stringify(before[k])) changed(k);
    }
    function reset(sectionId) {
        const sec = sections.find(s => s.id === sectionId);
        if (!sec) return;
        lastSnapshot = v;
        const o = Object.assign({}, v);
        const keys = [];
        for (const g of sec.groups) for (const r of g.rows) if (r.key) { o[r.key] = defaults[r.key]; keys.push(r.key); }
        v = o;
        save.restart();
        for (const k of keys) changed(k);
    }

    // Rofi menus grouped for Appearance → Launchers. `configs`: the
    // config/hypr/rofi/config-*.rasi files of the group, each importing
    // ~/.config/lagos/rofi/<id>.rasi (written by services/LauncherTheme.qml).
    // "apps" is config.rasi itself: SUPER D and every menu without its own config.
    readonly property var launcherGroups: [
        { id: "apps", label: "Apps", configs: [] },
        { id: "clipboard", label: "Clipboard & emoji", configs: ["clipboard", "emoji"] },
        { id: "keybinds", label: "Keybinds", configs: ["keybinds", "emacs-keybinds"] },
        { id: "wallpapers", label: "Wallpapers", configs: ["wallpaper", "wallpaper-effect"] },
        { id: "calc", label: "Calc & search", configs: ["calc", "search"] },
        { id: "other", label: "Other menus", configs: ["Animations", "Monitors", "layout", "edit", "rofi-theme",
            "kitty-theme", "ghostty-theme", "starship", "zsh-theme", "waybar-layout", "waybar-style",
            "rofi-Beats", "rofi-Beats-menu"] }
    ]

    // Places a notification popup can appear (NotificationPopups.qml), or the
    // bar's island (bar/Island.qml: levels and progress as a bar, the rest like
    // a message; top center while the island isn't on the bar)
    readonly property var notifPlaces: [["top", "Top center"], ["top-left", "Top left"], ["top-right", "Top right"], ["bottom-right", "Bottom right"],
                                        ["bottom", "Bottom center"], ["island", "Island (bar)"], ["off", "Don't show (history only)"]]

    // ---------------- Schema ----------------
    // Row types: switch · seg (opts [value, label]) · select (opts [value, label]) ·
    // range (min, max, step, unit: "%", "min", "time", "") · chips (opts: values
    // or [value, label]; multi; `all`: the value meaning "every option", exclusive) ·
    // keys (value: [..]) · info (value or infoKey from SystemSettings.about)
    // Any row: `visibleIf: v => …` (v = Settings.v) shows it only when true.
    readonly property var sections: [
        { id: "appearance", icon: "", label: "Appearance", lead: "How the panel and the Rofi menus look. Changes apply right away.", groups: [
            { title: "Panel & launchers", rows: [
                { key: "mode", label: "Mode", help: "Only the panel and Rofi: apps and browsers keep the system theme", type: "seg",
                  opts: [["system", "Follow system"], ["dark", "Dark"], ["light", "Light"]] },
                { key: "inverted", label: "Palette", help: "Inverted: surfaces take the wallpaper color", type: "seg",
                  opts: [[false, "Normal"], [true, "Inverted"]] },
                { key: "themeScope", label: "Apply to", help: "The rest keeps the default theme (dark, normal)", type: "seg",
                  opts: [["panel", "Panel only"], ["both", "Panel & launchers"], ["launchers", "Launchers only"]] },
                { key: "themeLaunchers", label: "Launchers", help: "Which Rofi menus follow it", type: "chips", all: "all",
                  opts: [["all", "All"]].concat(launcherGroups.map(g => [g.id, g.label])),
                  visibleIf: v => v.themeScope !== "panel" } ] },
            { title: "Panel surface", rows: [
                { key: "opacity", label: "Opacity", help: "Of the panel card · light and inverted modes add a little", type: "range", min: 50, max: 100, step: 1, unit: "%" },
                { key: "blur", label: "Blur", help: "Frosted card, and the screen behind while hovering", type: "switch", system: true },
                { key: "animations", label: "Animations", help: "Color and highlight transitions", type: "switch" } ] },
            { title: "Warnings", rows: [
                { key: "alertMark", label: "Mark warnings", help: "Readings past their limits (CPU, memory, temperature…) are always amber or red. A solid mark makes them stand out on a wallpaper that already has those colors", type: "seg",
                  opts: [["auto", "When the wallpaper has red / amber"], ["always", "Always"], ["never", "Color only"]] },
                { key: "alertShape", label: "Mark", help: "A solid amber / red shape behind the reading", type: "seg",
                  opts: [["pill", "Icon and number"], ["icon", "Icon only"]],
                  visibleIf: v => v.alertMark !== "never" } ] },
            { title: "Menus (rofi)", rows: [
                { key: "rofiPosition", label: "Where menus open", help: "App launcher, keybinds, clipboard, wallpapers… Same look either way", type: "seg",
                  opts: [["bottom", "Slide up from the bottom"], ["center", "Floating, centered"]], system: true } ] } ] },
        { id: "panel", icon: "", label: "Panel", lead: "Where the panel opens and how it closes.", groups: [
            { title: "Behavior", rows: [
                { key: "openTab", label: "Tab when opening", type: "select",
                  opts: [["Overview", "Overview"], ["Notifications", "Notifications"], ["Calendar", "Calendar"], ["Controls", "Controls"]] },
                { key: "closeOutside", label: "Close on a click outside", type: "switch" },
                { key: "dimHover", label: "Dim the screen while hovering", type: "switch" } ] },
            { title: "Size", rows: [
                { key: "width", label: "Width", help: "Share of the usable screen", type: "range", min: 35, max: 80, step: 1, unit: "%" },
                { key: "height", label: "Height", type: "range", min: 35, max: 80, step: 1, unit: "%" } ] } ] },
        { id: "bar", icon: "\uf2d0", label: "Bar", lead: "The bar at the top: how it looks and what it shows. Its colors come from the wallpaper, like the panel's.", groups: [
            { title: "Bar", rows: [
                { key: "barEnabled", label: "Use this bar", help: "Off: waybar comes back (SUPER CTRL ALT B hides or shows this one)", type: "switch", system: true } ] },
            { title: "Look", rows: [
                { key: "barStyle", label: "Style", help: "Islands: each group floats like the panel's cards", type: "seg",
                  opts: [["islands", "Islands"], ["full", "Full bar"], ["floating", "Floating"]] },
                { key: "barHeight", label: "Height", type: "seg", opts: [[32, "32"], [36, "36"], [40, "40"]] },
                { key: "barAccent", label: "Accent", help: "Auto: the panel's. Or any color of the wallpaper's palette", type: "swatches" },
                { key: "barDetailGap", label: "Details: gap to the center (px)", help: "The window title (right after the workspaces) and the music / weather (right before the readings) fill toward the center, stopping this far from the bell and caffeine (the same on both sides)", type: "range", min: 40, max: 320, step: 10, unit: "" },
                { key: "barScroll", label: "Long text", help: "Text that doesn't fit (window title, weather, what's due) scrolls sideways. Only on hover saves resources: it stays still until you point at it, so the bar isn't redrawn on every frame (less CPU and battery)", type: "seg",
                  opts: [["always", "Scroll"], ["hover", "Only on hover"]] } ] },
            { title: "Modules", rows: [
                { key: "barLeft", label: "Left", type: "chips", opts: [["logo", "Logo"], ["tray", "Tray"], ["workspaces", "Workspaces"], ["window", "Window / weather"]] },
                { key: "barCenter", label: "Center", help: "The island stays at the exact center of the screen", type: "chips",
                  opts: [["bell", "Notifications"], ["island", "Island"], ["caffeine", "Caffeine"]] },
                { key: "barRight", label: "Right", help: "Click the stats, network or battery for the system popup", type: "chips",
                  opts: [["glance", "Reminder / music"], ["cpu", "CPU"], ["ram", "RAM"], ["disk", "Disk"], ["temp", "Temp"], ["wifi", "Wi-Fi"],
                         ["bluetooth", "Bluetooth"], ["battery", "Battery"], ["power", "Power"]] } ] },
            { title: "Workspaces and clock", rows: [
                { key: "barEmptyWs", label: "Empty workspaces", type: "seg", opts: [["hide", "Hide"], ["show", "Show 1–5"]] },
                { key: "barWsIcons", label: "Icons of the apps on each workspace", type: "switch" },
                { key: "barDate", label: "Date next to the time", type: "switch" },
                { key: "bar24h", label: "24-hour clock", type: "switch" } ] },
            { title: "Notifications bell", rows: [
                { key: "barBellCount", label: "Show the count now and then", help: "While there are notifications, the number takes the bell's place for a moment (a new one always shows it)", type: "switch" },
                { key: "barBellEvery", label: "Every", type: "select", opts: [[3, "3 s"], [5, "5 s"], [10, "10 s"], [30, "30 s"], [60, "1 min"]] },
                { key: "barBellFor", label: "For", type: "select", opts: [[500, "0.5 s"], [1000, "1 s"], [2000, "2 s"], [3000, "3 s"]] } ] },
            { title: "Island", rows: [
                { key: "barIslandMessages", label: "Messages on the island", help: "Chat messages stretch the island with the chat's photo instead of a popup. Hover: the whole message, Reply and Open", type: "switch" } ] } ] },
        { id: "notifications", icon: "", label: "Notifications", lead: "Where popups appear, quiet hours and history.", groups: [
            { title: "Look", rows: [
                { key: "notifTheme", label: "Colors", help: "Of the popups. Critical ones keep their dark look", type: "select",
                  opts: [["panel", "Same as the panel"], ["system", "Same as the system"], ["dark", "Dark"], ["light", "Light"], ["inverted", "Inverted"]] },
                { label: "Try them", help: "A test notification of each kind, to see the look and where it appears. Demo: all of them one after another, for a video (scripts/wm/NotifDemo.sh)", type: "notiftests" } ] },
            { title: "Where popups appear", rows: [
                { key: "posCall", label: "Calls", help: "Incoming calls ring until answered or declined", type: "select", opts: notifPlaces.filter(o => o[0] !== "off" && o[0] !== "island") },
                { key: "posSecurity", label: "Security codes", help: "2FA / login codes (with a Copy button), sign-in alerts, password prompts", type: "select", opts: notifPlaces.filter(o => o[0] !== "island") },
                { key: "posReminder", label: "Reminders", help: "Calendar events: they stay until dismissed", type: "select", opts: notifPlaces },
                { key: "posLevel", label: "Volume", help: "Level bars: volume and mic", type: "select", opts: notifPlaces },
                { key: "posBrightness", label: "Brightness", help: "The screen's and the keyboard's level bars", type: "select", opts: notifPlaces },
                { key: "posSystem", label: "System", help: "Battery, network, devices, screenshots, recordings, scripts", type: "select", opts: notifPlaces },
                { key: "posMessage", label: "Messages", help: "WhatsApp, Telegram, Teams, Discord, email…", type: "select", opts: notifPlaces },
                { key: "posMedia", label: "Now playing", help: "Track changes from Spotify and other players", type: "select", opts: notifPlaces },
                { key: "posProgress", label: "Progress", help: "Downloads, copies, updates: a bar that fills in place", type: "select", opts: notifPlaces },
                { key: "posApp", label: "Other apps", help: "Browser and everything else", type: "select", opts: notifPlaces },
                { label: "Critical", help: "Always at the top center, so they can't be missed", type: "info", value: "Top center" },
                { key: "maxPopups", label: "At most per place", help: "More wait their turn, newest first", type: "range", min: 1, max: 6, step: 1, unit: "" } ] },
            { title: "Behavior", rows: [
                { key: "groupMessages", label: "Group messages by conversation", help: "One card per chat (“Ana · 3 messages”); each one stays in the history", type: "switch" },
                { key: "msgPicture", label: "Picture on messages", help: "The chat's photo, with the app's icon on its corner, or just the app's icon. Chats without a photo show the icon", type: "seg",
                  opts: [["photo", "Chat photo"], ["icon", "App icon"]] },
                { key: "callsThroughDnd", label: "Calls ring through Do Not Disturb", type: "switch" },
                { key: "downloadsThroughDnd", label: "Finished downloads show through Do Not Disturb", help: "You started them, so you're waiting for them (category transfer.complete)", type: "switch" } ] },
            { title: "Per app", rows: [
                { key: "appRules", label: "Rules", help: "Send an app elsewhere, history only, or mute it. Apps show up here after their first notification", type: "apprules" } ] },
            { title: "Do Not Disturb", rows: [
                { key: "dndSched", label: "Turn on automatically", help: "Every day, during the hours below", type: "switch" },
                { key: "dndWindow", label: "Quiet hours", type: "select",
                  opts: [["22:00-07:00", "22:00 – 07:00"], ["23:00-07:00", "23:00 – 07:00"], ["00:00-08:00", "00:00 – 08:00"], ["01:00-09:00", "01:00 – 09:00"]] },
                { key: "critical", label: "Let critical notifications through", type: "switch" } ] },
            { title: "Popups and history", rows: [
                { key: "popupSecs", label: "Popup duration", help: "Low urgency: half; critical: 30 s", type: "select",
                  opts: [[3, "3 s"], [6, "6 s"], [10, "10 s"], [0, "Until dismissed"]] },
                { key: "history", label: "Keep in history", help: "Oldest ones are removed", type: "range", min: 10, max: 300, step: 10, unit: "" } ] } ] },
        { id: "comms", icon: "\uf27a", label: "Comms dock",
          lead: "Messaging and mail apps kept running out of sight, so their notifications arrive. SUPER Y shows them full screen above a dock.", groups: [
            { title: "Apps", rows: [
                { key: "commsApps", label: "In the dock", help: "Each opens hidden at login, in its own workspace. Remove one and its window comes back to the current workspace", type: "commsapps" } ] } ] },
        { id: "startup", icon: "\uf135", label: "Startup apps", system: true,
          lead: "What opens on its own when you log in, and what it holds right now. Off takes effect from the next login; ■ stops it now. Also in the tray's Startup view.", groups: [
            { title: "Apps", rows: [
                { label: "Start at login", help: "XDG autostart: ~/.config/autostart over /etc/xdg/autostart (off: Hidden=true in your copy)", type: "startupapps", kind: "xdg" } ] },
            { title: "Started by Hyprland", rows: [
                { label: "Your startup commands", help: "startup_commands in UserConfigs/user_startup.lua: off comments the line out, and Hyprland reloads its config. The panel's own line stays", type: "startupapps", kind: "hypr" } ] } ] },
        { id: "power", icon: "", label: "Power & idle", system: true,
          lead: "Idle timeouts (hypridle), what closing the lid does, battery alerts and the power profile.", groups: [
            { title: "When idle", rows: [
                { key: "dim", label: "Dim the screen after", type: "range", min: 60, max: 1800, step: 30, unit: "time", system: true },
                { key: "warn", label: "“You are idle” notice after", type: "range", min: 60, max: 1800, step: 30, unit: "time", system: true },
                { key: "lock", label: "Lock after", type: "range", min: 120, max: 3600, step: 30, unit: "time", system: true },
                { key: "screenOff", label: "Turn the screen off after", type: "range", min: 120, max: 3600, step: 30, unit: "time", system: true },
                { key: "suspend", label: "Suspend after", type: "range", min: 300, max: 7200, step: 60, unit: "time", system: true },
                { key: "mediaGuard", label: "Not while media is playing", help: "Skip lock, screen off and suspend", type: "switch", system: true } ] },
            { title: "Closing the lid", rows: [
                { key: "lidBattery", label: "On battery", type: "select", system: true,
                  opts: [["suspend", "Suspend"], ["lock", "Lock and turn the screen off"], ["screenoff", "Only turn the screen off"]] },
                { key: "lidAc", label: "Plugged in", type: "select", system: true,
                  opts: [["suspend", "Suspend"], ["lock", "Lock and turn the screen off"], ["screenoff", "Only turn the screen off"]] },
                { key: "lidDocked", label: "With an external monitor", help: "Unplugging the monitor with the lid closed does what's chosen above", type: "select", system: true,
                  opts: [["nothing", "Keep working on the monitor"], ["lock", "Lock"], ["suspend", "Suspend"]] },
                { label: "Handled by", help: "lagos-lid.service. Without it (or outside Hyprland) logind decides: suspend on battery, nothing when plugged in", type: "info", infoKey: "lidService" } ] },
            { title: "Battery", rows: [
                { key: "battery", label: "Alert at", help: "10% and below show a big popup", type: "chips", opts: [50, 30, 20, 15, 10, 5], unit: "%", system: true },
                { key: "loginProfile", label: "Power profile at login", type: "select",
                  opts: [["keep", "Keep the last one"], ["power-saver", "Power saver"], ["balanced", "Balanced"], ["performance", "Performance"]] } ] } ] },
        { id: "weather", icon: "", label: "Weather & calendar", lead: "Where the weather is for, the calendar, reminders of what's due and quick capture.", groups: [
            { title: "Weather", rows: [
                // Units are not here: the weather cache is shared with waybar, which
                // takes them from $WEATHER_UNITS (Hyprland startup)
                { label: "Home location", help: "~/.config/lagos/weather-home", type: "info", infoKey: "weatherHome" } ] },
            { title: "Calendar", rows: [
                { key: "weekStart", label: "Week starts on", type: "seg", opts: [[0, "Sunday"], [1, "Monday"]] },
                { key: "calRefresh", label: "Refresh events every", type: "select", opts: [[15, "15 min"], [30, "30 min"], [60, "1 hour"]] },
                { label: "Sources", help: "Evolution webcal + ~/.config/lagos/calendars/*.ics", type: "info", infoKey: "calendars" } ] },
            { title: "Reminders", rows: [
                { key: "dueStages", label: "Remind me of what's due", help: "Before each to-do with a date and each Teams assignment; when overdue too. Each stays until you answer: Done · In 1 h · Tomorrow", type: "chips",
                  opts: [[10080, "1 week"], [4320, "3 days"], [1440, "1 day"], [180, "3 h"], [60, "1 h"], [30, "30 min"]] },
                { key: "briefOn", label: "Morning brief", help: "Today's events, what's due and the open to-dos, once a day", type: "switch" },
                { key: "briefHour", label: "Morning brief at", help: "Or the first time you turn on the computer after it", type: "select",
                  opts: [[5, "5:00"], [6, "6:00"], [7, "7:00"], [8, "8:00"], [9, "9:00"], [10, "10:00"]], visibleIf: v => v.briefOn },
                { key: "soonEvent", label: "Events on the bar", help: "The left of the bar shows the next one this long before it starts (instead of the window title)", type: "select",
                  opts: [[0, "Never"], [15, "15 min before"], [30, "30 min before"], [60, "1 h before"]] },
                { key: "soonDue", label: "Deadlines on the bar", help: "The left of the bar shows what's due this long before (overdue ones always)", type: "select",
                  opts: [[0, "Only overdue"], [3, "3 h before"], [6, "6 h before"], [12, "12 h before"], [24, "1 day before"]] } ] },
            { title: "Quick capture", rows: [
                { label: "Add anything", help: "SUPER Z: one line in your words (“entregar reporte viernes 18:00”, “clase mañana de 10 a 12 @ CCO3 310”, “pagar la luz cada mes”). SUPER SHIFT Z: the selected text. Notifications have an Add button", type: "info", value: "SUPER Z" } ] } ] },
        { id: "wallpaper", icon: "", label: "Wallpaper", lead: "Wallpaper folder and automatic changes.", groups: [
            { title: "Wallpaper", rows: [
                { label: "Folder", type: "info", infoKey: "wallpaperDir", mono: true },
                { label: "Current", type: "info", infoKey: "wallpaper", mono: true },
                { key: "wallust", label: "Take colors from the wallpaper", help: "wallust → panel, waybar, rofi, kitty, borders. Off keeps the current colors", type: "switch", system: true },
                { key: "rotate", label: "Change automatically", help: "A random one from the folder", type: "switch" },
                { key: "rotateMin", label: "Every", type: "select", opts: [[15, "15 min"], [30, "30 min"], [60, "1 hour"], [180, "3 hours"]] } ] } ] },
        { id: "keyboard", icon: "", label: "Keyboard", lead: "Shortcuts (read-only; edit them in UserConfigs/user_keybinds.lua).", groups: [
            { title: "Panel", rows: [
                { label: "Open or close the panel", type: "keys", value: ["SUPER", "ALT", "N"] },
                { label: "Notifications", type: "keys", value: ["SUPER", "SHIFT", "N"] },
                { label: "Next / previous tab", type: "keys", value: ["CTRL", "TAB"] },
                { label: "Jump to a tab", type: "keys", value: ["CTRL", "1…7"] },
                { label: "Back / close", type: "keys", value: ["ESC"] } ] },
            { title: "Desktop", rows: [
                { label: "Night light", type: "keys", value: ["SUPER", "N"] },
                { label: "Choose a wallpaper", type: "keys", value: ["SUPER", "W"] },
                { label: "All shortcuts (searchable)", type: "keys", value: ["SUPER", "H"] } ] } ] },
        { id: "about", icon: "", label: "About", lead: "This computer and this setup.", groups: [
            { title: "Device", rows: [
                { label: "Model", type: "info", infoKey: "model" },
                { label: "Processor", type: "info", infoKey: "cpu" },
                { label: "Graphics", type: "info", infoKey: "gpu" },
                { label: "Memory", type: "info", infoKey: "memory" } ] },
            { title: "Software", rows: [
                { label: "System", type: "info", infoKey: "os" },
                { label: "Kernel", type: "info", infoKey: "kernel", mono: true },
                { label: "Hyprland · Quickshell", type: "info", infoKey: "versions", mono: true },
                { label: "Dotfiles", type: "info", infoKey: "dotfiles", mono: true } ] } ] }
    ]

    // ---------------- Storage ----------------
    readonly property string dir: Quickshell.env("HOME") + "/.config/lagos"

    Timer {
        id: save
        interval: 300
        onTriggered: {
            Quickshell.execDetached(["mkdir", "-p", root.dir]);
            file.setText(JSON.stringify(root.v, null, 2));
        }
    }
    function load(o) {
        // Unknown keys are dropped, missing ones take the default
        const out = Object.assign({}, defaults);
        for (const k in defaults) if (o && o[k] !== undefined) out[k] = o[k];
        v = out;
        loaded = true;
    }
    // The settings file, or on first run the old panel-theme.json (mode/inverted)
    property string fileState: "pending"       // pending | ok | missing
    property string legacyState: "pending"
    property var legacyValues: ({})
    function settle() {
        if (loaded || fileState === "pending") return;
        if (fileState === "missing" && legacyState !== "pending") { load(legacyValues); save.restart(); }
    }
    FileView {
        id: file
        path: root.dir + "/panel-settings.json"
        atomicWrites: true
        printErrors: false
        onLoaded: {
            if (root.loaded) return;
            root.fileState = "ok";
            try { root.load(JSON.parse(text())); } catch (e) { root.load({}); }
        }
        onLoadFailed: { root.fileState = "missing"; root.settle(); }
    }
    FileView {
        path: root.dir + "/panel-theme.json"
        printErrors: false
        onLoaded: {
            try { const t = JSON.parse(text()); root.legacyValues = { mode: t.mode, inverted: !!t.inverted }; } catch (e) {}
            root.legacyState = "ok";
            root.settle();
        }
        onLoadFailed: { root.legacyState = "missing"; root.settle(); }
    }
}
