import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../common"
import "../../services"

// Controls: who and where (services/Profile.qml), uptime, battery, and the
// settings / lock / power-menu buttons.
Zone {
    id: root
    centered: true

    function run(cmd) {
        PanelState.open = false;
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    readonly property bool hasBattery: SystemStats.batteryStatus !== "Unknown"
    readonly property bool onAC: SystemStats.batteryStatus !== "Discharging"

    RowLayout {
        width: parent.width
        spacing: 12

        ClippingRectangle {
            implicitWidth: 38
            implicitHeight: 38
            radius: 19
            color: Theme.accent2
            Label {
                anchors.centerIn: parent
                visible: avatar.status !== Image.Ready
                text: Profile.initials
                color: Theme.onAccent2
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
            Image {
                id: avatar
                anchors.fill: parent
                source: Profile.avatar
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(92, 92)
                visible: status === Image.Ready
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Label { text: Profile.fullName; font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Row {
                spacing: 6
                Layout.fillWidth: true
                clip: true
                Label { text: Profile.user + "@" + Profile.host + "  ·"; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                Glyph { text: Profile.distroLogo; font.pixelSize: 11; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                Label { text: (Profile.distroName ? Profile.distroName + " on " : "on ") + Profile.wm + "  ·"; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                Glyph { text: ""; font.pixelSize: 10; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "up " + SystemStats.uptime; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        // Battery
        Rectangle {
            visible: root.hasBattery
            implicitHeight: 30
            implicitWidth: batRow.implicitWidth + 20
            radius: 9
            color: "transparent"
            border.color: Theme.border
            Row {
                id: batRow
                anchors.centerIn: parent
                spacing: 6
                Glyph {
                    text: root.onAC ? "" : SystemStats.battery > 60 ? "" : SystemStats.battery > 20 ? "" : ""
                    font.pixelSize: 12
                    color: Theme.lowLevel(SystemStats.battery / 100, 0.3, 0.15)
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label {
                    text: SystemStats.battery + "%" + (SystemStats.batteryStatus === "Charging" ? " · charging" : root.onAC ? " · AC" : "")
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        IconButton { icon: ""; iconSize: 13; implicitWidth: 34; implicitHeight: 30; onClicked: PanelState.openSettings("") }   // settings
        IconButton { icon: ""; iconSize: 12; implicitWidth: 34; implicitHeight: 30; onClicked: root.run(Config.lockCmd) }     // lock
        IconButton { icon: ""; iconSize: 12; implicitWidth: 34; implicitHeight: 30; onClicked: root.run(Config.powerCmd) }    // power menu
    }
}
