import QtQuick
import QtQuick.Layouts

// Icon + draggable slider. value is 0..1; emits moved(v) while dragging.
RowLayout {
    id: root
    property alias icon: btn.icon
    property real value: 0
    signal moved(real v)
    signal iconClicked()
    spacing: 10

    IconButton {
        id: btn
        implicitWidth: 34
        implicitHeight: 30
        border.width: 0
        onClicked: root.iconClicked()
    }

    Item {
        id: trackArea
        Layout.fillWidth: true
        implicitHeight: 20
        // Keyboard: ←/→ by 5%, Home/End to 0/100%
        activeFocusOnTab: true
        Keys.onLeftPressed: root.moved(Math.max(0, root.value - 0.05))
        Keys.onRightPressed: root.moved(Math.min(1, root.value + 0.05))
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Home) { root.moved(0); event.accepted = true; }
            else if (event.key === Qt.Key_End) { root.moved(1); event.accepted = true; }
        }
        FocusRing { radius: 6 }

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: Theme.track

            Rectangle {
                width: track.width * root.value
                height: parent.height
                radius: 2
                color: Theme.accent
            }
        }

        Rectangle {
            x: track.width * root.value - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            radius: 6
            color: Theme.fg
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            function update(mx) {
                const v = Math.max(0, Math.min(1, mx / width));
                root.moved(v);
            }
            onPressed: mouse => update(mouse.x)
            onPositionChanged: mouse => { if (pressed) update(mouse.x); }
        }
    }
}
