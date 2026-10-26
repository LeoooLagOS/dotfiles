import QtQuick
import QtQuick.Layouts

// Pill button that opens a list of options below it.
//   Dropdown { icon: "\uf0b0"; options: [{ label: "All", value: "all" }, …]; value: "all"
//              onSelected: v => … }
// The list is drawn above later siblings via `z`; give the Dropdown's parent a
// z above the content it should cover. It opens below, or above when there's
// more room there (the nearest clipping ancestor, e.g. a Flickable, or the
// window), and shrinks to that room, scrolling.
Item {
    id: root
    property string icon: ""
    property string prefix: ""                 // shown before the current option's label
    property var options: []                   // [{ label, value }]
    property var value
    property bool open: false
    property real listWidth: 200
    signal selected(var value)

    readonly property var current: options.find(o => o.value === value) ?? options[0]
    property int highlight: -1              // keyboard-highlighted option while open

    // Keyboard: Enter/Space opens; ↑/↓ move; Enter picks; Esc closes
    activeFocusOnTab: true
    onOpenChanged: {
        highlight = open ? Math.max(0, options.findIndex(o => o.value === value)) : -1;
        if (open) place();
    }
    // Where the list fits: below unless it doesn't and above has more room
    property bool up: false
    property real room: 320
    function place() {
        let clipper = parent;
        while (clipper && !clipper.clip) clipper = clipper.parent;
        const top = clipper ? mapToItem(clipper, 0, 0).y : mapToItem(null, 0, 0).y;
        const bottom = clipper ? clipper.height : (Window.height || 100000);
        const below = bottom - top - height - 12, above = top - 12;
        const want = Math.min(list.implicitHeight + 12, 320);
        up = below < want && above > below;
        room = Math.max(60, Math.min(want, up ? above : below));
    }
    onActiveFocusChanged: if (!activeFocus) open = false
    Keys.onPressed: event => {
        const k = event.key;
        if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) {
            if (open && highlight >= 0) { selected(options[highlight].value); open = false; }
            else open = !open;
            event.accepted = true;
        } else if (open && k === Qt.Key_Down) {
            highlight = Math.min(options.length - 1, highlight + 1); event.accepted = true;
        } else if (open && k === Qt.Key_Up) {
            highlight = Math.max(0, highlight - 1); event.accepted = true;
        } else if (open && k === Qt.Key_Escape) {
            open = false; event.accepted = true;
        }
    }

    implicitWidth: pill.implicitWidth
    implicitHeight: 28
    z: open ? 100 : 0

    Rectangle {
        id: pill
        anchors.fill: parent
        implicitWidth: row.implicitWidth + 22
        radius: 14
        color: root.open ? Theme.withAlpha(Theme.accent, 0.18) : (pillMouse.containsMouse ? Theme.bgHover : "transparent")
        border.color: root.open ? Theme.accent : Theme.border

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6
            Glyph { visible: root.icon !== ""; text: root.icon; font.pixelSize: 11; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
            Label { text: root.prefix + (root.current?.label ?? ""); font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Glyph { text: root.open ? "\uf077" : "\uf078"; font.pixelSize: 8; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { root.forceActiveFocus(); root.open = !root.open; }
        }
    }

    FocusRing { radius: root.height / 2 }

    // Option list
    Rectangle {
        visible: root.open
        y: root.up ? -height - 6 : root.height + 6
        // Fixed width (not from the options' widths, which would loop with the Column)
        width: Math.max(root.width, root.listWidth)
        height: Math.min(list.implicitHeight + 12, root.room)
        radius: 12
        color: Theme.bgAlt
        border.color: Theme.border
        clip: true

        Flickable {
            anchors.fill: parent
            anchors.margins: 6
            contentHeight: list.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: list
                width: parent.width
                Repeater {
                    model: root.options
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        readonly property bool isCurrent: modelData.value === root.value
                        width: list.width
                        height: 30
                        radius: 8
                        color: isCurrent ? Theme.withAlpha(Theme.accent, 0.16)
                             : (optMouse.containsMouse || index === root.highlight ? Theme.bgHover : "transparent")
                        Glyph { x: 8; anchors.verticalCenter: parent.verticalCenter; text: parent.isCurrent ? "\uf00c" : ""; font.pixelSize: 10; color: Theme.accent }
                        Label { x: 26; width: parent.width - 32; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; font.pixelSize: 12 }
                        MouseArea {
                            id: optMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.selected(parent.modelData.value); root.open = false; }
                        }
                    }
                }
            }
        }
    }
}
