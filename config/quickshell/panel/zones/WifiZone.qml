import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../common"
import "../services"

// ZONE: Wi-Fi (Controls tab) — on/off tile and the list of nearby networks.
// Click a network: disconnect if connected, connect if saved, otherwise open a
// terminal with `nmcli --ask` to enter the password.
Zone {
    id: root
    title: "Wi-Fi"
    icon: "\uf1eb"

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: (device?.networks.values ?? []).slice().sort((a, b) =>
        (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    readonly property var connected: networks.find(n => n.connected) ?? null
    readonly property bool tabVisible: PanelState.open && Config.tabs[PanelState.tab]?.name === "Controls"

    // Scan only while the Controls tab is on screen
    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.tabVisible && Networking.wifiEnabled
        when: root.device !== null
    }

    function signalIcon(s) {
        return s > 0.75 ? "\u{f0928}" : s > 0.5 ? "\u{f0925}" : s > 0.25 ? "\u{f0922}" : "\u{f091f}";
    }

    ColumnLayout {
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 10

        ToggleTile {
            Layout.fillWidth: true
            icon: Networking.wifiEnabled ? "\uf1eb" : "\u{f05aa}"
            label: Networking.wifiEnabled ? "On" : "Off"
            status: !Networking.wifiHardwareEnabled ? "Blocked by hardware switch"
                    : root.connected ? "Connected to " + root.connected.name
                    : Networking.wifiEnabled ? "Not connected" : "Wi-Fi is off"
            active: Networking.wifiEnabled && Networking.wifiHardwareEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
            onSettingsClicked: { PanelState.open = false; Quickshell.execDetached(["nm-connection-editor"]); }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Networking.wifiEnabled
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: root.networks

            delegate: Rectangle {
                id: item
                required property var modelData
                width: ListView.view.width
                height: 40
                radius: 10
                color: modelData.connected ? Theme.withAlpha(Theme.accent, 0.14)
                       : (netMouse.containsMouse ? Theme.bgHover : "transparent")

                function activate() {
                    const n = item.modelData;
                    if (n.connected) n.disconnect();
                    else if (n.known || n.security === WifiSecurityType.Open) n.connect();
                    else {
                        PanelState.open = false;
                        Quickshell.execDetached(["kitty", "--title", "Wi-Fi: " + n.name, "-e",
                                                 "nmcli", "--ask", "device", "wifi", "connect", n.name]);
                    }
                }
                // Keyboard: Tab to a network, Enter/Space connects or disconnects
                activeFocusOnTab: true
                Keys.onReturnPressed: activate()
                Keys.onEnterPressed: activate()
                Keys.onSpacePressed: activate()
                FocusRing {}

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Glyph { text: root.signalIcon(item.modelData.signalStrength); color: item.modelData.connected ? Theme.accent : Theme.fg; Layout.preferredWidth: 18 }
                    Label {
                        Layout.fillWidth: true
                        text: item.modelData.name
                        font.pixelSize: 13
                        font.weight: item.modelData.connected ? Font.DemiBold : Font.Normal
                    }
                    Label {
                        text: item.modelData.stateChanging ? "…" : item.modelData.connected ? "Connected" : item.modelData.known ? "Saved" : ""
                        dim: true
                        font.pixelSize: 11
                    }
                    Glyph {
                        visible: item.modelData.security !== WifiSecurityType.Open
                        text: "\uf023"
                        font.pixelSize: 10
                        color: Theme.fgDim
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: item.activate()
                }
            }

            Label {
                anchors.centerIn: parent
                visible: parent.count === 0
                text: "Scanning…"
                dim: true
            }
        }

        Item { Layout.fillHeight: true; visible: !Networking.wifiEnabled }
    }
}
