import QtQuick

// Rounded icon button. `active` fills it with the accent color.
// Keyboard: Tab to focus, Enter/Space to press.
Rectangle {
    id: root
    property alias icon: glyph.text
    property alias iconSize: glyph.font.pixelSize
    property alias iconRotation: glyph.rotation
    property bool active: false
    property color iconColor: active ? Theme.accentText : Theme.fg
    signal clicked()

    activeFocusOnTab: visible && enabled
    Keys.onReturnPressed: root.clicked()
    Keys.onEnterPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()

    implicitWidth: 38
    implicitHeight: 34
    radius: Theme.buttonRadius
    color: active ? Theme.accent : (mouse.containsMouse ? Theme.bgHover : "transparent")
    border.color: Theme.border
    border.width: 1

    Glyph {
        id: glyph
        anchors.centerIn: parent
        color: root.iconColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    FocusRing {}
}
