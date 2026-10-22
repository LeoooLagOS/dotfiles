import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../common"
import "../services"

// ZONE: Bluetooth (Controls tab) — on/off tile and paired devices.
// Click a device to connect/disconnect it. Pairing new devices: the tile's
// arrow opens blueman-manager.
Zone {
    id: root
    title: "Bluetooth"
    icon: "\uf293"

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices.values
        .filter(d => d.paired || d.connected)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property var connected: devices.filter(d => d.connected)

    function deviceIcon(icon) {
        if (!icon) return "\uf293";
        if (icon.includes("headset") || icon.includes("headphone")) return "\uf025";
        if (icon.includes("audio") || icon.includes("speaker")) return "\uf028";
        if (icon.includes("mouse")) return "\u{f037d}";
        if (icon.includes("keyboard")) return "\uf11c";
        if (icon.includes("phone")) return "\uf10b";
        if (icon.includes("gaming") || icon.includes("joystick")) return "\uf11b";
        return "\uf293";
    }

    ColumnLayout {
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 10

        ToggleTile {
            Layout.fillWidth: true
            icon: "\uf293"
            label: root.adapter?.enabled ? Tr.t("On") : Tr.t("Off")
            status: !root.adapter ? Tr.t("No adapter found")
                    : !root.adapter.enabled ? Tr.t("Bluetooth is off")
                    : root.connected.length === 1 ? Tr.t("Connected to %1", root.connected[0].name)
                    : root.connected.length > 1 ? Tr.t("%1 devices connected", root.connected.length)
                    : Tr.t("No devices connected")
            active: root.adapter?.enabled ?? false
            onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
            onSettingsClicked: { PanelState.open = false; Quickshell.execDetached(["blueman-manager"]); }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.adapter?.enabled ?? false
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: root.devices

            delegate: Rectangle {
                id: item
                required property var modelData
                width: ListView.view.width
                height: 44
                radius: 10
                color: modelData.connected ? Theme.withAlpha(Theme.accent, 0.14)
                       : (devMouse.containsMouse ? Theme.bgHover : "transparent")

                // Keyboard: Tab to a device, Enter/Space connects or disconnects
                activeFocusOnTab: true
                Keys.onReturnPressed: modelData.connected = !modelData.connected
                Keys.onEnterPressed: modelData.connected = !modelData.connected
                Keys.onSpacePressed: modelData.connected = !modelData.connected
                FocusRing {}

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Glyph { text: root.deviceIcon(item.modelData.icon); color: item.modelData.connected ? Theme.accent : Theme.fg; Layout.preferredWidth: 18 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label { Layout.fillWidth: true; text: item.modelData.name; font.pixelSize: 13; font.weight: item.modelData.connected ? Font.DemiBold : Font.Normal }
                        Label {
                            Layout.fillWidth: true
                            text: item.modelData.connected ? Tr.t("Connected") : Tr.t("Paired")
                            dim: true
                            font.pixelSize: 11
                        }
                    }
                    Label {
                        visible: item.modelData.batteryAvailable
                        text: Math.round(item.modelData.battery * 100) + "%"
                        dim: true
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: devMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: item.modelData.connected = !item.modelData.connected
                }
            }

            Label {
                anchors.centerIn: parent
                visible: parent.count === 0
                text: Tr.t("No paired devices")
                dim: true
            }
        }

        Item { Layout.fillHeight: true; visible: !(root.adapter?.enabled ?? false) }
    }
}
