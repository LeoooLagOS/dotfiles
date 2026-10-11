import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Profile — avatar, full name (GECOS field of /etc/passwd, falls back
// to $USER), $USER@$HOST, distro logo "on <WM>" and uptime.
// Lock / power-menu buttons live in the System zone header.
// Avatar: put a square image at ~/.face (falls back to initials).
// Data: services/Profile.qml (shared with the Controls identity bar).
Zone {
    id: root
    centered: true

    RowLayout {
        width: parent.width
        spacing: 8

        ClippingRectangle {
            implicitWidth: 40
            implicitHeight: 40
            radius: 20
            color: Theme.accent2

            Label {
                anchors.centerIn: parent
                visible: avatar.status !== Image.Ready
                text: Profile.initials
                color: Theme.accent2Text
                font.pixelSize: 15
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
            spacing: 3

            // Full name (only if set; otherwise $USER@$HOST is enough)
            Label {
                Layout.fillWidth: true
                visible: Profile.hasFullName
                text: Profile.fullName
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            // $USER@$HOST
            Label {
                Layout.fillWidth: true
                text: Profile.user + "@" + Profile.host
                dim: Profile.hasFullName
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            // Distro logo · on <WM>
            Row {
                spacing: 6
                Glyph { text: Profile.distroLogo; font.pixelSize: 12; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "on " + Profile.wm; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }

            // Uptime
            Row {
                spacing: 6
                Glyph { text: "\uf017"; font.pixelSize: 10; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "up " + SystemStats.uptime; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
