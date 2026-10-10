import QtQuick
import QtQuick.Layouts

// Quick-settings tile: click toggles, the arrow opens a settings app.
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
    signal toggled()
    signal settingsClicked()

    // Keyboard: Enter/Space toggles, → opens the settings app
    activeFocusOnTab: true
    Keys.onReturnPressed: root.toggled()
    Keys.onEnterPressed: root.toggled()
    Keys.onSpacePressed: root.toggled()
    Keys.onRightPressed: root.settingsClicked()

    implicitHeight: 58
    radius: 12
    color: active ? Theme.withAlpha(Theme.accent, mouse.containsMouse ? 0.32 : 0.22)
                  : (mouse.containsMouse ? Theme.bgHover : "transparent")
    border.color: active ? Theme.withAlpha(Theme.accent, 0.6) : Theme.border
    border.width: 1

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 4
        spacing: 10

        Rectangle {
            implicitWidth: 34
            implicitHeight: 34
            radius: 17
            color: root.active ? Theme.accent : Theme.bgHover
            Glyph {
                anchors.centerIn: parent
                text: root.icon
                color: root.active ? Theme.onAccent : Theme.fgDim
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Label { text: root.label; font.pixelSize: 13; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Label { text: root.status; dim: true; font.pixelSize: 11; Layout.fillWidth: true }
        }

        IconButton {
            icon: "\uf054"
            iconSize: 10
            implicitWidth: 24
            implicitHeight: 40
            border.width: 0
            onClicked: root.settingsClicked()
        }
    }

    FocusRing {}
}
