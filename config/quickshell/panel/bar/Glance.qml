import QtQuick
import Quickshell.Widgets
import "../common"
import "../services"

// The left twin's other face (TopBar.qml), in the window title's place. A
// video call (services/Call.qml) comes first: the app and the meeting, and
// buttons for the microphone and the camera (red while off). Then the player
// (`music`, TopBar.qml: something plays while the right twin has a reminder):
// the art, then title · artist · album, rolling what doesn't fit (bar/TrackRoll.qml). Else, on an empty workspace, the whole weather:
// icon, temperature, then the sky, high / low, rain and the place, scrolling
// when they don't fit (bar/Marquee.qml). With a window (the call, the player)
// the weather shrinks to the mini pill at the twin's inner edge (bar/MiniWeather.qml); the call or
// the player then takes only its `natural` width when it fits, and the pill the rest. The island grown with the weather is its bigger
// view (both twins hide then).
// Click: the Weather tab (a call: its window; music: the Media tab) · middle click (music): play / pause.
BarPill {
    id: root
    property int fixedWidth: 340
    // The most the twin can give the player (TopBar.qml: the window title's room):
    // the track decides from it what fits side by side, whatever width it takes
    property real room: fixedWidth
    property bool hide: false
    property bool music: false                  // the player, its other twin taken by a reminder
    signal openTab(string name)

    readonly property bool call: Call.active
    readonly property bool track: music && !call
    readonly property var player: Media.player
    readonly property bool shown: !hide && (call || track || Weather.ready)
    readonly property int rain: Math.max(0, ...(Weather.rainNext.length ? Weather.rainNext : [0]))
    function esc(s) { return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }

    // As wide as its content (a call, the player): TopBar.qml gives it just this
    // when it fits, and the mini weather beside it takes the rest
    readonly property real natural: 2 * pad + icon.width + spacing + (track ? trackRoll.implicitWidth : marquee.implicitWidth)
        + (callButtons.visible ? spacing + callButtons.width : 0)
    implicitWidth: fixedWidth
    opacity: shown ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true
    clickable: shown
    onClicked: b => {
        if (call) Call.show();
        else if (track && b === Qt.MiddleButton) player.togglePlaying();
        else root.openTab(track ? "Media" : "Weather");
    }

    Item {
        id: icon
        width: 18
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        ClippingRectangle {
            anchors.fill: parent
            visible: root.track
            radius: 5
            color: BarState.accent
            Image {
                anchors.fill: parent
                source: root.track ? root.player?.trackArtUrl ?? "" : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(36, 36)
                asynchronous: true
            }
        }
        Glyph {
            anchors.centerIn: parent
            optical: true
            visible: !root.track
            text: root.call ? "\u{f0567}" : Weather.icon
            font.pixelSize: 15
            color: BarState.accent
        }
    }
    Label {
        id: lead
        visible: !root.call && !root.track
        text: Math.round(Weather.temp) + "°"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        anchors.verticalCenter: parent.verticalCenter
    }
    // Its text (centered in the pill), up to the rest of the pill
    readonly property real textRoom: Math.max(0, fixedWidth - 2 * pad - icon.width - spacing
                                              - (lead.visible ? lead.width + spacing : 0)
                                              - (callButtons.visible ? callButtons.width + spacing : 0))
    TrackRoll {
        id: trackRoll
        visible: root.track
        title: root.player?.trackTitle ?? ""
        artist: root.player?.trackArtist ?? ""
        album: root.player?.trackAlbum ?? ""
        maxWidth: Math.max(0, root.room - 2 * root.pad - icon.width - root.spacing)
        anchors.verticalCenter: parent.verticalCenter
    }
    Marquee {
        id: marquee
        visible: !root.track
        textFormat: Text.StyledText
        text: root.call ? "<b>" + root.esc(Call.name) + "</b>" + (Call.detail ? "  ·  " + root.esc(Call.detail) : "")
            : "·  " + [root.esc(Weather.description),
                       "↑" + Math.round(Weather.high) + "° ↓" + Math.round(Weather.low) + "°",
                       root.rain > 0 ? Tr.t("rain %1", root.rain + "%") : "",
                       root.esc(Weather.place)].filter(s => s).join("  ·  ")
        dim: !root.call && !root.track
        width: Math.min(implicitWidth, root.textRoom)
        anchors.verticalCenter: parent.verticalCenter
    }
    // The call's microphone and camera
    CallButtons {
        id: callButtons
        visible: root.call
        anchors.verticalCenter: parent.verticalCenter
    }
}
