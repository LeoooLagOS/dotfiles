import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Media (full tab) — large album art; track info with two side buttons
// (system volume as a vertical slider, audio output picker); transport
// controls; and at the bottom a cava visualizer that doubles as the seekable
// progress bar, with elapsed / total time.
// Keyboard: Space play/pause, ←/→ previous/next (when no control has focus);
// Tab to the side buttons, Enter opens their popover (↑/↓ inside, Esc closes).
Zone {
    id: root
    readonly property var player: Media.player
    readonly property var sinkAudio: Media.sink?.audio ?? null

    // Which popover is open: "", "volume" or "output"
    property string popover: ""

    // Run cava only while this tab is on screen
    readonly property bool visualize: PanelState.open && Config.tabs[PanelState.tab]?.name === "Media"
    onVisualizeChanged: {
        Cava.users += visualize ? 1 : -1;
        if (!visualize) popover = "";        // close popovers when leaving the tab
    }
    Component.onDestruction: if (visualize) Cava.users -= 1

    // Empty state
    Item {
        visible: !root.player
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        Column {
            anchors.centerIn: parent
            spacing: 10
            Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: "\uf001"; font.pixelSize: 48; color: Theme.fgDim }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Nothing playing"; dim: true; font.pixelSize: 15 }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Play something in Spotify, Firefox, mpv…"; dim: true; font.pixelSize: 12 }
        }
    }

    RowLayout {
        visible: !!root.player
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        spacing: 24

        // --- Album art ---
        ClippingRectangle {
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            radius: Theme.zoneRadius
            color: Theme.bgHover

            Glyph { anchors.centerIn: parent; text: "\uf001"; font.pixelSize: 64; color: Theme.fgDim; visible: art.status !== Image.Ready }
            Image {
                id: art
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(600, 600)
                asynchronous: true
            }
        }

        // --- Info, controls, visualizer ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Player picker (only when there is more than one)
            Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: Media.players.length > 1
                Repeater {
                    model: Media.players
                    delegate: Chip {
                        required property var modelData
                        implicitHeight: 26
                        // Identity alone is ambiguous (e.g. two Firefox tabs): add the track
                        text: { const t = modelData.identity.split(" ")[0] + (modelData.trackTitle ? " · " + modelData.trackTitle : "");
                                return t.length > 34 ? t.slice(0, 33) + "…" : t; }
                        active: modelData === root.player
                        onClicked: Media.pick(modelData)
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Track info + side buttons (volume, output)
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label {
                        text: root.player?.identity ?? ""
                        dim: true
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        Layout.fillWidth: true
                    }
                    Label {
                        text: root.player?.trackTitle || "Unknown title"
                        color: Theme.accent
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                    }
                    Label { text: root.player?.trackArtist ?? ""; font.pixelSize: 15; visible: text !== ""; Layout.fillWidth: true }
                    Label { text: root.player?.trackAlbum ?? ""; dim: true; font.pixelSize: 13; visible: text !== ""; Layout.fillWidth: true }
                }

                ColumnLayout {
                    id: sideButtons
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    IconButton {
                        id: volumeButton
                        icon: (root.sinkAudio?.muted ?? false) ? "\uf026" : "\uf028"
                        active: root.popover === "volume"
                        onClicked: { root.popover = root.popover === "volume" ? "" : "volume"; if (root.popover) vslider.forceActiveFocus(); }
                    }
                    IconButton {
                        id: outputButton
                        icon: "\u{f04c3}"     // speaker / audio output
                        active: root.popover === "output"
                        onClicked: { root.popover = root.popover === "output" ? "" : "output"; if (root.popover) outputFocus.start(); }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Transport controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                IconButton {
                    icon: "\uf074"; iconSize: 13; border.width: 0
                    enabled: root.player?.shuffleSupported ?? false
                    opacity: enabled ? 1 : 0.35
                    active: root.player?.shuffle ?? false
                    onClicked: root.player.shuffle = !root.player.shuffle
                }
                IconButton { icon: "\uf048"; iconSize: 15; implicitWidth: 44; implicitHeight: 40; border.width: 0
                             onClicked: root.player.previous() }
                IconButton { icon: root.player?.isPlaying ? "\uf04c" : "\uf04b"; iconSize: 18; implicitWidth: 56; implicitHeight: 48
                             radius: 24; active: true; onClicked: root.player.togglePlaying() }
                IconButton { icon: "\uf051"; iconSize: 15; implicitWidth: 44; implicitHeight: 40; border.width: 0
                             onClicked: root.player.next() }
                IconButton {
                    icon: (root.player?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\u{f0458}" : "\uf01e"
                    iconSize: 13; border.width: 0
                    enabled: root.player?.loopSupported ?? false
                    opacity: enabled ? 1 : 0.35
                    active: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                    onClicked: Media.cycleLoop()
                }
            }

            // Cava visualizer as progress bar: elapsed | bars (played part in accent) | total
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 10

                Label { Layout.alignment: Qt.AlignBottom; text: Media.fmt(root.player?.position); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }

                Item {
                    id: viz
                    Layout.fillWidth: true
                    implicitHeight: 76

                    readonly property int count: 64
                    readonly property real slot: width / count

                    Row {
                        anchors.fill: parent
                        Repeater {
                            model: viz.count
                            delegate: Item {
                                required property int index
                                width: viz.slot
                                height: viz.height
                                readonly property real level: Cava.bars[index] ?? 0
                                readonly property bool played: (index + 0.5) / viz.count <= Media.progress
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Math.max(2, viz.slot * 0.6)
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

                Label { Layout.alignment: Qt.AlignBottom; text: Media.fmt(root.player?.length); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }
            }
        }
    }

    // ---------------- Popovers ----------------

    // Focus the current output (or the first) once the list is shown
    Timer {
        id: outputFocus
        interval: 30
        onTriggered: {
            const i = Math.max(0, Media.sinks.indexOf(Media.sink));
            const item = outputRepeater.itemAt(i);
            if (item) item.forceActiveFocus();
        }
    }

    // Click anywhere else to close the open popover
    MouseArea {
        parent: root
        anchors.fill: parent
        visible: root.popover !== ""
        z: 9
        onClicked: root.popover = ""
    }

    // Vertical volume slider (system output), left of the speaker button
    Rectangle {
        parent: root
        z: 10
        visible: root.popover === "volume"
        width: 64
        height: 210
        radius: 16
        color: Theme.bgAlt
        border.color: Theme.border
        // mapToItem isn't reactive: re-evaluate whenever the popover opens or the zone resizes
        readonly property point anchor: { root.popover; root.width; root.height;
                                          return volumeButton.mapToItem(root, 0, volumeButton.height / 2); }
        x: anchor.x - width - 10
        y: Math.max(8, Math.min(root.height - height - 8, anchor.y - height / 2))

        MouseArea { anchors.fill: parent }   // keep clicks inside

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: (root.sinkAudio?.muted ?? false) ? "Mute" : Math.round((root.sinkAudio?.volume ?? 0) * 100) + "%"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            // Track + fill + knob, drag vertically
            Item {
                id: vslider
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 24

                // Keyboard: ↑/↓ by 5%, M mutes, Esc closes the popover
                focus: root.popover === "volume"
                function nudge(d) { if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, root.sinkAudio.volume + d)); }
                Keys.onUpPressed: nudge(0.05)
                Keys.onDownPressed: nudge(-0.05)
                Keys.onRightPressed: nudge(0.05)
                Keys.onLeftPressed: nudge(-0.05)
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_M && root.sinkAudio) { root.sinkAudio.muted = !root.sinkAudio.muted; event.accepted = true; }
                    else if (event.key === Qt.Key_Escape) { root.popover = ""; volumeButton.forceActiveFocus(); event.accepted = true; }
                }
                readonly property real value: Math.min(1, root.sinkAudio?.volume ?? 0)

                Rectangle {
                    id: vtrack
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 6
                    height: parent.height
                    radius: 3
                    color: Theme.track
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * vslider.value
                        radius: 3
                        color: Theme.accent
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: vtrack.height * (1 - vslider.value) - height / 2
                    width: 16; height: 16; radius: 8
                    color: Theme.fg
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function set(my) {
                        if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, 1 - my / height));
                    }
                    onPressed: mouse => set(mouse.y)
                    onPositionChanged: mouse => { if (pressed) set(mouse.y); }
                    onWheel: wheel => {
                        if (root.sinkAudio)
                            root.sinkAudio.volume = Math.max(0, Math.min(1, root.sinkAudio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
                    }
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 34; implicitHeight: 28
                icon: (root.sinkAudio?.muted ?? false) ? "\uf026" : "\uf028"
                active: root.sinkAudio?.muted ?? false
                onClicked: if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted
            }
        }
    }

    // Audio output picker (PipeWire sinks), left of the output button
    Rectangle {
        parent: root
        z: 10
        visible: root.popover === "output"
        width: 300
        height: outputList.implicitHeight + 20
        radius: 16
        color: Theme.bgAlt
        border.color: Theme.border
        // mapToItem isn't reactive: re-evaluate whenever the popover opens or the zone resizes
        readonly property point anchor: { root.popover; root.width; root.height;
                                          return outputButton.mapToItem(root, 0, outputButton.height / 2); }
        x: anchor.x - width - 10
        y: Math.max(8, Math.min(root.height - height - 8, anchor.y - height / 2))

        MouseArea { anchors.fill: parent }   // keep clicks inside

        ColumnLayout {
            id: outputList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 4

            Label { text: "OUTPUT"; dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1; Layout.leftMargin: 6 }

            Repeater {
                id: outputRepeater
                model: Media.sinks
                delegate: Rectangle {
                    id: sinkItem
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData === Media.sink
                    Layout.fillWidth: true
                    implicitHeight: 36

                    // Keyboard: ↑/↓ move, Enter picks, Esc closes
                    activeFocusOnTab: root.popover === "output"
                    objectName: "sink" + index
                    Keys.onReturnPressed: { Media.setSink(modelData); root.popover = ""; outputButton.forceActiveFocus(); }
                    Keys.onEnterPressed: { Media.setSink(modelData); root.popover = ""; outputButton.forceActiveFocus(); }
                    Keys.onDownPressed: nextItemInFocusChain(true).forceActiveFocus()
                    Keys.onUpPressed: nextItemInFocusChain(false).forceActiveFocus()
                    Keys.onEscapePressed: { root.popover = ""; outputButton.forceActiveFocus(); }
                    FocusRing {}
                    radius: 10
                    color: current ? Theme.withAlpha(Theme.accent, 0.16) : (sinkMouse.containsMouse || activeFocus ? Theme.bgHover : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Glyph { text: parent.parent.current ? "\uf00c" : ""; font.pixelSize: 11; color: Theme.accent; Layout.preferredWidth: 14 }
                        Label {
                            Layout.fillWidth: true
                            text: Media.sinkName(parent.parent.modelData)
                            font.pixelSize: 12
                            font.weight: parent.parent.current ? Font.DemiBold : Font.Normal
                        }
                    }
                    MouseArea {
                        id: sinkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Media.setSink(parent.modelData); root.popover = ""; }
                    }
                }
            }
        }
    }
}
