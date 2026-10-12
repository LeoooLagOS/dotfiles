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
        mode: "system", inverted: false, themeScope: "both", themeLaunchers: ["all"], opacity: 72, blur: true, animations: true, rofiPosition: "bottom",
        // Panel
        openTab: "Overview", closeOutside: true, dimHover: true, width: 50, height: 50,
        // Notifications
        dndSched: false, dndWindow: "23:00-07:00", critical: true, popupSecs: 6, history: 100,
        // Where popups appear, per type (services/Notifs.qml placeKind)
        posLevel: "top", posSystem: "top", posMessage: "bottom-right", posMedia: "top-right", posApp: "top-right",
        posCall: "top-left", posSecurity: "top", posReminder: "top-right", posProgress: "top-right",
        maxPopups: 3, groupMessages: true, callsThroughDnd: true,
        appRules: ({}),                                           // appName → place | "off" | "mute"
        // Power & idle (system)
        dim: 300, warn: 540, lock: 600, screenOff: 630, suspend: 1200, mediaGuard: true,
        battery: [50, 20, 10, 5], loginProfile: "keep",
        // Weather & calendar
        weekStart: 0, calRefresh: 30,
        // Wallpaper
        wallust: true, rotate: false, rotateMin: 30,
        // Not shown in Settings (set from Controls)
        nightTemp: 4500,
        recTarget: "screen", recAudio: "system", recFps: 60,     // screen recording (services/Recorder.qml)
        mediaMode: "player", radioStation: "Radio BUAP",         // Media tab: player / radio / library view (services/Radio.qml)
        mediaLyrics: false,                                      // Media tab: lyrics instead of the big title (services/Lyrics.qml)
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

    // Places a notification popup can appear (NotificationPopups.qml)
    readonly property var notifPlaces: [["top", "Top center"], ["top-left", "Top left"], ["top-right", "Top right"], ["bottom-right", "Bottom right"],
                                        ["bottom", "Bottom center"], ["off", "Don't show (history only)"]]

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
        { id: "notifications", icon: "", label: "Notifications", lead: "Where popups appear, quiet hours and history.", groups: [
            { title: "Where popups appear", rows: [
                { key: "posCall", label: "Calls", help: "Incoming calls ring until answered or declined", type: "select", opts: notifPlaces.filter(o => o[0] !== "off") },
                { key: "posSecurity", label: "Security codes", help: "2FA / login codes (with a Copy button), sign-in alerts, password prompts", type: "select", opts: notifPlaces },
                { key: "posReminder", label: "Reminders", help: "Calendar events: they stay until dismissed", type: "select", opts: notifPlaces },
                { key: "posLevel", label: "Volume & brightness", help: "Level bars: volume, mic, brightness", type: "select", opts: notifPlaces },
                { key: "posSystem", label: "System", help: "Battery, network, devices, screenshots, recordings, scripts", type: "select", opts: notifPlaces },
                { key: "posMessage", label: "Messages", help: "WhatsApp, Telegram, Teams, Discord, email…", type: "select", opts: notifPlaces },
                { key: "posMedia", label: "Now playing", help: "Track changes from Spotify and other players", type: "select", opts: notifPlaces },
                { key: "posProgress", label: "Progress", help: "Downloads, copies, updates: a bar that fills in place", type: "select", opts: notifPlaces },
                { key: "posApp", label: "Other apps", help: "Browser and everything else", type: "select", opts: notifPlaces },
                { label: "Critical", help: "Always at the top center, so they can't be missed", type: "info", value: "Top center" },
                { key: "maxPopups", label: "At most per place", help: "More wait their turn, newest first", type: "range", min: 1, max: 6, step: 1, unit: "" } ] },
            { title: "Behavior", rows: [
                { key: "groupMessages", label: "Group messages by conversation", help: "One card per chat (“Ana · 3 messages”); each one stays in the history", type: "switch" },
                { key: "callsThroughDnd", label: "Calls ring through Do Not Disturb", type: "switch" } ] },
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
        { id: "power", icon: "", label: "Power & idle", system: true,
          lead: "Idle timeouts (hypridle), battery alerts and the power profile.", groups: [
            { title: "When idle", rows: [
                { key: "dim", label: "Dim the screen after", type: "range", min: 60, max: 1800, step: 30, unit: "time", system: true },
                { key: "warn", label: "“You are idle” notice after", type: "range", min: 60, max: 1800, step: 30, unit: "time", system: true },
                { key: "lock", label: "Lock after", type: "range", min: 120, max: 3600, step: 30, unit: "time", system: true },
                { key: "screenOff", label: "Turn the screen off after", type: "range", min: 120, max: 3600, step: 30, unit: "time", system: true },
                { key: "suspend", label: "Suspend after", type: "range", min: 300, max: 7200, step: 60, unit: "time", system: true },
                { key: "mediaGuard", label: "Not while media is playing", help: "Skip lock, screen off and suspend", type: "switch", system: true } ] },
            { title: "Battery", rows: [
                { key: "battery", label: "Alert at", help: "10% and below show a big popup", type: "chips", opts: [50, 30, 20, 15, 10, 5], unit: "%", system: true },
                { key: "loginProfile", label: "Power profile at login", type: "select",
                  opts: [["keep", "Keep the last one"], ["power-saver", "Power saver"], ["balanced", "Balanced"], ["performance", "Performance"]] } ] } ] },
        { id: "weather", icon: "", label: "Weather & calendar", lead: "Where the weather is for, the week start and how often events refresh.", groups: [
            { title: "Weather", rows: [
                // Units are not here: the weather cache is shared with waybar, which
                // takes them from $WEATHER_UNITS (Hyprland startup)
                { label: "Home location", help: "~/.config/lagos/weather-home", type: "info", infoKey: "weatherHome" } ] },
            { title: "Calendar", rows: [
                { key: "weekStart", label: "Week starts on", type: "seg", opts: [[0, "Sunday"], [1, "Monday"]] },
                { key: "calRefresh", label: "Refresh events every", type: "select", opts: [[15, "15 min"], [30, "30 min"], [60, "1 hour"]] },
                { label: "Sources", help: "Evolution webcal + ~/.config/lagos/calendars/*.ics", type: "info", infoKey: "calendars" } ] } ] },
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
