import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Agenda (Calendar tab) — the selected day's events, then the next 7
// days. ★ = important (Outlook events; amber = High importance). Events
// created in the panel can be deleted (×). Header: refresh (forces an Outlook
// download) and "+ New event", which opens the form below the header.
// Keyboard: Tab to "New event", Enter; in the form Tab between fields, Enter
// on a field saves, Esc closes the form.
Zone {
    id: root
    title: "Agenda"
    icon: ""

    property bool creating: false

    function dayTitle(d) {
        const t = new Date(); t.setHours(0, 0, 0, 0);
        const x = new Date(d); x.setHours(0, 0, 0, 0);
        const diff = Math.round((x - t) / 86400000);
        return diff === 0 ? "Today" : diff === 1 ? "Tomorrow" : diff === -1 ? "Yesterday" : Qt.formatDate(d, "dddd");
    }

    // Next 7 days, grouped by date, without the selected day (shown above)
    readonly property var upcomingGroups: {
        const sel = Events.key(Events.selected), groups = [], map = {};
        for (const e of Events.upcoming) {
            if (e.date === sel) continue;
            if (!map[e.date]) { map[e.date] = []; groups.push({ date: e.date, items: map[e.date] }); }
            map[e.date].push(e);
        }
        return groups;
    }

    actions: [
        IconButton {
            icon: ""; iconSize: 11; implicitWidth: 30; implicitHeight: 26
            rotation: Events.loading ? 360 : 0
            Behavior on rotation { RotationAnimation { duration: 800 } }
            onClicked: Events.refresh()
        },
        Chip {
            implicitHeight: 26
            icon: root.creating ? "\uf00d" : "\uf067"
            text: root.creating ? "Cancel" : "New event"
            active: root.creating
            onClicked: root.creating = !root.creating
        }
    ]

    Item {
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding

        // ---------------- New event form ----------------
        EventForm {
            id: form
            anchors.fill: parent
            visible: root.creating
            onDone: root.creating = false
        }

        // ---------------- Lists ----------------
        Flickable {
            anchors.fill: parent
            visible: !root.creating
            contentHeight: lists.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: lists
                width: parent.width
                spacing: 12

                // Selected day
                Column {
                    width: parent.width
                    spacing: 6
                    readonly property var dayEvents: Events.eventsOn(Events.selected)

                    Row {
                        spacing: 8
                        Label { text: root.dayTitle(Events.selected); font.pixelSize: 15; font.weight: Font.DemiBold }
                        Label {
                            anchors.baseline: parent.children[0].baseline
                            text: Qt.formatDate(Events.selected, "ddd").toUpperCase() + " · " + Qt.formatDate(Events.selected, "MMM d")
                            dim: true; font.pixelSize: 11; font.weight: Font.DemiBold
                        }
                    }
                    Label { visible: parent.dayEvents.length === 0; text: Events.loading ? "Loading…" : "No events"; dim: true; font.pixelSize: 12 }
                    Repeater {
                        model: parent.dayEvents
                        delegate: EventCard { required property var modelData; event: modelData; width: lists.width }
                    }
                }

                // Next 7 days
                Column {
                    width: parent.width
                    spacing: 6
                    visible: root.upcomingGroups.length > 0

                    Label { text: "NEXT 7 DAYS"; dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1 }

                    Repeater {
                        model: root.upcomingGroups
                        delegate: Column {
                            required property var modelData
                            width: lists.width
                            spacing: 4
                            Label {
                                readonly property date d: new Date(modelData.date + "T12:00")
                                text: root.dayTitle(d) + "  ·  " + Qt.formatDate(d, "MMM d")
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Theme.accentSoft
                            }
                            Repeater {
                                model: modelData.items
                                delegate: EventCard { required property var modelData; event: modelData; width: lists.width; compact: true }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------- Event card ----------------
    component EventCard: Rectangle {
        id: card
        property var event
        property bool compact: false
        implicitHeight: info.implicitHeight + (compact ? 10 : 14)
        radius: 8
        color: Theme.withAlpha(Theme.accent2, 0.10)

        Rectangle { x: 6; width: 3; height: parent.height - 12; anchors.verticalCenter: parent.verticalCenter; radius: 1.5; color: Theme.accent2 }

        ColumnLayout {
            id: info
            x: 16
            width: parent.width - 22 - (deleteBtn.visible ? 24 : 0)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                Glyph { visible: card.event.important; text: ""; font.pixelSize: 9; color: card.event.high ? Theme.warn : Theme.accent }
                Label { Layout.fillWidth: true; text: card.event.title; font.pixelSize: card.compact ? 11 : 12; font.weight: Font.DemiBold }
            }
            Label {
                Layout.fillWidth: true
                text: (card.event.allDay ? "All day" : card.event.start + " – " + card.event.end)
                      + (card.event.location ? "  ·  " + card.event.location : "")
                      + "  ·  " + (card.event.source === "outlook" ? "Outlook" : card.event.calendar)
                      + (card.event.reminder > 0 ? "  ·  ⏰ " + card.event.reminder + "m" : "")
                dim: true
                font.pixelSize: 10
            }
        }

        IconButton {
            id: deleteBtn
            visible: card.event.source === "local" && card.event.calendar === "Panel"
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            icon: ""; iconSize: 10; implicitWidth: 22; implicitHeight: 22; border.width: 0
            onClicked: Events.remove(card.event.uid)
        }
    }
}
