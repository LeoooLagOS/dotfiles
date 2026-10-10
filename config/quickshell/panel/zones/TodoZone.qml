import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: To-do (Calendar tab) — tasks and ideas (~/.config/lagos/todo.json).
// Add with Enter; choose Task or Idea and an optional due date (Today /
// Tomorrow / none). Click the circle to complete, click the text to edit,
// × to delete. Overdue items show their date in red.
// Keyboard: Tab to a row, Space completes, Enter edits, Delete removes.
Zone {
    id: root
    title: "To-do"
    icon: ""
    badge: Todos.openCount > 0 ? String(Todos.openCount) : ""

    property string filter: "all"          // all | task | idea
    property string newKind: "task"
    property string newDue: ""             // "" | today | tomorrow

    function dueKey(which) {
        if (!which) return "";
        const d = new Date();
        if (which === "tomorrow") d.setDate(d.getDate() + 1);
        return Events.key(d);
    }
    function addCurrent() {
        Todos.add(input.text, newKind, dueKey(newDue));
        input.text = "";
        newDue = "";
    }

    actions: [
        Chip {
            visible: Todos.doneCount > 0
            implicitHeight: 24
            fontSize: 10
            text: "Clear done (" + Todos.doneCount + ")"
            onClicked: Todos.clearDone()
        }
    ]

    ColumnLayout {
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 8

        // Filter
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: [{ label: "All", value: "all" }, { label: "Tasks", value: "task" }, { label: "Ideas", value: "idea" }]
                delegate: Chip {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    implicitHeight: 26
                    text: modelData.label
                    active: root.filter === modelData.value
                    onClicked: root.filter = modelData.value
                }
            }
        }

        // New item: text + add button, then kind / due chips (wrap if narrow)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            TextField {
                id: input
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                placeholder: root.newKind === "idea" ? "New idea…" : "New task…"
                icon: root.newKind === "idea" ? "\uf0eb" : "\uf067"
                onAccepted: root.addCurrent()
            }
            IconButton { icon: "\uf067"; iconSize: 11; implicitWidth: 30; implicitHeight: 30; active: input.text.trim() !== ""
                         onClicked: root.addCurrent() }
        }
        Flow {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: [
                    { label: "Task", group: "kind", value: "task", icon: "\uf0ae" },
                    { label: "Idea", group: "kind", value: "idea", icon: "\uf0eb" },
                    { label: "Today", group: "due", value: "today", icon: "\uf073" },
                    { label: "Tomorrow", group: "due", value: "tomorrow", icon: "" }
                ]
                delegate: Chip {
                    required property var modelData
                    implicitHeight: 24
                    fontSize: 10
                    icon: modelData.icon
                    text: modelData.label
                    tint: Theme.accent2
                    active: modelData.group === "kind" ? root.newKind === modelData.value : root.newDue === modelData.value
                    onClicked: {
                        if (modelData.group === "kind") root.newKind = modelData.value;
                        else root.newDue = root.newDue === modelData.value ? "" : modelData.value;
                    }
                }
            }
        }

        // List
        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: Todos.sorted(root.filter)

            delegate: Rectangle {
                id: row
                required property var modelData
                property bool editing: false
                width: ListView.view.width
                implicitHeight: Math.max(34, content.implicitHeight + 12)
                radius: 8
                color: rowMouse.containsMouse || activeFocus ? Theme.withAlpha(Theme.fg, 0.05) : "transparent"

                // Keyboard: Space completes, Enter edits, Delete removes
                activeFocusOnTab: !editing
                Keys.onSpacePressed: Todos.toggle(modelData.id)
                Keys.onReturnPressed: { editing = true; editField.text = modelData.text; editField.focusInput(); }
                Keys.onDeletePressed: Todos.remove(modelData.id)
                FocusRing {}

                MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }

                RowLayout {
                    id: content
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 4
                    spacing: 8

                    // Check circle
                    Rectangle {
                        implicitWidth: 18; implicitHeight: 18; radius: 9
                        color: row.modelData.done ? Theme.good : "transparent"
                        border.color: row.modelData.done ? Theme.good : Theme.fgDim
                        border.width: 1.5
                        Glyph { anchors.centerIn: parent; visible: row.modelData.done; text: ""; font.pixelSize: 9; color: Theme.onColor(Theme.good) }
                        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                    onClicked: Todos.toggle(row.modelData.id) }
                    }

                    // Text (click to edit)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        visible: !row.editing
                        Label {
                            Layout.fillWidth: true
                            text: row.modelData.text
                            font.pixelSize: 12
                            font.strikeout: row.modelData.done
                            dim: row.modelData.done
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            MouseArea { anchors.fill: parent; cursorShape: Qt.IBeamCursor
                                        onClicked: { row.editing = true; editField.text = row.modelData.text; editField.focusInput(); } }
                        }
                        Row {
                            spacing: 6
                            visible: row.modelData.kind === "idea" || row.modelData.due !== ""
                            Label {
                                visible: row.modelData.kind === "idea"
                                text: "• Idea"
                                color: Theme.accent2
                                font.pixelSize: 9
                            }
                            Label {
                                visible: row.modelData.due !== ""
                                text: "⏰ " + Qt.formatDate(new Date(row.modelData.due + "T12:00"), "MMM d")
                                color: Todos.isOverdue(row.modelData) ? Theme.bad : Theme.fgDim
                                font.pixelSize: 9
                            }
                        }
                    }
                    TextField {
                        id: editField
                        Layout.fillWidth: true
                        visible: row.editing
                        onAccepted: { Todos.edit(row.modelData.id, text); row.editing = false; row.forceActiveFocus(); }
                        input.onActiveFocusChanged: if (!editField.input.activeFocus && row.editing) { Todos.edit(row.modelData.id, text); row.editing = false; }
                    }

                    IconButton {
                        visible: rowMouse.containsMouse && !row.editing
                        icon: ""; iconSize: 9; implicitWidth: 20; implicitHeight: 20; border.width: 0
                        onClicked: Todos.remove(row.modelData.id)
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                visible: list.count === 0
                text: root.filter === "idea" ? "No ideas yet" : root.filter === "task" ? "No tasks" : "Nothing to do"
                dim: true
                font.pixelSize: 12
            }
        }
    }
}
