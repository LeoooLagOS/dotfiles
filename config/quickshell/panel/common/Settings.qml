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
        // Appearance
        mode: "system", inverted: false, opacity: 72, blur: true, animations: true, rofiPosition: "bottom",
        // Panel
        openTab: "Overview", closeOutside: true, dimHover: true, width: 50, height: 50,
        // Notifications
        dndSched: false, dndWindow: "23:00-07:00", critical: true, popupSecs: 6, history: 100,
        // Power & idle (system)
        dim: 300, warn: 540, lock: 600, screenOff: 630, suspend: 1200, mediaGuard: true,
        battery: [50, 20, 10, 5], loginProfile: "keep",
        // Weather & calendar
        weekStart: 0, calRefresh: 30,
        // Wallpaper
        wallust: true, rotate: false, rotateMin: 30,
        // Not shown in Settings (set from Controls)
        nightTemp: 4500
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

    // ---------------- Schema ----------------
    // Row types: switch · seg (opts [value, label]) · select (opts [value, label]) ·
    // range (min, max, step, unit: "%", "min", "time", "") · chips (opts, multi) ·
    // keys (value: [..]) · info (value or infoKey from SystemSettings.about)
    readonly property var sections: [
        { id: "appearance", icon: "", label: "Appearance", lead: "How the panel looks. Changes apply right away.", groups: [
            { title: "Theme", rows: [
                { key: "mode", label: "Default mode", help: "System follows DarkLight.sh", type: "seg",
                  opts: [["system", "System"], ["dark", "Dark"], ["light", "Light"]] },
                { key: "inverted", label: "Inverted palette", help: "Surfaces take the wallpaper color", type: "switch" } ] },
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
        { id: "notifications", icon: "", label: "Notifications", lead: "Popups, history and quiet hours.", groups: [
            { title: "Do Not Disturb", rows: [
                { key: "dndSched", label: "Turn on automatically", help: "Every day, during the hours below", type: "switch" },
                { key: "dndWindow", label: "Quiet hours", type: "select",
                  opts: [["22:00-07:00", "22:00 – 07:00"], ["23:00-07:00", "23:00 – 07:00"], ["00:00-08:00", "00:00 – 08:00"], ["01:00-09:00", "01:00 – 09:00"]] },
                { key: "critical", label: "Let critical notifications through", type: "switch" } ] },
            { title: "Popups and history", rows: [
                { key: "popupSecs", label: "Popup duration", help: "Low urgency: half; critical: 30 s", type: "select",
                  opts: [[3, "3 s"], [6, "6 s"], [10, "10 s"], [0, "Until dismissed"]] },
                { key: "history", label: "Keep in history", help: "Oldest ones are removed", type: "range", min: 10, max: 300, step: 10, unit: "" } ] } ] },
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
