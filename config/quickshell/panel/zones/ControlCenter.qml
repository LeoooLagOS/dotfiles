import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import Quickshell.Bluetooth
import "../common"
import "../services"
import "controls"

// The Controls tab: identity bar, quick toggles, sound & display, and a
// detail pane (System by default; a toggle's › shows its detail there).
// Some show theirs in a popover instead (see popoverAreas).
// The ⚙ button swaps everything for the Settings view (controls/SettingsView.qml).
// Navigation state lives in PanelState (controlsView, controlsDetail, settingsSection).
Item {
    id: root

    // Overview's Profile / System link here (Config.tabs → link: "Controls")
    Connections {
        target: PanelState
        function onFocusSerialChanged() {
            if (PanelState.focusZone === "ProfileZone") {
                PanelState.controlsView = "controls";
                Qt.callLater(() => identity.flash());
            } else if (PanelState.focusZone === "SystemZone") {
                PanelState.controlsView = "controls";
                PanelState.controlsDetail = "system";
                Qt.callLater(() => { if (detail.item) detail.item.flash(); });
            }
        }
    }

    // ---------------- Data for the tiles ----------------
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool micMuted: Audio.source?.audio?.muted ?? false

    // VPN state for the Wi-Fi tile and its VPN view, read while this tab is on screen
    Binding { target: Vpn; property: "watching"; value: PanelState.open && Config.tabs[PanelState.tab]?.name === "Controls" }

    function showDetail(id) { PanelState.controlsDetail = PanelState.controlsDetail === id ? "system" : id; }
    // Tiles whose detail opens as a popover, and the area it covers:
    //   tiles    the tiles of columns 2–3 (Caffeine, Night light: first column)
    //   sliders  Sound & display (Screen record, Display: third row, right above it)
    readonly property var popoverAreas: ({ caffeine: "tiles", night: "tiles", rec: "sliders", display: "sliders" })
    function showPopover(id) { PanelState.controlsPopover = PanelState.controlsPopover === id ? "" : id; }
    function toggleBluetooth() {
        if (btAdapter?.enabled) btAdapter.enabled = false;
        // rfkill may block it (airplane mode, or turned off elsewhere): unblock, then power on
        else Quickshell.execDetached(["bash", "-c", "rfkill unblock bluetooth; sleep 0.6; bluetoothctl power on >/dev/null"]);
    }

    // ---------------- Settings view ----------------
    SettingsView {
        anchors.fill: parent
        visible: PanelState.controlsView === "settings"
    }

    // ---------------- Controls view ----------------
    ColumnLayout {
        anchors.fill: parent
        spacing: Config.spacing
        visible: PanelState.controlsView !== "settings"

        IdentityBar {
            id: identity
            Layout.fillWidth: true
            Layout.preferredHeight: 58
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Config.spacing

            ColumnLayout {
                // Fixed share: children that fill would otherwise make it take the whole row
                readonly property int w: Math.round((root.width - Config.spacing) * 0.6)
                Layout.preferredWidth: w
                Layout.maximumWidth: w
                Layout.fillWidth: false
                Layout.fillHeight: true
                spacing: Config.spacing

                GridLayout {
                    id: grid
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 7
                    rowSpacing: 7

                    // Row by row: Caffeine · Airplane · Wi-Fi / Night light · Game · Bluetooth /
                    // Screen record · Display · Light mode. Do Not Disturb is in the
                    // identity bar. Some open their detail as a popover (see below).
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: Tr.t("Caffeine")
                        status: Toggles.caffeineStatus
                        active: Toggles.caffeine
                        selected: PanelState.controlsPopover === "caffeine"
                        hasSettings: true
                        onToggled: Toggles.setCaffeine(!Toggles.caffeine, 0)
                        onDetailRequested: root.showPopover("caffeine")
                        onSettingsRequested: PanelState.openSettings("power")
                    }
                    QuickTile {
                        id: popoverAnchor        // top-left of the popover area
                        Layout.fillWidth: true
                        icon: ""
                        label: Tr.t("Airplane mode")
                        status: Toggles.airplane ? Tr.t("Wi-Fi and Bluetooth off") : Tr.t("Off")
                        active: Toggles.airplane
                        selected: PanelState.controlsDetail === "airplane"
                        onToggled: Toggles.toggleAirplane()
                        onDetailRequested: root.showDetail("airplane")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: Networking.wifiEnabled ? "" : "\u{f05aa}"
                        label: "Wi-Fi"
                        // "VPN · " first: long network names get cut at the end
                        status: (Vpn.active ? "VPN · " : "")
                                + (!Networking.wifiEnabled ? Tr.t("Off") : root.wifiNetwork ? root.wifiNetwork.name : Tr.t("Not connected"))
                        active: Networking.wifiEnabled
                        selected: PanelState.controlsDetail === "wifi"
                        onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                        onDetailRequested: root.showDetail("wifi")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: Tr.t("Night light")
                        status: Toggles.night ? Settings.v.nightTemp + " K" : Tr.t("Off")
                        active: Toggles.night
                        selected: PanelState.controlsPopover === "night"
                        onToggled: Toggles.toggleNight()
                        onDetailRequested: root.showPopover("night")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: Tr.t("Game mode")
                        status: Toggles.gameBusy ? Tr.t("Switching…") : Toggles.game ? Tr.t("No animations or blur") : Tr.t("Off")
                        active: Toggles.game
                        selected: PanelState.controlsDetail === "game"
                        onToggled: if (!Toggles.gameBusy) Toggles.toggleGame()
                        onDetailRequested: root.showDetail("game")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Bluetooth"
                        status: !root.btAdapter?.enabled ? Tr.t("Off")
                              : root.btConnected.length === 1 ? root.btConnected[0].name
                              : root.btConnected.length > 1 ? Tr.t("%1 devices", root.btConnected.length)
                              : Tr.t("No devices connected")
                        active: root.btAdapter?.enabled ?? false
                        selected: PanelState.controlsDetail === "bt"
                        onToggled: root.toggleBluetooth()
                        onDetailRequested: root.showDetail("bt")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: Recorder.recording ? "\uf04d" : "\u{f044a}"
                        label: Recorder.recording ? Tr.t("Recording") : Tr.t("Screen record")
                        status: !Recorder.installed ? Tr.t("Not installed")
                              : Recorder.recording ? "\u25cf " + Tr.t("%1 · click to stop", Recorder.elapsed)
                              : Settings.v.recTarget === "region" ? Tr.t("Region") : Tr.t("Whole screen")
                        active: Recorder.recording
                        selected: PanelState.controlsPopover === "rec"
                        onToggled: Recorder.installed ? Recorder.toggle() : root.showPopover("rec")
                        onDetailRequested: root.showPopover("rec")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: "\u{f0379}"
                        label: Displays.enabled.length > 1 ? Tr.t("%1 displays", Displays.enabled.length) : Tr.t("Display")
                        status: Displays.primary ? Displays.primary.width + "×" + Displays.primary.height + " · "
                                                   + Math.round(Displays.primary.refresh) + " Hz"
                                                   + (Displays.primary.scale !== 1 ? " · " + Displays.primary.scale + "×" : "")
                                                 : "…"
                        selected: PanelState.controlsPopover === "display"
                        // No on/off: the body opens the detail too
                        onToggled: root.showPopover("display")
                        onDetailRequested: root.showPopover("display")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: Theme.chosenLight ? "" : ""
                        label: Theme.chosenLight ? Tr.t("Light mode") : Tr.t("Dark mode")
                        status: ({ panel: Tr.t("Panel"), both: Tr.t("Panel & launchers"), launchers: Tr.t("Launchers") })[Theme.scope]
                                + (Theme.chosenInverted ? " · " + Tr.t("inverted") : "")
                        active: !Theme.chosenLight
                        selected: PanelState.controlsDetail === "dark"
                        hasSettings: true
                        onToggled: Theme.toggleLight()
                        onDetailRequested: root.showDetail("dark")
                        onSettingsRequested: PanelState.openSettings("appearance")
                    }
                }

                // Zones are loaded by path (like Cell.qml), not as types
                Loader {
                    id: sliders
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: Qt.resolvedUrl("SlidersZone.qml")
                    onLoaded: item.detailRequested.connect(id => root.showDetail(id))
                }
            }

            // Detail pane
            Loader {
                id: detail
                Layout.fillWidth: true
                Layout.fillHeight: true
                readonly property var files: ({
                    system: "SystemZone.qml", wifi: "WifiZone.qml", bt: "BluetoothZone.qml",
                    dnd: "controls/DndDetail.qml", dark: "controls/AppearanceDetail.qml",
                    night: "controls/NightDetail.qml", caffeine: "controls/CaffeineDetail.qml",
                    airplane: "controls/AirplaneDetail.qml", game: "controls/GameDetail.qml",
                    mic: "controls/MicDetail.qml", output: "controls/OutputDetail.qml",
                    rec: "controls/RecordDetail.qml", display: "controls/DisplayDetail.qml"
                })
                source: Qt.resolvedUrl(files[PanelState.controlsDetail] ?? files.system)
                onLoaded: {
                    if (PanelState.controlsDetail === "system") item.controls = true;
                    else {
                        item.closable = true;
                        item.closeRequested.connect(() => PanelState.controlsDetail = "system");
                    }
                }
            }
        }
    }

    // ---------------- Popover ----------------
    // A tile's detail as one card over part of the tab (popoverAreas), like
    // Overview's notifications.
    // Click outside, ›, ✕ or Esc closes it.
    Item {
        anchors.fill: parent
        visible: PanelState.controlsPopover !== "" && PanelState.controlsView !== "settings"
        z: 5

        MouseArea { anchors.fill: parent; onClicked: PanelState.controlsPopover = "" }

        Item {
            id: popover
            readonly property string area: root.popoverAreas[PanelState.controlsPopover] ?? "tiles"
            readonly property Item target: area === "sliders" ? sliders : grid
            // Corner of the target in this tab; mapToItem isn't reactive, so it is
            // re-evaluated on opening and whenever the layout changes size
            readonly property point origin: {
                PanelState.controlsPopover; target.width; target.height; root.width; root.height;
                return target.mapToItem(root, 0, 0);
            }
            readonly property real fit: popoverLoader.item?.implicitHeight ?? 0
            // Over the tiles it grows down if it needs more room; over Sound &
            // display it keeps that size and its content scrolls
            x: origin.x + (area === "tiles" ? popoverAnchor.x : 0)
            y: origin.y
            width: target.width - (area === "tiles" ? popoverAnchor.x : 0)
            height: area === "tiles" ? Math.max(grid.height, fit) : target.height

            MouseArea { anchors.fill: parent }   // keep clicks inside
            Loader {
                id: popoverLoader
                anchors.fill: parent
                active: PanelState.controlsPopover !== ""
                source: active ? Qt.resolvedUrl(detail.files[PanelState.controlsPopover]) : ""
                onLoaded: {
                    item.closable = true;
                    item.closeRequested.connect(() => PanelState.controlsPopover = "");
                    // Take the keyboard so ↑/↓ scroll right away
                    Qt.callLater(() => { if (item) item.forceActiveFocus(); });
                }
            }
            // Fixed size over Sound & display: the content scrolls. A Binding, not
            // set in onLoaded: `area` may not have followed controlsPopover yet there
            Binding {
                target: popoverLoader.item
                property: "scrollable"
                value: popover.area === "sliders"
                when: popoverLoader.item !== null
            }
        }
    }
}
