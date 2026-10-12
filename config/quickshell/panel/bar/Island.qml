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
// Click: the panel (open / close) · wheel: volume of the output.
Rectangle {
    id: root

    readonly property var player: Media.player
    readonly property bool hasTrack: !!player && !!player.trackTitle
    readonly property bool playing: hasTrack && player.isPlaying
    property bool expandWanted: false
    readonly property string mode: BarState.flash ? "flash"
        : Recorder.recording ? "rec"
        : expandWanted && hasTrack ? "expanded"
        : playing ? "media" : "rest"
    readonly property int pillH: Settings.v.barHeight - 6
    readonly property color ink: "#f1f3f5"
    readonly property color inkDim: Qt.rgba(241 / 255, 243 / 255, 245 / 255, 0.6)
    readonly property color accent: Theme.ensure(BarState.accent, color, 3)

    width: mode === "expanded" ? 440 : (mode === "flash" ? flashRow.implicitWidth : topRow.implicitWidth) + 34
    height: mode === "expanded" ? 178 : pillH
    radius: mode === "expanded" ? 26 : pillH / 2
    color: Theme.mix(Theme.panel.base, "#000000", Theme.light ? 0.85 : 0.55)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)
    clip: true
    Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
    Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }
    Behavior on radius { NumberAnimation { duration: 300 } }

    // Hover intent: a pointer passing by doesn't open it
    HoverHandler { id: hover; onHoveredChanged: hovered ? intent.restart() : (intent.stop(), root.expandWanted = false) }
    Timer { id: intent; interval: 220; onTriggered: root.expandWanted = true }

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
        onClicked: Recorder.recording ? Recorder.stop() : (PanelState.open = !PanelState.open)
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
        visible: root.mode !== "flash"
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
            visible: root.mode === "media" || root.mode === "expanded"
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
            visible: root.mode === "media" || root.mode === "expanded"
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
                        running: root.playing && (root.mode === "media" || root.mode === "expanded")
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

    // ---------------- Expanded: the player ----------------
    RowLayout {
        visible: opacity > 0
        opacity: root.mode === "expanded" && root.height > 120 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        x: 16
        y: root.pillH + 6
        width: root.width - 32
        spacing: 14

        ClippingRectangle {
            Layout.preferredWidth: 76
            Layout.preferredHeight: 76
            radius: 14
            color: root.accent
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(152, 152)
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
            spacing: 2
            Label { text: root.player?.trackTitle ?? ""; color: root.ink; font.pixelSize: 15; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Label {
                text: [root.player?.trackArtist ?? "", root.player?.identity ?? ""].filter(s => s).join(" · ")
                color: root.inkDim
                font.pixelSize: 12
                Layout.fillWidth: true
            }
            // Progress
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 8
                visible: (root.player?.length ?? 0) > 0
                Label { text: Media.fmt(root.player?.position ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
                Rectangle {
                    Layout.fillWidth: true
                    height: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.14)
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1)))
                        height: parent.height
                        radius: 2
                        color: root.accent
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.player?.canSeek ?? false
                        onClicked: m => root.player.position = root.player.length * Math.max(0, Math.min(1, (m.x - 6) / (width - 12)))
                    }
                }
                Label { text: Media.fmt(root.player?.length ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
            }
            // Controls
            Row {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                spacing: 26
                Repeater {
                    model: [
                        { icon: "", size: 15, run: () => root.player?.previous(), ok: root.player?.canGoPrevious ?? false },
                        { icon: root.playing ? "" : "", size: 19, run: () => root.player?.togglePlaying(), ok: root.player?.canTogglePlaying ?? true },
                        { icon: "", size: 15, run: () => root.player?.next(), ok: root.player?.canGoNext ?? false }
                    ]
                    delegate: Glyph {
                        required property var modelData
                        text: modelData.icon
                        font.pixelSize: modelData.size
                        color: ctlMouse.containsMouse ? root.accent : root.ink
                        opacity: modelData.ok ? 1 : 0.35
                        width: 26
                        height: 26
                        MouseArea {
                            id: ctlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData.run()
                        }
                    }
                }
            }
        }
    }
}
