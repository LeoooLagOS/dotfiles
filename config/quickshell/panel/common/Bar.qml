import QtQuick

// Thin progress bar; value is 0..1, fill color defaults to the accent
Rectangle {
    property real value: 0
    property color fillColor: Theme.accent
    implicitHeight: 4
    radius: 2
    color: Theme.track

    Rectangle {
        width: parent.width * Math.max(0, Math.min(1, parent.value))
        height: parent.height
        radius: parent.radius
        color: parent.fillColor
        Behavior on width { NumberAnimation { duration: 250 } }
        Behavior on color { ColorAnimation { duration: 250 } }
    }
}
