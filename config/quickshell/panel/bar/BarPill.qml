import QtQuick
import "../common"
import "../services"

// One group of the bar. Islands style: a translucent card like the panel's
// (Theme.bg + border, blurred by Hyprland); full and floating: bare, on the
// bar's own background. Children go in a row, centered.
//   BarPill { clickable: true; onClicked: b => …; Glyph { … } Label { … } }
Rectangle {
    id: root
    default property alias content: row.data
    property int pad: 10
    property alias spacing: row.spacing
    property bool clickable: false
    property bool square: false                 // icon button: as wide as tall
    property bool active: false                 // accent-tinted (DND on, caffeine on…)
    readonly property bool hovered: mouse.containsMouse
    readonly property real contentWidth: row.implicitWidth
    readonly property bool islands: Settings.v.barStyle === "islands"
    signal clicked(int button)
    signal wheel(int delta)

    implicitHeight: Settings.v.barHeight - 8
    implicitWidth: square ? implicitHeight : row.implicitWidth + 2 * pad
    radius: 11
    color: active ? Theme.withAlpha(BarState.accent, hovered ? 0.30 : 0.20)
         : clickable && hovered ? Theme.bgHover
         : islands ? Theme.bg : "transparent"
    border.width: islands ? 1 : 0
    border.color: Theme.border
    Behavior on color { ColorAnimation { duration: Theme.anim } }
    Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: m => root.clicked(m.button)
        onWheel: w => root.wheel(w.angleDelta.y)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 8
    }
}
