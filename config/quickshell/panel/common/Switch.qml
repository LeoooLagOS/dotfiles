import QtQuick

// On/off switch. Keyboard: Tab to focus, Enter/Space to flip.
//   Switch { checked: true; onToggled: … }
Rectangle {
    id: root
    property bool checked: false
    signal toggled()

    implicitWidth: 38
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accent : Theme.track
    Behavior on color { ColorAnimation { duration: Theme.anim } }

    activeFocusOnTab: true
    Keys.onReturnPressed: root.toggled()
    Keys.onEnterPressed: root.toggled()
    Keys.onSpacePressed: root.toggled()

    Rectangle {
        width: 16; height: 16; radius: 8
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.onAccent : Theme.fg
        Behavior on x { NumberAnimation { duration: Theme.anim / 1.3; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
    FocusRing {}
}
