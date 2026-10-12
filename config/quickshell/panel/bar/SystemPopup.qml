import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import "../common"
import "../services"

// The small system panel that drops from the bar's stats / network / battery
// (BarState.popupOn): who and how long up, lock / power / settings, the four
// readings with bars, output volume and brightness, and quick tiles (Wi-Fi,
// Bluetooth, output, microphone, night light, dark mode). A tile's › opens its
// detail in the panel (Controls). Closes on a click outside, Esc, or the same
// pill again (HyprlandFocusGrab with the bar).
PanelWindow {
    id: root
    property var barWindow: null
    property real rightOffset: 8          // from the screen's right edge to the pill's right edge
    property string screenName: ""        // this bar's monitor
    readonly property bool open: screenName !== "" && BarState.popupOn === screenName

    visible: open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal   // below the bar
    anchors { top: true; right: true }
    margins { top: 6; right: Math.max(8, rightOffset) }
    implicitWidth: 440
    implicitHeight: card.implicitHeight + 2
    WlrLayershell.namespace: "quickshell:bar-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
        active: root.open
        windows: [root, root.barWindow]
        onCleared: if (root.open) BarState.popupOn = ""
    }

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected: Bluetooth.devices.values.filter(d => d.connected)
    readonly property var bat: UPower.displayDevice
    readonly property bool hasBattery: !!bat && bat.isLaptopBattery
    readonly property int batPct: !bat ? 0 : Math.round(bat.percentage > 1 ? bat.percentage : bat.percentage * 100)

    // A detail of the panel's Controls tab (wifi, bt, output, mic, dark…), or a popover (night)
    function controls(detail, popover) {
        BarState.popupOn = "";
        PanelState.open = true;
        PanelState.goTo("Controls", "");
        if (popover) PanelState.controlsPopover = popover; else PanelState.controlsDetail = detail;
    }
    function run(cmd) { BarState.popupOn = ""; Quickshell.execDetached(["bash", "-c", cmd]); }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: col.implicitHeight + 28
        radius: 18
        color: Theme.bg
        border.color: Theme.border
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.97
        transformOrigin: Item.TopRight
        Behavior on opacity { NumberAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        focus: root.open
        Keys.onEscapePressed: BarState.popupOn = ""

        ColumnLayout {
            id: col
            x: 14
            y: 14
            width: parent.width - 28
            spacing: 10

            // ---------------- Who ----------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 11
                ClippingRectangle {
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Theme.accent2
                    Label { anchors.centerIn: parent; visible: avatar.status !== Image.Ready; text: Profile.initials; color: Theme.accent2Text; font.pixelSize: 14; font.weight: Font.DemiBold }
                    Image { id: avatar; anchors.fill: parent; source: Profile.avatar; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(80, 80); visible: status === Image.Ready }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Label { text: Profile.fullName; font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    Label { text: "up " + SystemStats.uptime + (root.hasBattery ? "  ·  " + root.batPct + "%" + (root.bat.state === UPowerDeviceState.Charging ? " charging" : "") : ""); dim: true; font.pixelSize: 11; Layout.fillWidth: true }
                }
                IconButton { icon: ""; iconSize: 12; implicitWidth: 34; implicitHeight: 30; onClicked: root.run(Config.lockCmd) }
                IconButton { icon: ""; iconSize: 12; implicitWidth: 34; implicitHeight: 30; iconColor: Theme.bad; onClicked: root.run(Config.powerCmd) }
                IconButton { icon: ""; iconSize: 13; implicitWidth: 34; implicitHeight: 30; onClicked: { BarState.popupOn = ""; PanelState.open = true; PanelState.openSettings("bar"); } }
            }

            // ---------------- Readings ----------------
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                columnSpacing: 7
                Repeater {
                    model: [
                        { icon: "", label: "CPU", v: SystemStats.cpu, text: SystemStats.cpu + "%", warn: 80, bad: 95 },
                        { icon: "\uefc5", label: "RAM", v: SystemStats.memPct, text: SystemStats.memPct + "%", warn: 80, bad: 92 },
                        { icon: "\uf0a0", label: "Disk", v: SystemStats.diskPct, text: SystemStats.diskPct + "%", warn: 90, bad: 97 },
                        { icon: "", label: "Temp", v: SystemStats.temp, text: SystemStats.temp + "°C", warn: 80, bad: 90 }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        readonly property color tint: modelData.v >= modelData.bad ? Theme.bad : modelData.v >= modelData.warn ? Theme.warn : BarState.accent
                        Layout.fillWidth: true
                        implicitHeight: 64
                        radius: 12
                        color: Theme.bgAlt
                        border.color: Theme.border
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 9
                            spacing: 3
                            RowLayout {
                                spacing: 6
                                Glyph { text: modelData.icon; font.pixelSize: 12; color: Theme.fgDim }
                                Label { text: modelData.label; dim: true; font.pixelSize: 11 }
                            }
                            Label { text: modelData.text; font.pixelSize: 16; font.weight: Font.DemiBold; font.features: { "tnum": 1 }
                                    color: modelData.v >= modelData.warn ? tint : Theme.fg }
                            Bar { Layout.fillWidth: true; value: Math.min(1, modelData.v / 100); fillColor: parent.parent.tint }
                        }
                    }
                }
            }

            // ---------------- Volume & brightness ----------------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: sliders.implicitHeight + 16
                radius: 12
                color: Theme.bgAlt
                border.color: Theme.border
                ColumnLayout {
                    id: sliders
                    x: 8
                    y: 8
                    width: parent.width - 16
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        SliderRow {
                            Layout.fillWidth: true
                            readonly property var a: Audio.sink?.audio
                            icon: a?.muted ? "" : ""
                            value: Math.min(1, a?.volume ?? 0)
                            onMoved: v => { if (a) a.volume = v; }
                            onIconClicked: if (a) a.muted = !a.muted
                        }
                        Label { text: Math.round((Audio.sink?.audio?.volume ?? 0) * 100) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.preferredWidth: 44; horizontalAlignment: Text.AlignRight }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        SliderRow {
                            Layout.fillWidth: true
                            icon: "\u{f00df}"
                            value: Brightness.value
                            onMoved: v => Brightness.set(v)
                        }
                        Label { text: Math.round(Brightness.value * 100) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.preferredWidth: 44; horizontalAlignment: Text.AlignRight }
                    }
                }
            }

            // ---------------- Tiles ----------------
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 7
                rowSpacing: 7
                QuickTile {
                    Layout.fillWidth: true
                    icon: Networking.wifiEnabled ? "\u{f0928}" : "\u{f092d}"
                    label: "Wi-Fi"
                    status: !Networking.wifiEnabled ? "Off" : root.wifiNetwork ? root.wifiNetwork.name : "Not connected"
                    active: Networking.wifiEnabled
                    onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                    onDetailRequested: root.controls("wifi")
                }
                QuickTile {
                    Layout.fillWidth: true
                    icon: ""
                    label: "Bluetooth"
                    status: !root.btAdapter?.enabled ? "Off"
                          : root.btConnected.length === 1 ? root.btConnected[0].name
                          : root.btConnected.length > 1 ? root.btConnected.length + " devices" : "No devices"
                    active: root.btAdapter?.enabled ?? false
                    onToggled: {
                        if (root.btAdapter?.enabled) root.btAdapter.enabled = false;
                        else Quickshell.execDetached(["bash", "-c", "rfkill unblock bluetooth; sleep 0.6; bluetoothctl power on >/dev/null"]);
                    }
                    onDetailRequested: root.controls("bt")
                }
                QuickTile {
                    Layout.fillWidth: true
                    icon: Audio.sink?.audio?.muted ? "" : ""
                    label: Audio.name(Audio.sink) || "Output"
                    status: Audio.sink?.audio?.muted ? "Muted" : Math.round((Audio.sink?.audio?.volume ?? 0) * 100) + "%"
                    active: !(Audio.sink?.audio?.muted ?? true)
                    onToggled: if (Audio.sink?.audio) Audio.sink.audio.muted = !Audio.sink.audio.muted
                    onDetailRequested: root.controls("output")
                }
                QuickTile {
                    Layout.fillWidth: true
                    icon: Audio.source?.audio?.muted ? "" : ""
                    label: Audio.name(Audio.source) || "Microphone"
                    status: Audio.source?.audio?.muted ? "Muted" : Math.round((Audio.source?.audio?.volume ?? 0) * 100) + "%"
                    active: !(Audio.source?.audio?.muted ?? true)
                    onToggled: if (Audio.source?.audio) Audio.source.audio.muted = !Audio.source.audio.muted
                    onDetailRequested: root.controls("mic")
                }
                QuickTile {
                    Layout.fillWidth: true
                    icon: ""
                    label: "Night light"
                    status: Toggles.night ? Settings.v.nightTemp + " K" : "Off"
                    active: Toggles.night
                    onToggled: Toggles.toggleNight()
                    onDetailRequested: root.controls("", "night")
                }
                QuickTile {
                    Layout.fillWidth: true
                    icon: Theme.chosenLight ? "" : ""
                    label: Theme.chosenLight ? "Light mode" : "Dark mode"
                    status: Theme.chosenInverted ? "Inverted" : "Normal"
                    active: !Theme.chosenLight
                    onToggled: Theme.toggleLight()
                    onDetailRequested: root.controls("dark")
                }
            }
        }
    }
}
