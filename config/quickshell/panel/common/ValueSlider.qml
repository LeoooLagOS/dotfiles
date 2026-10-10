import QtQuick

// Slider over a range with steps. Shows `value` while idle; while dragging it
// shows the dragged value and emits moved(v); committed(v) on release.
//   ValueSlider { from: 60; to: 1800; step: 30; value: 300; onCommitted: v => … }
// Keyboard: ←/→ one step, Home/End to the ends.
Item {
    id: root
    property real from: 0
    property real to: 100
    property real step: 1
    property real value: 0
    property real dragValue: value
    property bool dragging: false
    signal moved(real v)
    signal committed(real v)

    readonly property real shown: dragging ? dragValue : value
    readonly property real ratio: (shown - from) / Math.max(1e-9, to - from)

    implicitWidth: 200
    implicitHeight: 20

    function snap(v) { return Math.max(from, Math.min(to, Math.round((v - from) / step) * step + from)); }
    function nudge(d) { const v = snap(value + d); committed(v); }

    activeFocusOnTab: true
    Keys.onLeftPressed: nudge(-step)
    Keys.onRightPressed: nudge(step)
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) { committed(from); event.accepted = true; }
        else if (event.key === Qt.Key_End) { committed(to); event.accepted = true; }
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Theme.track
        Rectangle { width: track.width * root.ratio; height: parent.height; radius: 2; color: Theme.accent }
    }
    Rectangle {
        x: track.width * root.ratio - width / 2
        anchors.verticalCenter: parent.verticalCenter
        width: 14; height: 14; radius: 7
        color: Theme.fg
        border.color: Theme.accent
        border.width: root.activeFocus ? 2 : 0
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        function at(mx) { return root.snap(root.from + Math.max(0, Math.min(1, (mx - 4) / root.width)) * (root.to - root.from)); }
        onPressed: mouse => { root.forceActiveFocus(); root.dragging = true; root.dragValue = at(mouse.x); root.moved(root.dragValue); }
        onPositionChanged: mouse => { if (pressed) { const v = at(mouse.x); if (v !== root.dragValue) { root.dragValue = v; root.moved(v); } } }
        onReleased: { root.dragging = false; root.committed(root.dragValue); }
    }
}
