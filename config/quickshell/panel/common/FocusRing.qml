import QtQuick

// Keyboard focus indicator: put inside any focusable item; shows while the
// parent has active focus. Follows the parent's corner radius.
Rectangle {
    anchors.fill: parent
    anchors.margins: -3
    radius: (parent.radius ?? 8) + 3
    color: "transparent"
    border.color: Theme.vivid
    border.width: 2
    visible: parent.activeFocus
    z: 10
}
