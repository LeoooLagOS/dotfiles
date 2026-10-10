import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Notifications (Overview) — count in the header, the latest
// notification as a card, and a chevron that drops down the full list
// (drawn by Panel.qml over the zones below).
Zone {
    id: root
    title: "Notifications"
    icon: "\uf0f3"
    badge: Notifs.count > 0 ? String(Notifs.count) : ""

    readonly property var latest: Notifs.list[0] ?? null

    function updateAnchor() {
        const p = root.mapToItem(null, 0, 0);
        PanelState.notifAnchor = Qt.rect(p.x, p.y, root.width, root.height);
    }
    onWidthChanged: if (PanelState.notifDropdown) updateAnchor()

    actions: [
        IconButton {        // Do Not Disturb
            icon: Notifs.dnd ? "\uf1f6" : "\uf0f3"
            iconSize: 12; implicitWidth: 30; implicitHeight: 26
            active: Notifs.dnd
            onClicked: Notifs.toggleDnd()
        },
        IconButton {        // clear all
            icon: "\uf1f8"
            iconSize: 12; implicitWidth: 30; implicitHeight: 26
            visible: Notifs.count > 0
            onClicked: Notifs.clearAll()
        },
        IconButton {        // show all: drop the list down
            icon: PanelState.notifDropdown ? "\uf077" : "\uf078"
            iconSize: 11; implicitWidth: 30; implicitHeight: 26
            visible: Notifs.count > 1
            active: PanelState.notifDropdown
            onClicked: {
                root.updateAnchor();
                PanelState.notifDropdown = !PanelState.notifDropdown;
            }
        }
    ]

    // Latest notification
    NotificationCard {
        visible: !!root.latest
        width: parent.width
        notif: root.latest
        compact: true
    }

    RowLayout {
        visible: !root.latest
        width: parent.width
        spacing: 10
        Glyph { text: Notifs.dnd ? "\uf1f6" : "\uf0f3"; color: Theme.fgDim; font.pixelSize: 16 }
        Label {
            Layout.fillWidth: true
            text: Notifs.dnd ? "Do not disturb is on" : "You're all caught up"
            dim: true
        }
    }
}
