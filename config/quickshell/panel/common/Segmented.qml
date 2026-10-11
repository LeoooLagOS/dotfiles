import QtQuick
import QtQuick.Layouts

// Segmented control: one option selected.
//   Segmented { options: [{ value: "a", label: "A", icon: "" }, …]; value: "a"
//               onSelected: v => … }
// Keyboard: Tab to focus, ←/→ to change.
Rectangle {
    id: root
    property var options: []
    property var value
    signal selected(var value)

    implicitHeight: 34
    implicitWidth: row.implicitWidth + 6
    radius: 10
    color: Theme.track

    activeFocusOnTab: true
    readonly property int index: options.findIndex(o => o.value === value)
    Keys.onLeftPressed: if (index > 0) selected(options[index - 1].value)
    Keys.onRightPressed: if (index < options.length - 1) selected(options[index + 1].value)

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 3
        spacing: 3
        Repeater {
            model: root.options
            delegate: Rectangle {
                id: segItem
                required property var modelData
                readonly property bool current: modelData.value === root.value
                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitWidth: inner.implicitWidth + 18
                radius: 8
                color: current ? Theme.accent : (segMouse.containsMouse ? Theme.withAlpha(Theme.fg, 0.06) : "transparent")
                Row {
                    id: inner
                    anchors.centerIn: parent
                    spacing: 5
                    Glyph {
                        visible: !!segItem.modelData.icon
                        text: segItem.modelData.icon ?? ""
                        font.pixelSize: 11
                        color: segItem.current ? Theme.accentText : Theme.fgDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        text: segItem.modelData.label
                        font.pixelSize: 12
                        font.weight: segItem.current ? Font.DemiBold : Font.Normal
                        color: segItem.current ? Theme.accentText : Theme.fgDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: segMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(segItem.modelData.value)
                }
            }
        }
    }

    FocusRing {}
}
