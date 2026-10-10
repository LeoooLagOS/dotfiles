import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Media (compact) — album art filling the card's height; title on top,
// the five transport buttons below and a progress bar at the bottom.
// Click the card (outside the buttons) to open the Media tab.
Zone {
    id: root
    clickable: true
    onClicked: {
        const i = Config.tabs.findIndex(t => t.name === "Media");
        if (i >= 0) PanelState.tab = i;
    }

    readonly property var player: Media.player
    readonly property real inner: root.height - 2 * Theme.zonePadding

    // Toggle (top right): transport buttons ⇄ cava visualizer
    readonly property bool showViz: PanelState.miniVisualizer
    readonly property bool vizOn: showViz && !!player && PanelState.open
                                  && Config.tabs[PanelState.tab]?.name === "Overview"
    onVizOnChanged: Cava.users += vizOn ? 1 : -1
    Component.onDestruction: if (vizOn) Cava.users -= 1

    RowLayout {
        visible: !root.player
        width: parent.width
        height: root.inner
        spacing: 10
        Glyph { text: "\uf001"; color: Theme.fgDim; font.pixelSize: 18 }
        Label { text: "Nothing playing"; dim: true; Layout.fillWidth: true }
    }

    RowLayout {
        visible: !!root.player
        width: parent.width
        height: root.inner
        spacing: 12

        // --- Album art, as tall as the card ---
        ClippingRectangle {
            Layout.preferredWidth: root.inner
            Layout.preferredHeight: root.inner
            radius: 10
            color: Theme.bgHover
            Glyph { anchors.centerIn: parent; text: "\uf001"; color: Theme.fgDim; font.pixelSize: 20; visible: art.status !== Image.Ready }
            Image {
                id: art
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(160, 160)
                asynchronous: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Title · artist, with the buttons/visualizer toggle on the right
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Label {
                        Layout.fillWidth: true
                        text: (root.player?.trackTitle || "Unknown title")
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    Label {
                        Layout.fillWidth: true
                        text: root.player?.trackArtist || root.player?.identity || ""
                        dim: true
                        font.pixelSize: 11
                    }
                }
                IconButton {
                    Layout.alignment: Qt.AlignTop
                    icon: root.showViz ? "\uf04b" : "\uf080"     // what you switch to: buttons (▶) ⇄ visualizer (bars)
                    iconSize: 11; implicitWidth: 28; implicitHeight: 24
                    active: root.showViz
                    onClicked: PanelState.miniVisualizer = !PanelState.miniVisualizer
                }
            }

            Item { Layout.fillHeight: true }

            // Cava visualizer (instead of the buttons when toggled); it is also
            // the progress bar: played part in the vivid accent, click to seek
            Item {
                visible: root.showViz
                Layout.fillWidth: true
                Layout.preferredHeight: 32

                Row {
                    id: miniViz
                    anchors.fill: parent
                    readonly property int count: 32
                    Repeater {
                        model: miniViz.count
                        delegate: Item {
                            required property int index
                            width: miniViz.width / miniViz.count
                            height: miniViz.height
                            // Sample the 64 cava bars down to 32
                            readonly property real level: Math.max(Cava.bars[index * 2] ?? 0, Cava.bars[index * 2 + 1] ?? 0)
                            readonly property bool played: (index + 0.5) / miniViz.count <= Media.progress
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(2, parent.width * 0.6)
                                height: Math.max(3, parent.height * parent.level)
                                radius: width / 2
                                color: parent.played ? Theme.vivid : Theme.withAlpha(Theme.fg, 0.25)
                                Behavior on height { NumberAnimation { duration: 60 } }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: (root.player?.canSeek ?? false) && root.player.length > 0
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: mouse => root.player.position = root.player.length * mouse.x / width
                }
            }

            // The five transport buttons
            RowLayout {
                visible: !root.showViz
                Layout.fillWidth: true
                spacing: 2

                IconButton {
                    Layout.fillWidth: true
                    icon: "\uf074"; iconSize: 11; implicitHeight: 26; border.width: 0
                    enabled: root.player?.shuffleSupported ?? false
                    opacity: enabled ? 1 : 0.35
                    active: root.player?.shuffle ?? false
                    onClicked: root.player.shuffle = !root.player.shuffle
                }
                IconButton {
                    Layout.fillWidth: true
                    icon: "\uf048"; iconSize: 11; implicitHeight: 26; border.width: 0
                    onClicked: root.player.previous()
                }
                IconButton {
                    Layout.fillWidth: true
                    icon: root.player?.isPlaying ? "\uf04c" : "\uf04b"; iconSize: 11; implicitHeight: 26
                    active: true
                    onClicked: root.player.togglePlaying()
                }
                IconButton {
                    Layout.fillWidth: true
                    icon: "\uf051"; iconSize: 11; implicitHeight: 26; border.width: 0
                    onClicked: root.player.next()
                }
                IconButton {
                    Layout.fillWidth: true
                    icon: (root.player?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\u{f0458}" : "\uf01e"
                    iconSize: 11; implicitHeight: 26; border.width: 0
                    enabled: root.player?.loopSupported ?? false
                    opacity: enabled ? 1 : 0.35
                    active: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                    onClicked: Media.cycleLoop()
                }
            }

            Item { Layout.preferredHeight: 6; visible: !root.showViz }

            Bar {
                Layout.fillWidth: true
                visible: !root.showViz && (root.player?.lengthSupported ?? false) && root.player.length > 0
                value: Media.progress
            }
        }
    }
}
