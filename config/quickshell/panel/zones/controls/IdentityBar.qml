import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../common"
import "../../services"

// Controls: who and where (services/Profile.qml), uptime, Do Not Disturb,
// battery, and the settings / lock / power-menu buttons.
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
                color: Theme.accent2Text
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

        // Do Not Disturb: the body toggles it, › shows its detail in the right
        // pane (controls/DndDetail.qml), right-click opens Settings → Notifications
        Rectangle {
            id: dnd
            readonly property bool selected: PanelState.controlsDetail === "dnd"
            implicitHeight: 30
            implicitWidth: dndRow.implicitWidth + 16 + dndMore.width
            radius: 9
            color: Notifs.dnd ? Theme.withAlpha(Theme.accent, dndMouse.containsMouse ? 0.28 : 0.20)
                              : dndMouse.containsMouse ? Theme.bgHover : "transparent"
            border.color: selected ? Theme.accent : Notifs.dnd ? Theme.withAlpha(Theme.accent, 0.55) : Theme.border
            border.width: selected ? 2 : 1
            Behavior on color { ColorAnimation { duration: Theme.anim } }

            activeFocusOnTab: true
            Keys.onReturnPressed: Notifs.toggleDnd()
            Keys.onSpacePressed: Notifs.toggleDnd()
            Keys.onRightPressed: dnd.showDetail()
            FocusRing {}
            function showDetail() { PanelState.controlsDetail = selected ? "system" : "dnd"; }

            MouseArea {
                id: dndMouse
                anchors.fill: parent
                anchors.rightMargin: dndMore.width
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => mouse.button === Qt.RightButton ? PanelState.openSettings("notifications") : Notifs.toggleDnd()
            }
            Row {
                id: dndRow
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 6
                Glyph { text: Notifs.dnd ? "\uf1f6" : "\uf0f3"; font.pixelSize: 12; color: Notifs.dnd ? Theme.accent : Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: Notifs.dnd ? "DND · " + Notifs.dndStatus : "DND"; font.pixelSize: 12; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
            }
            // › detail
            Rectangle {
                id: dndMore
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: dnd.border.width
                width: 24
                radius: dnd.radius
                color: dndMoreMouse.containsMouse ? Theme.withAlpha(Theme.fg, 0.06) : "transparent"
                Rectangle { width: 1; height: parent.height; color: Theme.border }
                Glyph { anchors.centerIn: parent; text: "\uf054"; font.pixelSize: 9; color: Theme.fgDim }
                MouseArea {
                    id: dndMoreMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dnd.showDetail()
                }
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
