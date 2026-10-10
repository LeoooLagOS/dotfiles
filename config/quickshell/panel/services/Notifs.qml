pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../common"

// The notification daemon (replaces swaync): receives every notification,
// keeps the history, shows popups (unless Do Not Disturb) and tells waybar
// about the count / DND state.
Singleton {
    id: root

    property bool dnd: false
    // Do Not Disturb with an end: a Date, or null = until turned off
    property var dndUntil: null
    property bool dndScheduled: false       // turned on by the quiet-hours schedule
    property var popups: []                 // notifications currently shown as popups
    property var received: ({})             // notification id → Date received

    // Newest first
    readonly property var list: server.trackedNotifications.values.slice().reverse()
    readonly property int count: list.length

    // Popup durations (ms): Settings → Notifications (0 = until dismissed);
    // low urgency stays half as long, critical 30 s
    function timeoutFor(n) {
        if (n.urgency === NotificationUrgency.Critical) return 30000;
        const s = Settings.v.popupSecs * 1000;
        if (s === 0) return 0;
        return n.urgency === NotificationUrgency.Low ? Math.max(2000, s / 2) : s;
    }

    function timeAgo(n) {
        const t = n ? received[n.id] : null;
        if (!t) return "";
        const s = Math.floor((clock.date - t) / 1000);
        if (s < 60) return "now";
        if (s < 3600) return Math.floor(s / 60) + "m";
        if (s < 86400) return Math.floor(s / 3600) + "h";
        return Qt.formatDate(t, "MMM d");
    }

    // --- Classify / search / sort (Notifications tab) ---

    // Apps treated as messaging, besides the "im.*" / "email.*" categories
    readonly property var messagingApps: ["discord", "vesktop", "telegram", "whatsapp", "signal", "slack",
                                          "element", "teams", "thunderbird", "evolution", "geary", "mail"]
    readonly property var systemApps: ["notify-send", "networkmanager", "nm-applet", "blueman", "battery",
                                       "udiskie", "power", "system", "hyprland", "swappy", "grim"]

    // "critical" | "message" | "system" | "app"
    function kind(n) {
        if (n.urgency === NotificationUrgency.Critical) return "critical";
        const cat = String(n.hints?.category ?? "").toLowerCase();
        const app = (n.appName || "").toLowerCase();
        if (cat.startsWith("im") || cat.startsWith("email") || messagingApps.some(a => app.includes(a))) return "message";
        if (cat.startsWith("device") || cat.startsWith("network") || systemApps.some(a => app.includes(a))) return "system";
        return "app";
    }

    function plain(s) { return String(s ?? "").replace(/<[^>]*>/g, ""); }

    function matches(n, query) {
        if (!query) return true;
        const q = query.toLowerCase();
        return [n.appName, n.summary, plain(n.body)].some(t => String(t ?? "").toLowerCase().includes(q));
    }

    // filter: "all" | "critical" | "message" | "system" | "app" | "app:<name>"
    function select(filter, query, sort) {
        let out = list.filter(n => matches(n, query) && (
            filter === "all" ? true
            : filter.startsWith("app:") ? (n.appName || "Other") === filter.slice(4)
            : kind(n) === filter));
        const t = n => received[n.id]?.getTime() ?? 0;
        const rank = n => n.urgency === NotificationUrgency.Critical ? 0 : n.urgency === NotificationUrgency.Normal ? 1 : 2;
        if (sort === "oldest") out.sort((a, b) => t(a) - t(b));
        else if (sort === "app") out.sort((a, b) => (a.appName || "").localeCompare(b.appName || "") || t(b) - t(a));
        else if (sort === "urgency") out.sort((a, b) => rank(a) - rank(b) || t(b) - t(a));
        else out.sort((a, b) => t(b) - t(a));
        return out;
    }

    readonly property var apps: [...new Set(list.map(n => n.appName || "Other"))].sort()

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
        // Transient notifications are not kept in the history
        if (n && n.transient) n.expire();
    }
    function dismiss(n) { n.dismiss(); }
    function clearAll() { for (const n of list.slice()) n.dismiss(); }
    function toggleDnd() { setDnd(!dnd, null); }
    // until: Date or null (until turned off)
    function setDnd(on, until) {
        dndUntil = on ? until : null;
        dndScheduled = false;
        dnd = on;
    }
    // "For 1 hour" / "Until tomorrow" (07:00) / null
    function dndFor(what) {
        const d = new Date();
        if (what === "1h") d.setHours(d.getHours() + 1);
        else if (what === "tomorrow") { d.setDate(d.getDate() + 1); d.setHours(7, 0, 0, 0); }
        else return setDnd(true, null);
        setDnd(true, d);
    }
    readonly property string dndStatus: !dnd ? "Off"
        : dndScheduled ? "Quiet hours"
        : dndUntil ? "Until " + Qt.formatTime(dndUntil, "HH:mm") + (dndUntil.getDate() !== clock.date.getDate() ? " tomorrow" : "")
        : "Until turned off"

    // Every minute: end a timed DND, and follow the quiet-hours schedule
    function inQuietHours(now) {
        const [from, to] = Settings.v.dndWindow.split("-").map(t => { const [h, m] = t.split(":"); return +h * 60 + +m; });
        const m = now.getHours() * 60 + now.getMinutes();
        return from <= to ? (m >= from && m < to) : (m >= from || m < to);
    }
    function tick() {
        const now = clock.date;
        if (dnd && dndUntil && now >= dndUntil) setDnd(false, null);
        const quiet = Settings.v.dndSched && inQuietHours(now);
        if (quiet && !dnd) { dnd = true; dndScheduled = true; dndUntil = null; }
        else if (!quiet && dnd && dndScheduled) { dnd = false; dndScheduled = false; }
    }
    Connections {
        target: Settings
        function onChanged(key) { if (key === "dndSched" || key === "dndWindow") root.tick(); }
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            const r = Object.assign({}, root.received);
            r[n.id] = new Date();
            root.received = r;
            if (!root.dnd || (Settings.v.critical && n.urgency === NotificationUrgency.Critical))
                root.popups = root.popups.concat([n]);
        }
    }

    // Drop closed notifications from the popup list, and the oldest ones beyond
    // the history limit (Settings → Notifications)
    onListChanged: {
        if (list.length > Settings.v.history) for (const n of list.slice(Settings.v.history)) n.dismiss();
        const alive = popups.filter(p => list.includes(p));
        if (alive.length !== popups.length) popups = alive;
    }

    // Ticks once a minute so "5m ago" labels update
    SystemClock { id: clock; precision: SystemClock.Minutes; onDateChanged: root.tick() }

    // --- Persist Do Not Disturb across restarts ---
    FileView {
        id: dndFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell-panel/dnd"
        onLoaded: root.dnd = text().trim() === "1"
        onLoadFailed: root.dnd = false
    }
    onDndChanged: {
        Quickshell.execDetached(["bash", "-c",
            "mkdir -p ~/.local/state/quickshell-panel && echo " + (dnd ? 1 : 0) + " > ~/.local/state/quickshell-panel/dnd"]);
        waybarState.restart();
    }
    onCountChanged: waybarState.restart()

    // --- Waybar: write the state and signal the custom/swaync module ---
    Timer {
        id: waybarState
        interval: 100
        onTriggered: Quickshell.execDetached(["bash", "-c",
            "mkdir -p ~/.cache/quickshell-panel && printf '%s %s\\n' " + root.count + " " + (root.dnd ? 1 : 0)
            + " > ~/.cache/quickshell-panel/notifs && pkill -RTMIN+11 waybar"])
    }
    Component.onCompleted: waybarState.start()
}
