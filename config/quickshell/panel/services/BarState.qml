pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// State of the top bar (TopBar.qml, bar/).
//   enabled    which bar runs: this one, or waybar. Source of truth:
//              ~/.config/lagos/bar ("quickshell" | "waybar"; missing = this one),
//              written by scripts/wm/BarSwitch.sh, which also stops / starts
//              waybar; WaybarStartup.sh and Refresh.sh read it too. Settings →
//              Bar → "Use this bar" runs the script.
//   popup      the system popup (bar/SystemPopup.qml) open, on which monitor
//   startOn    the start menu (bar/StartMenu.qml) open, on which monitor
//   flash      a short message the island shows (Do Not Disturb, caffeine…)
Singleton {
    id: root

    readonly property string stateFile: Quickshell.env("HOME") + "/.config/lagos/bar"
    property bool enabled: true
    FileView {
        id: stateView
        path: root.stateFile
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { root.enabled = text().trim() !== "waybar"; if (Settings.loaded) Settings.set("barEnabled", root.enabled); }
        onLoadFailed: { root.enabled = true; if (Settings.loaded) Settings.set("barEnabled", true); }
    }
    Connections {
        target: Settings
        function onLoadedChanged() { if (Settings.loaded) Settings.set("barEnabled", root.enabled); }
        function onChanged(key) {
            if (key === "barEnabled" && Settings.v.barEnabled !== root.enabled)
                Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/BarSwitch.sh", Settings.v.barEnabled ? "quickshell" : "waybar"]);
        }
    }

    // Modules shown, per zone, in this order (Settings → Bar → Modules)
    readonly property var allModules: ({
        left: [["logo", Tr.t("Logo")], ["workspaces", Tr.t("Workspaces")], ["window", Tr.t("Window / weather")]],
        center: [["bell", Tr.t("Notifications")], ["island", Tr.t("Island")], ["caffeine", Tr.t("Caffeine")]],
        right: [["tray", Tr.t("Tray")], ["cpu", "CPU"], ["ram", "RAM"], ["disk", "Disk"], ["temp", Tr.t("Temperature")],
                ["wifi", "Wi-Fi"], ["bluetooth", "Bluetooth"], ["battery", Tr.t("Battery")], ["power", Tr.t("Power")]]
    })
    function shown(id) {
        for (const z of ["barLeft", "barCenter", "barRight"]) if ([].concat(Settings.v[z] ?? []).includes(id)) return true;
        return false;
    }
    // The stats poll fast only while the bar shows one of them
    readonly property bool statsShown: enabled && ["cpu", "ram", "disk", "temp"].some(id => shown(id))

    // The bar's accent: the panel's, or a wallust color (Settings → Bar → Accent)
    readonly property color accent: Settings.v.barAccent === "auto" || !Theme.palette[Settings.v.barAccent]
        ? Theme.accent : Theme.palette[Settings.v.barAccent]
    readonly property color accentText: Settings.v.barAccent === "auto" ? Theme.accentText : Theme.onColor(accent)

    // SUPER CTRL ALT B (IPC barToggle): hide / show the bar for now
    signal toggleRequested()

    // System popup (network, Bluetooth, battery) and system monitor (the
    // readings): open on one monitor ("" = closed), one at a time
    property string popupOn: ""
    property string monitorOn: ""
    function togglePopup(monitor) { monitorOn = ""; startOn = ""; popupOn = popupOn === monitor ? "" : monitor; }
    function toggleMonitor(monitor) { popupOn = ""; startOn = ""; monitorOn = monitorOn === monitor ? "" : monitor; }
    // Start menu (bar/StartMenu.qml): the logo's click, or IPC `start`
    property string startOn: ""
    function toggleStart(monitor) { popupOn = ""; monitorOn = ""; startOn = startOn === monitor ? "" : monitor; }
    Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) { root.popupOn = ""; root.monitorOn = ""; root.startOn = ""; } } }

    // ---------------- Messages on the island ----------------
    // Instead of a popup (services/Notifs.qml arrive): what it shows is copied
    // now, since the app may close its notification any moment (WhatsApp does);
    // `notif` stays for Reply / Open while it lives. Same chat again: counted.
    // Hovering the island holds it (messageHold).
    readonly property bool takesMessages: enabled && !!Settings.v.barIslandMessages && shown("island")
    property var message: null              // { notif, who, body, photo, icon, app, key, count }
    property bool messageHold: false
    function showMessage(n) {
        const key = Notifs.conversationOf(n);
        const same = message && message.key === key;
        message = { notif: n, who: Notifs.titleOf(n), body: Notifs.plain(Notifs.bodyOf(n)).replace(/\s+/g, " ").trim(),
                    photo: Settings.v.msgPicture !== "icon" ? Notifs.photoOf(n) : "", icon: Notifs.appIconOf(n),
                    app: Notifs.appLabel(n), key: key, count: same ? message.count + 1 : 1 };
        messageTimer.restart();
    }
    function clearMessage() { message = null; messageHold = false; }
    Timer { id: messageTimer; interval: 6000; onTriggered: if (root.messageHold) restart(); else root.message = null }
    // The notification may be gone (closed by its app): then only Open's dock part works
    function messageNotif() { try { return message?.notif && message.notif.id !== undefined ? message.notif : null; } catch (e) { return null; } }
    function openMessage() {
        const n = messageNotif(), m = message;
        clearMessage();
        if (n) {
            const def = (n.actions ?? []).find(a => a.identifier === "default");
            const chat = Notifs.chatOf(n);
            Comms.showFor(n);
            if (def) def.invoke();
            Notifs.dismissAll(chat);
        }
    }
    function replyMessage() {
        const n = messageNotif();
        clearMessage();
        if (n && Comms.canReply(n)) Comms.startReply(n);
    }

    // ---------------- Levels on the island ----------------
    // Volume, brightness, progress… placed on the island (Settings → Notifications
    // → Where popups appear; Notifs.placeOf): icon · title · bar · percentage.
    // `level` is the notification (or the panel's own level object, Notifs.showLevel);
    // a new one with the same tag replaces it and its bar slides from the old value
    // (bar/Island.qml).
    // Progress stays while it runs; levels go after the popup's time.
    readonly property bool islandOn: enabled && shown("island")
    property var level: null
    function showLevel(n) {
        const old = level;
        level = n;
        // Closed by its app (a finished download): off the island
        if (!n.local && old !== n) n.closed.connect(() => { if (root.level === n) root.level = null; });
        levelTimer.interval = Notifs.placeKind(n) === "progress" ? 8000 : Notifs.timeoutFor(n);
        levelTimer.restart();
        // A real notification that was a level (not the panel's own): it isn't kept
        if (old && old !== n && !old.local && Notifs.syncTag(old)) Qt.callLater(() => { try { old.expire(); } catch (e) {} });
    }
    function clearLevel() {
        const n = level;
        level = null;
        if (n && !n.local && (n.transient || Notifs.syncTag(n))) { try { n.expire(); } catch (e) {} }
    }
    Timer { id: levelTimer; onTriggered: root.clearLevel() }

    // A short message on the island ({ icon, text, undo }), gone after a moment.
    // With `undo` (a function) it stays 6 s and clicking the island runs it
    property var flash: null
    function say(icon, text, undo) {
        flash = { icon: icon, text: text, undo: undo ?? null };
        flashTimer.interval = undo ? 6000 : 1800;
        flashTimer.restart();
    }
    function undoFlash() {
        const f = flash;
        flash = null;
        if (f?.undo) { f.undo(); say("\uf0e2", Tr.t("Undone")); }
    }
    Timer { id: flashTimer; interval: 1800; onTriggered: root.flash = null }
}
