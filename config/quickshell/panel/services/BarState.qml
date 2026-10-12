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
        left: [["logo", "Logo"], ["workspaces", "Workspaces"], ["window", "Window title"]],
        center: [["bell", "Notifications"], ["island", "Island"], ["caffeine", "Caffeine"]],
        right: [["tray", "Tray"], ["cpu", "CPU"], ["ram", "RAM"], ["disk", "Disk"], ["temp", "Temperature"],
                ["wifi", "Wi-Fi"], ["bluetooth", "Bluetooth"], ["battery", "Battery"], ["power", "Power"]]
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
    function togglePopup(monitor) { monitorOn = ""; popupOn = popupOn === monitor ? "" : monitor; }
    function toggleMonitor(monitor) { popupOn = ""; monitorOn = monitorOn === monitor ? "" : monitor; }
    Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) { root.popupOn = ""; root.monitorOn = ""; } } }

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

    // A short message on the island ({ icon, text }), gone after a moment
    property var flash: null
    function say(icon, text) { flash = { icon: icon, text: text }; flashTimer.restart(); }
    Timer { id: flashTimer; interval: 1800; onTriggered: root.flash = null }
}
