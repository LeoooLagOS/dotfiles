import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services"

// One thing to hand in (Events.deadlines): a circle to mark it done, its
// title, and when it's due with the time left, red under a day, amber under
// three ("Today 23:59 · in 2 h 58 min", "Overdue · Yesterday"). Teams ones
// carry the Teams mark and their class; a provider's task with a link opens
// it from its title.
// A to-do's date is set by clicking it (common/DuePicker.qml: quick days,
// typed, repeat).
//   DeadlineRow { item: Events.deadlines[0]; width: … }
Rectangle {
    id: row
    property var item
    property bool compact: false
    property bool editing: false
    readonly property var todo: item.kind === "todo" ? Todos.items.find(i => i.id === item.id) ?? null : null
    readonly property color tint: Events.dueColor(item)
    implicitHeight: Math.max(compact ? 30 : 34, content.implicitHeight + (compact ? 10 : 12)) + (editing ? picker.implicitHeight + 8 : 0)
    radius: 8
    color: Theme.withAlpha(tint, mouse.containsMouse ? 0.16 : 0.10)

    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }

    // Urgency bar on the left
    Rectangle { x: 6; width: 3; height: parent.height - 12; anchors.verticalCenter: parent.verticalCenter; radius: 1.5; color: row.tint }

    RowLayout {
        id: content
        y: row.compact ? 5 : 6
        x: 14
        width: parent.width - 20
        spacing: 7

        // Done
        Rectangle {
            implicitWidth: 16; implicitHeight: 16; radius: 8
            color: check.containsMouse ? Theme.withAlpha(Theme.good, 0.25) : "transparent"
            border.color: check.containsMouse ? Theme.good : Theme.fgDim
            border.width: 1.5
            Glyph { anchors.centerIn: parent; visible: check.containsMouse; text: ""; font.pixelSize: 8; color: Theme.good }
            MouseArea { id: check; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor; onClicked: Events.complete(row.item) }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                Glyph { visible: row.item.kind === "teams"; text: ""; font.pixelSize: 9; color: Theme.accent2 }
                Glyph { visible: !!row.item.important; text: ""; font.pixelSize: 9; color: Theme.warn }   // ★ important
                Label {
                    Layout.fillWidth: true
                    text: row.item.title
                    font.pixelSize: row.compact ? 11 : 12
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    // A provider's task with a link (e.g. its note): click opens it
                    MouseArea { anchors.fill: parent; enabled: !!row.item.open; cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["xdg-open", row.item.open]) }
                }
            }
            Label {
                Layout.fillWidth: true
                text: Events.dueText(row.item) + (row.item.repeat ? "  ·  \uf01e" : "") + (row.item.where ? "  ·  " + row.item.where : "")
                color: row.item.due ? row.tint : Theme.fgDim
                font.pixelSize: row.compact ? 10 : 11
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
                wrapMode: Text.Wrap
                maximumLineCount: 2
                // A to-do's date: click to change it
                MouseArea { anchors.fill: parent; enabled: !!row.todo; cursorShape: Qt.PointingHandCursor; onClicked: row.editing = !row.editing }
            }
        }
    }
    DuePicker {
        id: picker
        visible: row.editing && !!row.todo
        x: 14
        y: content.y + content.height + 6
        width: parent.width - 22
        due: row.todo?.due ?? ""
        time: row.todo?.time ?? ""
        repeat: row.todo?.repeat ?? ""
        onPicked: (due, time) => { Todos.setDue(row.item.id, due, time); row.editing = false; }
        onRepeatPicked: r => Todos.setRepeat(row.item.id, r)
    }
}
