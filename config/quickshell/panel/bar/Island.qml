import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../common"
import "../services"

// The island at the center of the bar: a near-black pill, whatever the theme.
//   rest       date · time
//   media      while a player plays: its art on the left, an equalizer on
//              the right; the time stays where it was
//   expanded   hovering it while a player has a track: it grows down with the
//              art, title, progress and controls
//   rec        screen recording (services/Recorder.qml): red dot and elapsed
//              time; a click stops it
//   flash      a short message (BarState.say: Do Not Disturb, caffeine, volume)
//   message    a chat message (BarState.message, instead of a popup): the
//              chat's photo, who and the text; hovering holds it and shows the
//              whole text with Reply and Open; a click opens the chat
// Click: the panel (open / close) · wheel: volume of the output.
// It doesn't grow while the panel is open (it would open behind it), and stays
// grown while a screenshot region is picked (slurp covers it: PanelState.capturing).
Rectangle {
    id: root

    readonly property var player: Media.player
    readonly property bool hasTrack: !!player && !!player.trackTitle
    readonly property bool playing: hasTrack && player.isPlaying
    property bool expandWanted: false
    readonly property var msg: BarState.message
    readonly property string mode: BarState.flash ? "flash"
        : msg ? (expandWanted ? "messageOpen" : "message")
        : Recorder.recording ? "rec"
        : expandWanted && hasTrack ? "expanded"
        : playing ? "media" : "rest"
    readonly property bool isMessage: mode === "message" || mode === "messageOpen"
    readonly property int pillH: Settings.v.barHeight - 6
    readonly property color ink: "#f1f3f5"
    readonly property color inkDim: Qt.rgba(241 / 255, 243 / 255, 245 / 255, 0.6)
    readonly property color accent: Theme.ensure(BarState.accent, color, 3)

    readonly property int expandedH: 196
    width: mode === "expanded" ? 520 : isMessage ? 480 : (mode === "flash" ? flashRow.implicitWidth : topRow.implicitWidth) + 34
    height: mode === "expanded" ? expandedH : mode === "messageOpen" ? pillH + msgBody.implicitHeight + 58 : pillH
    radius: mode === "expanded" || mode === "messageOpen" ? 24 : pillH / 2
    color: Theme.mix(Theme.panel.base, "#000000", Theme.light ? 0.85 : 0.55)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)
    clip: true
    Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
    Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }
    Behavior on radius { NumberAnimation { duration: 300 } }

    // Hover intent: a pointer passing by doesn't open it. Leaving closes it a
    // moment later, unless a screenshot region is being picked (slurp's layer
    // takes the pointer): then it waits for the capture to end.
    HoverHandler {
        id: hover
        onHoveredChanged: {
            BarState.messageHold = hovered && !!root.msg;
            if (hovered) intent.restart(); else { intent.stop(); leave.restart(); }
        }
    }
    Timer { id: intent; interval: 220; onTriggered: if (!PanelState.open) root.expandWanted = true }
    Timer { id: leave; interval: 200; onTriggered: if (!hover.hovered && !PanelState.capturing) root.expandWanted = false }
    Connections {
        target: PanelState
        function onCapturingChanged() { if (!PanelState.capturing && !hover.hovered) root.expandWanted = false; }
        function onOpenChanged() { if (PanelState.open) root.expandWanted = false; }
    }
    onMsgChanged: if (!msg) BarState.messageHold = false

    // MPRIS positions don't update on their own
    Timer {
        interval: 1000
        repeat: true
        running: root.mode === "expanded" && root.playing
        onTriggered: root.player.positionChanged()
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.isMessage ? BarState.openMessage() : Recorder.recording ? Recorder.stop() : (PanelState.open = !PanelState.open)
        onWheel: w => {
            const a = Media.sink?.audio;
            if (!a) return;
            a.volume = Math.max(0, Math.min(1, a.volume + (w.angleDelta.y > 0 ? 0.05 : -0.05)));
            BarState.say(a.volume === 0 ? "" : "", "Volume " + Math.round(a.volume * 100) + "%");
        }
    }

    // ---------------- Top row (the pill) ----------------
    Row {
        id: topRow
        visible: root.mode !== "flash" && !root.isMessage
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        height: root.pillH
        spacing: 12

        // Recording
        Row {
            visible: root.mode === "rec"
            spacing: 7
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: 9; height: 9; radius: 5
                color: "#ff4d4d"
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on opacity {
                    running: root.mode === "rec"
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 600 }
                    NumberAnimation { to: 1; duration: 600 }
                }
            }
            Label { text: "REC " + Recorder.elapsed; color: "#ff8a8a"; font.pixelSize: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
        }
        // Album art (small)
        ClippingRectangle {
            visible: root.mode === "media"
            width: 20; height: 20; radius: 6
            anchors.verticalCenter: parent.verticalCenter
            color: root.accent
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(40, 40)
                asynchronous: true
            }
        }
        Label {
            visible: Settings.v.barDate && root.mode !== "rec"
            text: Qt.formatDate(clock.date, "ddd d MMM")
            color: root.inkDim
            font.pixelSize: 13
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            visible: Settings.v.barDate && root.mode !== "rec"
            width: 3; height: 3; radius: 2
            color: Qt.rgba(1, 1, 1, 0.4)
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            text: Qt.formatTime(clock.date, Settings.v.bar24h ? "HH:mm" : "h:mm AP")
            color: root.ink
            font.family: Theme.clockFont
            font.pixelSize: 15
            font.weight: Font.Bold
            font.features: { "tnum": 1 }
            anchors.verticalCenter: parent.verticalCenter
        }
        // Equalizer (decorative: moves while playing)
        Row {
            visible: root.mode === "media"
            spacing: 2
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: [520, 380, 610, 450]
                delegate: Rectangle {
                    required property int modelData
                    width: 3
                    radius: 2
                    color: root.accent
                    anchors.verticalCenter: parent.verticalCenter
                    height: 4
                    SequentialAnimation on height {
                        running: root.playing && root.mode === "media"
                        loops: Animation.Infinite
                        NumberAnimation { to: 14; duration: modelData; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 4; duration: modelData; easing.type: Easing.InOutSine }
                    }
                }
            }
        }
    }

    // ---------------- Flash message ----------------
    Row {
        id: flashRow
        visible: root.mode === "flash"
        anchors.centerIn: parent
        spacing: 9
        Glyph { text: BarState.flash?.icon ?? ""; color: root.accent; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
        Label { text: BarState.flash?.text ?? ""; color: root.ink; font.pixelSize: 13; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
    }

    // ---------------- Message ----------------
    // Top row: photo (app icon on its corner) · who · the text, one line
    Item {
        visible: root.isMessage
        x: 14
        width: root.width - 28
        height: root.pillH
        Item {
            id: msgPic
            width: 22; height: 22
            anchors.verticalCenter: parent.verticalCenter
            ClippingRectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.1)
                Image {
                    id: msgPhoto
                    // The photo's file may be gone already (Brave deletes it): the app's icon
                    property bool photoFailed: false
                    readonly property bool usingPhoto: !!root.msg?.photo && !photoFailed
                    anchors.fill: parent
                    source: usingPhoto ? root.msg.photo : (root.msg?.icon ?? "")
                    fillMode: usingPhoto ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                    sourceSize: Qt.size(44, 44)
                    asynchronous: true
                    onStatusChanged: if (status === Image.Error && usingPhoto) photoFailed = true
                    Connections { target: root; function onMsgChanged() { msgPhoto.photoFailed = false; } }
                }
            }
            Rectangle {
                visible: msgPhoto.usingPhoto && !!root.msg?.icon
                width: 12; height: 12; radius: 6
                anchors.right: parent.right; anchors.bottom: parent.bottom
                anchors.rightMargin: -3; anchors.bottomMargin: -3
                color: root.color
                Image { anchors.centerIn: parent; width: 10; height: 10; source: root.msg?.icon ?? ""; sourceSize: Qt.size(20, 20) }
            }
        }
        Label {
            id: msgWho
            anchors.left: msgPic.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 160)
            text: root.msg?.who ?? ""
            color: root.ink
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Label {
            anchors.left: msgWho.right
            anchors.leftMargin: 8
            anchors.right: msgCount.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: root.mode === "message"
            text: root.msg?.body ?? ""
            color: root.inkDim
            font.pixelSize: 13
        }
        Rectangle {
            id: msgCount
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: (root.msg?.count ?? 1) > 1
            width: visible ? countText.implicitWidth + 12 : 0
            height: 18
            radius: 9
            color: root.accent
            Label { id: countText; anchors.centerIn: parent; text: root.msg?.count ?? ""; color: Theme.onColor(root.accent); font.pixelSize: 10; font.weight: Font.Bold }
        }
    }
    // Hovered: the whole text, Reply and Open
    ColumnLayout {
        visible: opacity > 0
        opacity: root.mode === "messageOpen" && root.height > root.pillH + 30 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }
        x: 18
        y: root.pillH + 2
        width: root.width - 36
        spacing: 10
        Label {
            id: msgBody
            Layout.fillWidth: true
            text: root.msg?.body ?? ""
            color: root.ink
            font.pixelSize: 13
            wrapMode: Text.Wrap
            maximumLineCount: 4
        }
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Repeater {
                model: [
                    { label: "Reply", icon: "\uf112", ok: !!BarState.messageNotif() && Comms.canReply(BarState.messageNotif()), run: () => BarState.replyMessage() },
                    { label: "Open", icon: "\uf35d", ok: true, run: () => BarState.openMessage() }
                ]
                delegate: Rectangle {
                    required property var modelData
                    visible: modelData.ok
                    width: btnRow.implicitWidth + 22
                    height: 28
                    radius: 14
                    color: btnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.09)
                    Row {
                        id: btnRow
                        anchors.centerIn: parent
                        spacing: 7
                        Glyph { text: modelData.icon; color: root.accent; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: modelData.label; color: root.ink; font.pixelSize: 12; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.modelData.run() }
                }
            }
        }
    }

    // ---------------- Expanded: the player ----------------
    // Art on the left, as tall as the content; on the right the titles, the
    // cava visualizer (doubles as the seekable progress: played bars in the
    // accent) with the times, and shuffle · previous · play · next · loop
    readonly property bool vizOn: mode === "expanded"
    onVizOnChanged: Cava.users += vizOn ? 1 : -1
    Component.onDestruction: if (vizOn) Cava.users -= 1
    readonly property real progress: (player?.length ?? 0) > 0 ? Math.max(0, Math.min(1, player.position / player.length)) : 0

    RowLayout {
        visible: opacity > 0
        opacity: root.mode === "expanded" && root.height > 140 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        x: 14
        y: root.pillH + 4
        width: root.width - 28
        height: root.expandedH - root.pillH - 18
        spacing: 16

        ClippingRectangle {
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            radius: 16
            color: root.accent
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(280, 280)
                asynchronous: true
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { PanelState.open = true; PanelState.goTo("Media", ""); }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Titles
            Label { text: root.player?.trackTitle ?? ""; color: root.ink; font.pixelSize: 15; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Label {
                text: [root.player?.trackArtist ?? "", root.player?.identity ?? ""].filter(s => s).join(" · ")
                color: root.inkDim
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            // Visualizer = progress
            Item {
                id: viz
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 6
                readonly property int count: 44
                readonly property real slot: width / count
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: times.top
                    anchors.bottomMargin: 3
                    height: parent.height - times.height - 3
                    Repeater {
                        model: viz.count
                        delegate: Item {
                            required property int index
                            width: viz.slot
                            height: parent.height
                            readonly property real level: Cava.bars.length ? (Cava.bars[Math.floor(index * Cava.bars.length / viz.count)] ?? 0) : 0
                            readonly property bool played: (index + 0.5) / viz.count <= root.progress
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(2, viz.slot * 0.6)
                                height: Math.max(3, parent.height * parent.level)
                                radius: width / 2
                                color: parent.played ? root.accent : Qt.rgba(1, 1, 1, 0.22)
                                Behavior on height { NumberAnimation { duration: 60 } }
                            }
                        }
                    }
                }
                RowLayout {
                    id: times
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    Label { text: Media.fmt(root.player?.position ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
                    Item { Layout.fillWidth: true }
                    Label { text: Media.fmt(root.player?.length ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: (root.player?.canSeek ?? false) && (root.player?.length ?? 0) > 0
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: m => root.player.position = root.player.length * Math.max(0, Math.min(1, m.x / width))
                }
            }

            // Shuffle · previous · play / pause · next · loop
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                Repeater {
                    model: [
                        { icon: "\uf074", size: 13, ok: root.player?.shuffleSupported ?? false, on: root.player?.shuffle ?? false,
                          run: () => root.player.shuffle = !root.player.shuffle },
                        { icon: "\uf048", size: 15, ok: root.player?.canGoPrevious ?? false, on: false, run: () => root.player?.previous() },
                        { icon: root.playing ? "\uf04c" : "\uf04b", size: 19, ok: root.player?.canTogglePlaying ?? true, on: false, big: true,
                          run: () => root.player?.togglePlaying() },
                        { icon: "\uf051", size: 15, ok: root.player?.canGoNext ?? false, on: false, run: () => root.player?.next() },
                        { icon: (root.player?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\u{f0458}" : "\uf01e", size: 13,
                          ok: root.player?.loopSupported ?? false, on: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None,
                          run: () => Media.cycleLoop() }
                    ]
                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 32
                        Rectangle {
                            anchors.centerIn: parent
                            width: modelData.big ? 36 : 30
                            height: width
                            radius: width / 2
                            color: modelData.big ? root.accent : ctlMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                            Glyph {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.pixelSize: modelData.size
                                color: modelData.big ? Theme.onColor(root.accent) : modelData.on ? root.accent : root.ink
                                opacity: modelData.ok ? 1 : 0.35
                            }
                            MouseArea {
                                id: ctlMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: modelData.ok
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.run()
                            }
                        }
                    }
                }
            }
        }
    }
}
