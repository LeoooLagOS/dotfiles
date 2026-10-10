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

    function showDetail(id) { PanelState.controlsDetail = PanelState.controlsDetail === id ? "system" : id; }
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
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: 7
                    rowSpacing: 7

                    QuickTile {
                        Layout.fillWidth: true
                        icon: Networking.wifiEnabled ? "" : "\u{f05aa}"
                        label: "Wi-Fi"
                        status: !Networking.wifiEnabled ? "Off" : root.wifiNetwork ? root.wifiNetwork.name : "Not connected"
                        active: Networking.wifiEnabled
                        selected: PanelState.controlsDetail === "wifi"
                        onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                        onDetailRequested: root.showDetail("wifi")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Bluetooth"
                        status: !root.btAdapter?.enabled ? "Off"
                              : root.btConnected.length === 1 ? root.btConnected[0].name
                              : root.btConnected.length > 1 ? root.btConnected.length + " devices"
                              : "No devices connected"
                        active: root.btAdapter?.enabled ?? false
                        selected: PanelState.controlsDetail === "bt"
                        onToggled: root.toggleBluetooth()
                        onDetailRequested: root.showDetail("bt")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: Notifs.dnd ? "" : ""
                        label: "Do Not Disturb"
                        status: Notifs.dndStatus
                        active: Notifs.dnd
                        selected: PanelState.controlsDetail === "dnd"
                        hasSettings: true
                        onToggled: Notifs.toggleDnd()
                        onDetailRequested: root.showDetail("dnd")
                        onSettingsRequested: PanelState.openSettings("notifications")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: Theme.light ? "" : ""
                        label: Theme.light ? "Light mode" : "Dark mode"
                        status: Theme.override ? "For now" : Theme.modeSetting === "system" ? "Follows system" : "Default"
                        active: !Theme.light
                        selected: PanelState.controlsDetail === "dark"
                        hasSettings: true
                        onToggled: Theme.toggleLight()
                        onDetailRequested: root.showDetail("dark")
                        onSettingsRequested: PanelState.openSettings("appearance")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Night light"
                        status: Toggles.night ? Settings.v.nightTemp + " K" : "Off"
                        active: Toggles.night
                        selected: PanelState.controlsDetail === "night"
                        onToggled: Toggles.toggleNight()
                        onDetailRequested: root.showDetail("night")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Caffeine"
                        status: Toggles.caffeineStatus
                        active: Toggles.caffeine
                        selected: PanelState.controlsDetail === "caffeine"
                        hasSettings: true
                        onToggled: Toggles.setCaffeine(!Toggles.caffeine, 0)
                        onDetailRequested: root.showDetail("caffeine")
                        onSettingsRequested: PanelState.openSettings("power")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Airplane mode"
                        status: Toggles.airplane ? "Wi-Fi and Bluetooth off" : "Off"
                        active: Toggles.airplane
                        selected: PanelState.controlsDetail === "airplane"
                        onToggled: Toggles.toggleAirplane()
                        onDetailRequested: root.showDetail("airplane")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: ""
                        label: "Game mode"
                        status: Toggles.gameBusy ? "Switching…" : Toggles.game ? "No animations or blur" : "Off"
                        active: Toggles.game
                        selected: PanelState.controlsDetail === "game"
                        onToggled: if (!Toggles.gameBusy) Toggles.toggleGame()
                        onDetailRequested: root.showDetail("game")
                    }
                    QuickTile {
                        Layout.fillWidth: true
                        icon: root.micMuted ? "" : ""
                        label: "Microphone"
                        status: root.micMuted ? "Muted" : Audio.name(Audio.source)
                        active: !root.micMuted && !!Audio.source
                        selected: PanelState.controlsDetail === "mic"
                        onToggled: if (Audio.source?.audio) Audio.source.audio.muted = !Audio.source.audio.muted
                        onDetailRequested: root.showDetail("mic")
                    }
                }

                // Zones are loaded by path (like Cell.qml), not as types
                Loader {
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
                    mic: "controls/MicDetail.qml", output: "controls/OutputDetail.qml"
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
}
