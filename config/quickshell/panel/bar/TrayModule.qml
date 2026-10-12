import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../common"
import "../services"

// The system tray, folded behind a chevron (Teams, Vesktop, Telegram… live
// here once their window is closed). Click an icon: the app · right click:
// its menu · middle click: its secondary action.
BarPill {
    id: root
    property var barWindow: null
    property bool open: false
    readonly property var items: SystemTray.items.values
    visible: items.length > 0
    pad: 8
    spacing: 9

    Glyph {
        text: root.open ? "" : ""
        font.pixelSize: 10
        color: chev.containsMouse ? Theme.fg : Theme.fgDim
        width: 14
        height: Settings.v.barHeight - 8
        MouseArea { id: chev; anchors.fill: parent; anchors.margins: -4; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.open = !root.open }
    }
    Repeater {
        model: root.open ? root.items : []
        delegate: IconImage {
            id: ti
            required property var modelData
            source: modelData.icon
            implicitSize: 16
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: m => {
                    const it = ti.modelData;
                    if (m.button === Qt.MiddleButton) it.secondaryActivate();
                    else if (m.button === Qt.RightButton || it.onlyMenu) {
                        if (it.hasMenu && root.barWindow) {
                            const p = ti.mapToItem(null, 0, ti.height + 10);
                            it.display(root.barWindow, p.x, p.y);
                        }
                    } else it.activate();
                }
            }
        }
    }
}
