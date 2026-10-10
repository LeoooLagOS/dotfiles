import QtQuick

// Pill button: optional icon + text. Keyboard: Tab to focus, Enter/Space to press.
//   Chip { text: "All"; active: true; onClicked: … }
//   Chip { text: "Save"; filled: true }        // solid primary button
Rectangle {
    id: root
    property string text: ""
    property string icon: ""
    property bool active: false            // selected state (tinted)
    property bool filled: false            // solid button in `tint`
    property color tint: Theme.accent
    property real fontSize: 11
    property bool bold: false
    signal clicked()

    implicitWidth: row.implicitWidth + 20
    implicitHeight: 28
    radius: height / 2
    opacity: enabled ? 1 : 0.4
    color: filled ? ((mouse.containsMouse || activeFocus) ? Theme.vivid : tint)
         : active ? Theme.withAlpha(tint, 0.22)
         : (mouse.containsMouse ? Theme.bgHover : "transparent")
    border.color: (active || filled) ? tint : Theme.border

    activeFocusOnTab: enabled
    Keys.onReturnPressed: root.clicked()
    Keys.onEnterPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5
        Glyph {
            visible: root.icon !== ""
            text: root.icon
            font.pixelSize: root.fontSize - 1
            color: root.filled ? Theme.onAccent : (root.active ? root.tint : Theme.fgDim)
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            visible: root.text !== ""
            text: root.text
            font.pixelSize: root.fontSize
            font.weight: (root.bold || root.active) ? Font.DemiBold : Font.Normal
            color: root.filled ? Theme.onAccent : Theme.fg
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: { root.forceActiveFocus(); root.clicked(); }
    }

    FocusRing {}
}
