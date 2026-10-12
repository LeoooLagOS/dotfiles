import QtQuick
import Quickshell
import Quickshell.Wayland
import "./common"
import "./services"

// Dock under the communication apps (services/Comms.qml), like macOS's: shown
// on a monitor while one of them is up (SUPER Y). It rests half hidden below
// the screen edge (the app gets that room) and rises while the mouse is on it. An icon per app — a dot
// under the running ones, the unread count, the shown one highlighted;
// hovering grows it and names it. Click: switch to it (it starts if it isn't
// running); the shown one hides them (as does SUPER Y).
// The app above fills the screen down to the dock: its special workspace has
// a bottom gap (UserConfigs/user_window_rules.lua) of `peek` + 6 px.
Scope {
    readonly property int iconSize: 48
    readonly property int pad: 12
    readonly property int peek: 40            // what shows of the dock at rest

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            readonly property bool up: (Comms.shownOn[modelData.name] ?? "") !== ""

            visible: up || hideAnim.running
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors.bottom: true
            // Room above the raised dock for the grown icon and its name
            implicitWidth: dock.width + 80
            implicitHeight: dock.height + 10 + 56

            // Raised while hovered; lowered a moment after the mouse leaves
            property bool raised: false
            readonly property bool hovering: dockHover.hovered
            onHoveringChanged: if (hovering) { lowerTimer.stop(); raised = true; } else lowerTimer.restart()
            onUpChanged: if (!up) raised = false
            Timer { id: lowerTimer; interval: 450; onTriggered: win.raised = false }

            WlrLayershell.namespace: "quickshell:dock"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            // Only the dock takes clicks; the rest passes through to the app
            mask: Region { item: dock }

            Rectangle {
                id: dock
                anchors.horizontalCenter: parent.horizontalCenter
                y: !win.up ? parent.height + 8 : win.raised ? parent.height - height - 10 : parent.height - peek
                Behavior on y { NumberAnimation { id: hideAnim; duration: 200; easing.type: Easing.OutCubic } }
                HoverHandler { id: dockHover }
                width: row.width + 2 * 10
                height: 72
                radius: 22
                color: Theme.withAlpha(Theme.bg, 0.78)
                border.color: Theme.border

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: Comms.apps
                        delegate: Item {
                            id: cell
                            required property var modelData
                            readonly property bool shown: Comms.shownOn[win.modelData.name] === modelData.key
                            width: 56
                            height: 56

                            // The shown app: a soft tile behind it
                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: cell.shown ? Theme.withAlpha(Theme.accent, 0.22) : "transparent"
                                border.color: cell.shown ? Theme.withAlpha(Theme.accent, 0.5) : "transparent"
                            }

                            Item {
                                id: iconBox
                                width: 44; height: 44
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -2
                                scale: mouse.containsMouse ? 1.28 : 1
                                transformOrigin: Item.Bottom
                                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
                                opacity: cell.modelData.running ? 1 : 0.55

                                Image {
                                    id: img
                                    anchors.fill: parent
                                    source: cell.modelData.icon
                                    sourceSize: Qt.size(96, 96)
                                    smooth: true
                                    asynchronous: true
                                }
                                // No icon: the app's initial
                                Rectangle {
                                    visible: img.status !== Image.Ready
                                    anchors.fill: parent
                                    radius: 12
                                    color: Theme.accent
                                    Label { anchors.centerIn: parent; text: cell.modelData.name[0]; color: Theme.accentText; font.pixelSize: 22; font.weight: Font.DemiBold }
                                }
                                // Unread
                                Rectangle {
                                    visible: cell.modelData.badge > 0
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: -5
                                    width: Math.max(18, badgeText.implicitWidth + 10)
                                    height: 18
                                    radius: 9
                                    color: "#ff3b30"
                                    border.color: Theme.withAlpha(Theme.bg, 0.9)
                                    border.width: 1.5
                                    Label { id: badgeText; anchors.centerIn: parent; text: cell.modelData.badge > 99 ? "99+" : cell.modelData.badge; color: "white"; font.pixelSize: 10; font.weight: Font.Bold }
                                }
                            }

                            // Running
                            Rectangle {
                                visible: cell.modelData.running
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: -5
                                width: 5; height: 5; radius: 2.5
                                color: cell.shown ? Theme.accent : Theme.fgDim
                            }

                            // Name, above the dock while hovered
                            Rectangle {
                                visible: mouse.containsMouse
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: -height - 26
                                width: tip.implicitWidth + 20
                                height: 26
                                radius: 8
                                color: Theme.withAlpha(Theme.bgAlt, 0.95)
                                border.color: Theme.border
                                Label {
                                    id: tip
                                    anchors.centerIn: parent
                                    font.pixelSize: 12
                                    text: cell.shown ? "Hide " + cell.modelData.name + "  ·  Super Y"
                                        : cell.modelData.running ? cell.modelData.name : "Open " + cell.modelData.name
                                }
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Comms.pick(cell.modelData.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
