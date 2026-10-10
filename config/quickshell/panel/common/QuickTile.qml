import QtQuick
import QtQuick.Layouts

// Controls tile: the body toggles, the › opens its detail, right-click opens
// its Settings section.
//   QuickTile { icon: ""; label: "Wi-Fi"; status: "Home"; active: true
//               onToggled: …; onDetailRequested: …; onSettingsRequested: … }
Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
    property bool selected: false         // its detail is the one shown
    property bool hasSettings: false
    signal toggled()
    signal detailRequested()
    signal settingsRequested()

    implicitHeight: 54
    radius: 12
    color: active ? Theme.withAlpha(Theme.accent, body.containsMouse ? 0.28 : 0.20)
                  : (body.containsMouse ? Theme.bgHover : Theme.bgAlt)
    border.color: selected ? Theme.accent : active ? Theme.withAlpha(Theme.accent, 0.55) : Theme.border
    border.width: selected ? 2 : 1
    Behavior on color { ColorAnimation { duration: Theme.anim } }

    // Keyboard: Enter/Space toggles, → opens the detail
    activeFocusOnTab: true
    Keys.onReturnPressed: root.toggled()
    Keys.onEnterPressed: root.toggled()
    Keys.onSpacePressed: root.toggled()
    Keys.onRightPressed: root.detailRequested()

    MouseArea {
        id: body
        anchors.fill: parent
        anchors.rightMargin: more.width
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) { if (root.hasSettings) root.settingsRequested(); }
            else root.toggled();
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 9
        anchors.rightMargin: more.width
        spacing: 9

        Rectangle {
            implicitWidth: 32
            implicitHeight: 32
            radius: 16
            color: root.active ? Theme.accent : Theme.bgHover
            Glyph {
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: 14
                color: root.active ? Theme.onAccent : Theme.fgDim
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label { text: root.label; font.pixelSize: 13; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Label { text: root.status; dim: true; font.pixelSize: 11; Layout.fillWidth: true }
        }
    }

    // › detail
    Rectangle {
        id: more
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: root.border.width
        width: 26
        radius: root.radius
        color: moreMouse.containsMouse ? Theme.withAlpha(Theme.fg, 0.06) : "transparent"
        Rectangle { width: 1; height: parent.height; color: Theme.border }
        Glyph { anchors.centerIn: parent; text: ""; font.pixelSize: 9; color: Theme.fgDim }
        MouseArea {
            id: moreMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.detailRequested()
        }
    }

    FocusRing {}
}
