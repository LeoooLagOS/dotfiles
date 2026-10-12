import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../common"
import "../services"

// The system tray (Teams, Vesktop, Telegram… live here once their window is
// closed): a chevron next to the power button that drops a list below it.
// An app: click opens it · right click: its menu · middle click: its
// secondary action. Closes on a click outside (TopBar's focus grab) or after
// choosing. `dropdown` is the list, for the bar's input mask.
BarPill {
    id: root
    property var barWindow: null
    property bool open: false
    readonly property var items: SystemTray.items.values
    property alias dropdown: drop
    visible: items.length > 0
    square: true
    clickable: true
    active: open
    onClicked: open = !open
    onItemsChanged: if (!items.length) open = false

    Glyph {
        text: root.open ? "" : ""
        font.pixelSize: 10
        color: root.open ? Theme.fg : Theme.fgDim
    }

    // ---------------- The list ----------------
    Rectangle {
        id: drop
        parent: root
        visible: root.open
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.right: parent.right
        width: root.open ? 250 : 0
        height: root.open ? list.implicitHeight + 12 : 0
        radius: 14
        color: Theme.bg
        border.color: Theme.border

        ColumnLayout {
            id: list
            x: 6
            y: 6
            width: parent.width - 12
            spacing: 2
            Repeater {
                model: root.items
                delegate: Rectangle {
                    id: rowItem
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 9
                    color: rowMouse.containsMouse ? Theme.bgHover : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 9
                        anchors.rightMargin: 9
                        spacing: 10
                        IconImage { source: rowItem.modelData.icon; implicitSize: 18 }
                        Label {
                            Layout.fillWidth: true
                            text: rowItem.modelData.tooltipTitle || rowItem.modelData.title || rowItem.modelData.id
                            font.pixelSize: 13
                        }
                        Glyph { visible: rowItem.modelData.hasMenu; text: ""; font.pixelSize: 11; color: Theme.fgDim }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: m => {
                            const it = rowItem.modelData;
                            if (m.button === Qt.MiddleButton) { it.secondaryActivate(); root.open = false; }
                            else if (m.button === Qt.RightButton || it.onlyMenu) {
                                if (it.hasMenu && root.barWindow) {
                                    const p = rowItem.mapToItem(null, rowItem.width - 8, rowItem.height / 2);
                                    it.display(root.barWindow, p.x, p.y);
                                }
                            } else { it.activate(); root.open = false; }
                        }
                    }
                }
            }
        }
    }
}
