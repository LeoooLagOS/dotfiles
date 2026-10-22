import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"
import "../common/When.js" as When

// ZONE: To-do (Calendar tab) — Teams assignments and the task providers'
// tasks to hand in (Events.deadlines, done with their circle), then tasks and
// ideas (~/.config/lagos/todo.json), each due date with the time left (red under a day, amber under three).
// Add with Enter; choose Task or Idea and an optional due date (Today /
// Tomorrow / none). Click the circle to complete, click the text to edit,
// × to delete. Overdue items show their date in red. An idea has a copy
// button always at hand (wl-copy, then paste it anywhere).
// Keyboard: Tab to a row, Space completes, Enter edits, Delete removes, Ctrl+C copies an idea.
Zone {
    id: root
    title: Tr.t("To-do")
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
    // A task is read in plain words (common/When.js: "pagar la luz viernes",
    // "estudiar BD todos los días 8pm"); the Today / Tomorrow chips win over it
    readonly property var parsed: newKind === "task" && input.text.trim() ? When.parse(input.text + " #task") : null
    function addCurrent() {
        const r = parsed;
        if (r && r.title) Todos.add(r.title, "task", dueKey(newDue) || r.date, newDue ? "" : r.start, r.repeat, r.place);
        else Todos.add(input.text, newKind, dueKey(newDue));
        input.text = "";
        newDue = "";
    }

    actions: [
        Chip {
            visible: Todos.doneCount > 0
            implicitHeight: 24
            fontSize: 10
            text: Tr.t("Clear done (%1)", Todos.doneCount)
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
                model: [{ label: Tr.t("All"), value: "all" }, { label: Tr.t("Tasks"), value: "task" }, { label: Tr.t("Ideas"), value: "idea" }]
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
                placeholder: root.newKind === "idea" ? Tr.t("New idea…") : Tr.t("New task…")
                icon: root.newKind === "idea" ? "\uf0eb" : "\uf067"
                onAccepted: root.addCurrent()
            }
            IconButton { icon: "\uf067"; iconSize: 11; implicitWidth: 30; implicitHeight: 30; active: input.text.trim() !== ""
                         onClicked: root.addCurrent() }
        }
        // What it understood
        Label {
            visible: !!root.parsed && (root.parsed.date !== "" || root.parsed.repeat !== "")
            Layout.fillWidth: true
            text: root.parsed ? When.describe(root.parsed, null, Tr).slice(1).map(c => c.text).join("  ·  ") + "  →  “" + root.parsed.title + "”" : ""
            color: Theme.accent2
            font.pixelSize: 10
            elide: Text.ElideRight
        }
        Flow {
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: [
                    { label: Tr.t("Task"), group: "kind", value: "task", icon: "\uf0ae" },
                    { label: Tr.t("Idea"), group: "kind", value: "idea", icon: "\uf0eb" },
                    { label: Tr.t("Today"), group: "due", value: "today", icon: "\uf073" },
                    { label: Tr.t("Tomorrow"), group: "due", value: "tomorrow", icon: "" }
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

        // What's to hand in from elsewhere (Events.deadlines): Teams assignments,
        // then each task provider's (scripts/providers.py), above the list
        Repeater {
            model: {
                if (root.filter === "idea") return [];
                const groups = [], at = {};
                for (const x of Events.deadlines) {
                    if (x.kind === "todo") continue;
                    const k = x.kind === "teams" ? "teams" : "p:" + x.source;
                    if (!(k in at)) { at[k] = groups.length; groups.push({ name: x.kind === "teams" ? "Teams" : x.label, items: [] }); }
                    groups[at[k]].items.push(x);
                }
                return groups;
            }
            delegate: Column {
                id: group
                required property var modelData
                Layout.fillWidth: true
                spacing: 4
                Label { text: Tr.t("FROM %1", group.modelData.name).toUpperCase(); dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1 }
                Repeater {
                    model: group.modelData.items
                    delegate: DeadlineRow { required property var modelData; item: modelData; width: group.width }
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
                property bool picking: false              // the date picker open
                property bool copied: false               // an idea just copied: ✓ for a moment
                function copy() {
                    Quickshell.execDetached(["wl-copy", "--", modelData.text]);
                    copied = true;
                    copiedTimer.restart();
                }
                Timer { id: copiedTimer; interval: 1200; onTriggered: row.copied = false }
                width: ListView.view.width
                implicitHeight: Math.max(34, content.implicitHeight + 12) + (picking ? picker.implicitHeight + 8 : 0)
                radius: 8
                color: rowMouse.containsMouse || activeFocus ? Theme.withAlpha(Theme.fg, 0.05) : "transparent"

                // Keyboard: Space completes, Enter edits, Delete removes
                activeFocusOnTab: !editing
                Keys.onSpacePressed: Todos.toggle(modelData.id)
                Keys.onReturnPressed: { editing = true; editField.text = modelData.text; editField.focusInput(); }
                Keys.onDeletePressed: Todos.remove(modelData.id)
                Keys.onPressed: e => {
                    if (e.key === Qt.Key_C && (e.modifiers & Qt.ControlModifier) && modelData.kind === "idea") { copy(); e.accepted = true; }
                }
                FocusRing {}

                MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }

                RowLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 6
                    anchors.rightMargin: 4
                    y: Math.max(6, (Math.max(34, implicitHeight + 12) - implicitHeight) / 2)
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
                            visible: row.modelData.kind === "idea" || row.modelData.due !== "" || (!row.modelData.done && rowMouse.containsMouse)
                            Label {
                                visible: row.modelData.kind === "idea"
                                text: Tr.t("• Idea")
                                color: Theme.accent2
                                font.pixelSize: 9
                            }
                            Label {
                                visible: row.modelData.kind !== "idea" && (row.modelData.due !== "" || !row.modelData.done)
                                readonly property var asDeadline: ({ due: Todos.dueAt(row.modelData), dateOnly: !row.modelData.time })
                                text: row.modelData.due ? "⏰ " + Events.dueText(asDeadline) + (row.modelData.repeat ? "  \uf01e" : "") : Tr.t("+ date")
                                color: row.modelData.done || !row.modelData.due ? Theme.fgDim : Events.dueColor(asDeadline)
                                font.pixelSize: 9
                                MouseArea { anchors.fill: parent; anchors.margins: -3; enabled: !row.modelData.done
                                            cursorShape: Qt.PointingHandCursor; onClicked: row.picking = !row.picking }
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

                    // Copy an idea: one click, then paste it anywhere
                    IconButton {
                        visible: row.modelData.kind === "idea" && !row.editing
                        icon: row.copied ? "\uf00c" : "\uf0c5"; iconSize: 10; implicitWidth: 22; implicitHeight: 22; border.width: 0
                        iconColor: row.copied ? Theme.good : (rowMouse.containsMouse ? Theme.fg : Theme.fgDim)
                        onClicked: row.copy()
                    }
                    IconButton {
                        visible: (rowMouse.containsMouse || row.picking) && !row.editing
                        icon: ""; iconSize: 9; implicitWidth: 20; implicitHeight: 20; border.width: 0
                        onClicked: Todos.remove(row.modelData.id)
                    }
                }
                DuePicker {
                    id: picker
                    visible: row.picking
                    x: 32
                    y: content.y + content.height + 6
                    width: row.width - 40
                    due: row.modelData.due
                    time: row.modelData.time ?? ""
                    repeat: row.modelData.repeat ?? ""
                    onPicked: (due, time) => { Todos.setDue(row.modelData.id, due, time); row.picking = false; }
                    onRepeatPicked: r => Todos.setRepeat(row.modelData.id, r)
                }
            }

            Label {
                anchors.centerIn: parent
                visible: list.count === 0
                text: root.filter === "idea" ? Tr.t("No ideas yet") : root.filter === "task" ? Tr.t("No tasks") : Tr.t("Nothing to do")
                dim: true
                font.pixelSize: 12
            }
        }
    }
}
