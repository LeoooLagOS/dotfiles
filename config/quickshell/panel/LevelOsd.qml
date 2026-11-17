import QtQuick
import Quickshell
import Quickshell.Wayland
import "./common"
import "./services"
import "./bar"

// The island's levels (volume, brightness…; BarState.level) and short messages
// (Do Not Disturb, caffeine, a to-do done…; BarState.flash) when a fullscreen
// window covers the bar (services/Fullscreen.qml): the same pill on the Overlay
// layer, where the island would be, on the focused monitor. As on the island,
// a level wins over a message, and a click runs the message's Undo.
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            // What the island would show now ("" = nothing), only while the bar shows the island
            readonly property string mode: !BarState.islandOn ? ""
                : BarState.level ? "level" : BarState.flash ? "flash" : ""
            readonly property bool wanted: Fullscreen.monitorName === modelData.name && mode !== ""
            // While it fades out it keeps what it showed
            property string lastMode: ""
            property var lastLevel: null
            property var lastFlash: null
            onModeChanged: if (mode) lastMode = mode
            Connections {
                target: BarState
                function onLevelChanged() { if (BarState.level) win.lastLevel = BarState.level; }
                function onFlashChanged() { if (BarState.flash) win.lastFlash = BarState.flash; }
            }
            readonly property string shownMode: mode || lastMode
            // Where the island sits in the bar (TopBar.qml): same top, same height
            readonly property int top: (Settings.v.barStyle === "islands" || Settings.v.barStyle === "floating" ? 6 : 0) + 3

            visible: wanted || pill.opacity > 0
            anchors.top: true
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: pill.width + 40
            implicitHeight: top + pill.height + 12
            color: "transparent"
            WlrLayershell.namespace: "quickshell:osd"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // The island's look (bar/Island.qml): a near-black pill, whatever the theme
            Rectangle {
                id: pill
                readonly property color accent: Theme.ensure(BarState.accent, color, 3)
                x: Math.round((parent.width - width) / 2)
                y: win.top
                width: (win.shownMode === "flash" ? flashRow.implicitWidth : levelRow.implicitWidth) + 34
                height: Settings.v.barHeight - 6
                radius: height / 2
                color: Theme.mix(Theme.panel.base, "#000000", Theme.light ? 0.85 : 0.55)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.07)
                opacity: win.wanted ? 1 : 0
                scale: win.wanted ? 1 : 0.9
                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                onOpacityChanged: if (opacity === 0) { win.lastMode = ""; win.lastLevel = null; win.lastFlash = null; }

                // A message's Undo (under the level's bar, which takes its own drags)
                MouseArea {
                    anchors.fill: parent
                    enabled: win.mode === "flash" && !!BarState.flash?.undo
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: BarState.undoFlash()
                }
                LevelRow {
                    id: levelRow
                    visible: win.shownMode === "level"
                    anchors.centerIn: parent
                    lvl: BarState.level ?? win.lastLevel
                    accent: pill.accent
                }
                FlashRow {
                    id: flashRow
                    visible: win.shownMode === "flash"
                    anchors.centerIn: parent
                    flash: BarState.flash ?? win.lastFlash
                    accent: pill.accent
                }
            }
        }
    }
}
