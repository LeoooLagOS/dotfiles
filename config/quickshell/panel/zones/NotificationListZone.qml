import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"

// ZONE: Notification list (Notifications tab).
// Toolbar: Classify (type or app) · Search · Sort · Do not disturb · Clear all.
// The list is centered at 50% of the width (25% free on each side). Sorting
// by app groups the cards under app headers; other sorts show a flat list.
Zone {
    id: root

    property string filter: "all"
    property string query: ""
    property string sort: "newest"

    readonly property var shown: Notifs.select(filter, query, sort)

    // Groups for "app" sort: { order: [app names], items: { app: [notifications] } }
    // ("" is the one group of the other sorts). The Repeaters take them through
    // ScriptModels, which keep the cards already there: a new notification adds
    // one card instead of building the whole history again
    readonly property var groups: {
        if (sort !== "app") return { order: [""], items: { "": shown } };
        const order = [], map = {};
        for (const n of shown) {
            const app = Notifs.appLabel(n);
            if (!map[app]) { map[app] = []; order.push(app); }
            map[app].push(n);
        }
        return { order: order, items: map };
    }

    // Clear the filter if its app no longer has notifications
    onShownChanged: if (filter.startsWith("app:") && !Notifs.apps.includes(filter.slice(4))) filter = "all"

    ColumnLayout {
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        spacing: 12

        // ---------------- Toolbar ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            z: 2                       // dropdown lists open over the cards

            Row {
                spacing: 8
                Glyph { text: "\uf0f3"; font.pixelSize: 13; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "NOTIFICATIONS"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
                        anchors.verticalCenter: parent.verticalCenter }
                Rectangle {
                    visible: Notifs.count > 0
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(height, countLabel.implicitWidth + 12); height: 18; radius: 9
                    color: Theme.accent
                    Label { id: countLabel; anchors.centerIn: parent; text: Notifs.count; color: Theme.accentText; font.pixelSize: 11; font.weight: Font.Bold }
                }
            }

            // Classify
            Dropdown {
                icon: "\uf0b0"
                prefix: "Show: "
                value: root.filter
                options: [
                    { label: "All", value: "all" },
                    { label: "Critical", value: "critical" },
                    { label: "Messages", value: "message" },
                    { label: "System", value: "system" },
                    { label: "Other apps", value: "app" }
                ].concat(Notifs.apps.map(a => ({ label: "App · " + a, value: "app:" + a })))
                onSelected: v => root.filter = v
            }

            // Search
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 28
                radius: 14
                color: Theme.withAlpha(Theme.base, 0.35)
                border.color: search.activeFocus ? Theme.accent : Theme.border

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8
                    Glyph { text: "\uf002"; font.pixelSize: 11; color: Theme.fgDim }
                    TextInput {
                        id: search
                        Layout.fillWidth: true
                        color: Theme.fg
                        font.family: Theme.font
                        font.pixelSize: 12
                        clip: true
                        selectByMouse: true
                        onTextChanged: root.query = text
                        Keys.onEscapePressed: event => {
                            if (text !== "") { text = ""; event.accepted = true; }
                            else event.accepted = false;      // let Esc close the panel
                        }
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !search.text && !search.activeFocus
                            text: "Search notifications…"
                            dim: true
                            font.pixelSize: 12
                        }
                    }
                    Glyph {
                        visible: search.text !== ""
                        text: "\uf00d"; font.pixelSize: 10; color: Theme.fgDim
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: search.text = "" }
                    }
                }
            }

            // Sort
            Dropdown {
                icon: "\uf0dc"
                prefix: "Sort: "
                value: root.sort
                options: [
                    { label: "Newest", value: "newest" },
                    { label: "Oldest", value: "oldest" },
                    { label: "App", value: "app" },
                    { label: "Urgency", value: "urgency" }
                ]
                onSelected: v => root.sort = v
            }

            // Do not disturb
            Chip {
                icon: Notifs.dnd ? "\uf1f6" : "\uf0f3"
                text: "Do not disturb"
                active: Notifs.dnd
                onClicked: Notifs.toggleDnd()
            }

            // Clear all (only what is shown when a filter/search is active)
            Chip {
                visible: root.shown.length > 0
                text: root.filter === "all" && root.query === "" ? "Clear all" : "Clear shown"
                onClicked: Notifs.dismissAll(root.shown)
            }
        }

        // ---------------- List (50% centered) ----------------
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Empty state
            Column {
                anchors.centerIn: parent
                visible: root.shown.length === 0
                spacing: 8
                Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: Notifs.dnd ? "\uf1f6" : "\uf0f3"; font.pixelSize: 40; color: Theme.fgDim }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Notifs.count === 0 ? "No notifications" : "Nothing matches"
                    dim: true; font.pixelSize: 15
                }
                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: Notifs.dnd && Notifs.count === 0
                    text: "Do not disturb is on — popups are muted"
                    dim: true; font.pixelSize: 12
                }
            }

            Flickable {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.5
                visible: root.shown.length > 0
                contentHeight: groupsColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: groupsColumn
                    width: parent.width
                    spacing: 14

                    Repeater {
                        model: ScriptModel { values: root.groups.order }
                        delegate: Column {
                            id: group
                            required property string modelData
                            readonly property string app: modelData
                            readonly property var items: root.groups.items[app] ?? []
                            width: groupsColumn.width
                            spacing: 6

                            // App header (only when grouping by app)
                            RowLayout {
                                width: parent.width
                                visible: group.app !== ""
                                Label {
                                    text: group.app.toUpperCase()
                                    dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1
                                }
                                Label { text: group.items.length; dim: true; font.pixelSize: 11; visible: group.items.length > 1 }
                                Item { Layout.fillWidth: true }
                                Label {
                                    text: "Clear"
                                    dim: !groupClear.containsMouse
                                    font.pixelSize: 11
                                    MouseArea { id: groupClear; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: group.items.slice().forEach(n => n.dismiss()) }
                                }
                            }

                            Repeater {
                                model: ScriptModel { values: group.items }
                                delegate: NotificationCard {
                                    required property var modelData
                                    notif: modelData
                                    width: group.width
                                    showApp: group.app === ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
