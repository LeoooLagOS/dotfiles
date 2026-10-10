pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../common"

Singleton {
    id: root
    property bool open: false
    property int tab: 0          // index into Config.tabs
    property bool miniVisualizer: false   // Overview media card: cava instead of buttons

    // Zone to highlight after a `link` jump (see Config.tabs): goTo("Controls",
    // "SystemZone") switches tab, then that zone pulses and takes keyboard focus
    property string focusZone: ""
    property int focusSerial: 0
    function goTo(tabName, zone) {
        const i = Config.tabs.findIndex(t => t.name === tabName);
        if (i < 0) return;
        tab = i;
        focusZone = zone;
        focusSerial++;
    }

    // Controls tab: "controls" or "settings" view, the detail shown on the
    // right ("system", "wifi", "bt"…, see zones/ControlCenter.qml) and the
    // Settings section. Opening the panel returns to Controls → System; the
    // section is remembered.
    property string controlsView: "controls"
    property string controlsDetail: "system"
    property string settingsSection: "appearance"
    function openSettings(section) {
        if (section) settingsSection = section;
        controlsView = "settings";
        const i = Config.tabs.findIndex(t => t.name === "Controls");
        if (i >= 0) tab = i;
    }

    // Overview's notification dropdown: open flag and the zone's rect in
    // window coordinates (the list is drawn by Panel.qml, above every zone)
    property bool notifDropdown: false
    property rect notifAnchor: Qt.rect(0, 0, 0, 0)

    // Pointer over the panel card (set by Panel.qml). The screen is dimmed
    // while it is, and right after opening until the pointer leaves the card.
    property bool hovered: false
    property bool dimmed: false
    onHoveredChanged: if (open) dimmed = hovered && Settings.v.dimHover

    // Click outside to close, without swallowing the click: while open, a
    // non-consuming left-click bind makes Hyprland emit "custom>>panel-click"
    // on every click; clicks that aren't over the card close the panel.
    readonly property string clickEvent: "panel-click"
    // (Unbinding first keeps a single bind, e.g. if a previous instance died while open)
    function setClickBind(on) {
        Quickshell.execDetached(["hyprctl", "eval", `hl.unbind("mouse:272")`
            + (on ? `; hl.bind("mouse:272", hl.dsp.event("${clickEvent}"), { non_consuming = true })` : "")]);
    }
    Component.onCompleted: setClickBind(false)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "custom" && event.data === root.clickEvent && root.open && !root.hovered) root.open = false;
        }
    }

    // Settings → Panel: close on a click outside / dim while hovering
    Connections {
        target: Settings
        function onChanged(key) {
            if (key === "closeOutside" && root.open) root.setClickBind(Settings.v.closeOutside);
            if (key === "dimHover") root.dimmed = root.open && root.hovered && Settings.v.dimHover;
        }
    }

    // Opening always starts on Config.defaultTab (Settings → Panel)
    onOpenChanged: {
        if (open) {
            tab = Math.max(0, Config.tabs.findIndex(t => t.name === Config.defaultTab));
            controlsView = "controls";
            controlsDetail = "system";
        }
        notifDropdown = false;
        if (!open) hovered = false;
        dimmed = open && Settings.v.dimHover;
        setClickBind(open && Settings.v.closeOutside);
    }
    onTabChanged: notifDropdown = false
}
