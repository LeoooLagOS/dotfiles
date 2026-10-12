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

    // System popup: open on one monitor ("" = closed)
    property string popupOn: ""
    function togglePopup(monitor) { popupOn = popupOn === monitor ? "" : monitor; }
    Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) root.popupOn = ""; } }

    // A short message on the island ({ icon, text }), gone after a moment
    property var flash: null
    function say(icon, text) { flash = { icon: icon, text: text }; flashTimer.restart(); }
    Timer { id: flashTimer; interval: 1800; onTriggered: root.flash = null }
}
