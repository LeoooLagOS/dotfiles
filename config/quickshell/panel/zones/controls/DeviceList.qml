import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// List of audio devices; the current one is highlighted and checked.
ColumnLayout {
    id: root
    property var nodes: []
    property var current: null
    signal picked(var node)
    spacing: 3

    Repeater {
        model: root.nodes
        delegate: Rectangle {
            id: item
            required property var modelData
            readonly property bool isCurrent: modelData === root.current
            Layout.fillWidth: true
            implicitHeight: 36
            radius: 9
            color: isCurrent ? Theme.withAlpha(Theme.accent, 0.18) : (mouse.containsMouse || activeFocus ? Theme.bgHover : "transparent")
            activeFocusOnTab: true
            Keys.onReturnPressed: root.picked(modelData)
            Keys.onSpacePressed: root.picked(modelData)
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                Glyph { text: Audio.icon(item.modelData); font.pixelSize: 13; color: item.isCurrent ? Theme.accent : Theme.fgDim }
                Label { text: Audio.name(item.modelData); font.pixelSize: 13; Layout.fillWidth: true }
                Glyph { visible: item.isCurrent; text: ""; font.pixelSize: 11; color: Theme.accent }
            }
            MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.picked(item.modelData) }
            FocusRing {}
        }
    }
}
