import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Wallpapers (full tab) — thumbnail grid of Config.wallpaperDir with a
// folder filter. Click a thumbnail to apply it (same script as SUPER W:
// awww transition + wallust colors + waybar/swaync refresh).
// Keyboard: Tab to the grid, arrows move, Enter applies.
Zone {
    id: root
    property string folder: "*"      // "*" = all folders

    readonly property var shown: folder === "*" ? Wallpapers.items
                                 : Wallpapers.items.filter(i => i.folder === folder)

    Component.onCompleted: Wallpapers.refresh()
    Connections {
        target: PanelState
        function onTabChanged() { if (Config.tabs[PanelState.tab]?.name === "Wallpapers") Wallpapers.refresh(); }
    }

    ColumnLayout {
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        spacing: 10

        // --- Header: folder chips, count, refresh ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: ["*"].concat(Wallpapers.folders)
                delegate: Chip {
                    required property string modelData
                    text: modelData === "*" ? Tr.t("All") : modelData === "" ? Tr.t("Main") : modelData.split("/").pop()
                    active: root.folder === modelData
                    onClicked: root.folder = modelData
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                text: Wallpapers.applying !== "" ? Tr.t("Applying…")
                      : Wallpapers.pending > 0 ? Tr.t("Making thumbnails… (%1)", Wallpapers.pending)
                      : Tr.t("%1 wallpapers", root.shown.length)
                dim: true
                font.pixelSize: 12
            }
            IconButton { icon: "\uf021"; iconSize: 12; implicitWidth: 32; implicitHeight: 28; onClicked: Wallpapers.refresh() }
        }

        // --- Thumbnail grid ---
        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: root.shown

            readonly property int columns: Math.max(2, Math.round(width / 190))
            cellWidth: width / columns
            cellHeight: cellWidth * 9 / 16 + 8

            // Keyboard: Tab into the grid, arrows move, Enter applies
            activeFocusOnTab: true
            keyNavigationEnabled: true
            highlightFollowsCurrentItem: false
            Keys.onReturnPressed: if (currentIndex >= 0) Wallpapers.apply(root.shown[currentIndex].path)
            Keys.onEnterPressed: if (currentIndex >= 0) Wallpapers.apply(root.shown[currentIndex].path)
            // Start on the current wallpaper
            onActiveFocusChanged: if (activeFocus) {
                const i = root.shown.findIndex(w => w.path === Wallpapers.current);
                if (i >= 0) { currentIndex = i; positionViewAtIndex(i, GridView.Contain); }
            }

            delegate: Item {
                id: tile
                required property var modelData
                required property int index
                readonly property bool isCurrent: modelData.path === Wallpapers.current
                readonly property bool focused: grid.activeFocus && grid.currentIndex === index
                width: grid.cellWidth
                height: grid.cellHeight

                ClippingRectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 10
                    color: Theme.bgHover

                    Image {
                        anchors.fill: parent
                        source: "file://" + tile.modelData.thumb
                        sourceSize: Qt.size(320, 180)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    // Name on hover
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 22
                        color: Theme.scrim
                        visible: tileMouse.containsMouse
                        Label {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: tile.modelData.name
                            font.pixelSize: 10
                        }
                    }

                    // Applying spinner-ish overlay
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.withAlpha(Theme.base, 0.55)
                        visible: Wallpapers.applying === tile.modelData.path
                        Glyph {
                            id: spinner
                            anchors.centerIn: parent
                            text: "\uf110"
                            font.pixelSize: 20
                            RotationAnimation on rotation { from: 0; to: 360; duration: 1000; loops: Animation.Infinite; running: spinner.visible }
                        }
                    }
                }

                // Current-wallpaper ring + hover ring
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: 11
                    color: "transparent"
                    border.color: tile.focused ? Theme.vivid : Theme.accent
                    border.width: tile.focused ? 3 : tile.isCurrent ? 2.5 : (tileMouse.containsMouse ? 1 : 0)
                }
                Rectangle {
                    visible: tile.isCurrent
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 10
                    width: 20; height: 20; radius: 10
                    color: Theme.accent
                    Glyph { anchors.centerIn: parent; text: "\uf00c"; font.pixelSize: 10; color: Theme.accentText }
                }

                MouseArea {
                    id: tileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { grid.currentIndex = tile.index; Wallpapers.apply(tile.modelData.path); }
                }
            }
        }
    }
}
