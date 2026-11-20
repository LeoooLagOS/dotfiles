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
    property bool bare: false                   // no card of its own: a cell inside another one (the tray in the workspaces')
    // What it is and its keys, shown below the bar on hover (bar/BarTip.qml)
    property var tip: null
    property Item barTip: null
    readonly property bool isCard: !bare        // the tip lines up with the card (bar/BarTip.qml)
    readonly property bool hovered: mouse.containsMouse
    readonly property real contentWidth: row.implicitWidth
    readonly property bool islands: Settings.v.barStyle === "islands"
    signal clicked(int button)
    signal wheel(int delta)

    implicitHeight: Settings.v.barHeight - 8
    implicitWidth: square ? implicitHeight : row.implicitWidth + 2 * pad
    radius: 11
    // Active: the accent tints the card instead of replacing it, so the
    // icon stays readable on any wallpaper, dark or light
    readonly property color tint: Theme.withAlpha(BarState.accent, hovered ? 0.30 : 0.20)
    color: active ? (islands && !bare ? Qt.tint(Theme.bg, tint) : tint)
         : clickable && hovered ? Theme.bgHover
         : islands && !bare ? Theme.bg : "transparent"
    border.width: islands && !bare ? 1 : 0
    border.color: Theme.border
    Behavior on color { ColorAnimation { duration: Theme.anim } }
    Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    // Passive: it still sees the pointer over a child's own MouseArea
    HoverHandler {
        enabled: !!root.barTip && !!root.tip
        onHoveredChanged: hovered ? root.barTip.show(root) : root.barTip.hide(root)
    }

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
