import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Profile — the avatar nearly filling the card (like the album art),
// beside it the full name (GECOS field of /etc/passwd, if set), $USER@$HOST,
// distro logo "on <WM>" and uptime.
// Lock / power-menu buttons live in the System zone header.
// Avatar: put a square image at ~/.face (falls back to initials).
// Data: services/Profile.qml (shared with the Controls identity bar).
Zone {
    id: root
    centered: true

    // The photo nearly fills the card (half the usual padding around it);
    // beside it, from the top, the full name level with the other cards'
    // titles (Zone's header: NOTIFICATIONS, SYSTEM), then $USER@$HOST,
    // "on <WM>" and the uptime
    readonly property real inner: root.height - 2 * Theme.zonePadding
    readonly property int inset: Math.round(Theme.zonePadding / 2)

    Item {
        width: parent.width
        implicitHeight: root.inner

        ClippingRectangle {
            id: photo
            // The body starts zonePadding in: out to `inset` from the card's edges
            x: root.inset - Theme.zonePadding
            y: root.inset - Theme.zonePadding
            width: root.height - 2 * root.inset
            height: width
            radius: Theme.zoneRadius
            color: Theme.accent2

            Label {
                anchors.centerIn: parent
                visible: avatar.status !== Image.Ready
                text: Profile.initials
                color: Theme.accent2Text
                font.pixelSize: 30
                font.weight: Font.DemiBold
            }

            Image {
                id: avatar
                anchors.fill: parent
                source: Profile.avatar
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(220, 220)
                visible: status === Image.Ready
            }
        }

        ColumnLayout {
            x: photo.x + photo.width + 12
            // In the band the compact cards beside it use for their content
            // (Zone's bandTop: weather / clock, notifications), so the three line up
            y: root.bandTop - Theme.zonePadding
            width: parent.width - x
            spacing: 3

            // Full name (only if set; otherwise $USER@$HOST is enough)
            Label {
                Layout.fillWidth: true
                visible: Profile.hasFullName
                text: Profile.fullName
                font.pixelSize: 17
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
                Label { text: Tr.t("on %1", Profile.wm); dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }

            // Uptime
            Row {
                spacing: 6
                Glyph { text: "\uf017"; font.pixelSize: 10; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: Tr.t("up %1", SystemStats.uptime); dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
