import QtQuick
import Quickshell.Widgets
import "../common"
import "../services"

// The right side's twin of the window title (from the readings to the same
// gap before the center as the title's, TopBar.qml). The island grown is its
// bigger view, by the same rule: while something plays (Media.active), the
// art, title and artist; otherwise the weather: icon, temperature, then the
// sky, high / low, rain and the place, scrolling when they don't fit (bar/Marquee.qml).
// `weatherOnly`: the weather even while music plays (the island grown shows the player).
// Click: the Media or Weather tab · middle click (music): play / pause.
BarPill {
    id: root
    property int fixedWidth: 340
    property bool hide: false
    property bool weatherOnly: false            // the weather even while music plays (the island shows the player)
    signal openTab(string name)

    readonly property var player: Media.player
    readonly property bool music: Media.active && !weatherOnly
    readonly property bool shown: !hide && (music || Weather.ready)
    readonly property int rain: Math.max(0, ...(Weather.rainNext.length ? Weather.rainNext : [0]))
    function esc(s) { return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }

    implicitWidth: fixedWidth
    opacity: shown ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true
    clickable: shown
    onClicked: b => {
        if (b === Qt.MiddleButton && music) player.togglePlaying();
        else root.openTab(music ? "Media" : "Weather");
    }

    Item {
        width: 18
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        ClippingRectangle {
            anchors.fill: parent
            visible: root.music
            radius: 5
            color: BarState.accent
            Image {
                anchors.fill: parent
                source: root.music ? root.player?.trackArtUrl ?? "" : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(36, 36)
                asynchronous: true
            }
        }
        Glyph {
            anchors.centerIn: parent
            optical: true
            visible: !root.music
            text: Weather.icon
            font.pixelSize: 15
            color: BarState.accent
        }
    }
    Label {
        id: lead
        visible: !root.music
        text: Math.round(Weather.temp) + "°"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        anchors.verticalCenter: parent.verticalCenter
    }
    Marquee {
        textFormat: Text.StyledText
        text: root.music
            ? "<b>" + root.esc(root.player?.trackTitle) + "</b>"
              + (root.player?.trackArtist ? "  ·  " + root.esc(root.player.trackArtist) : "")
            : "·  " + [root.esc(Weather.description),
                       "↑" + Math.round(Weather.high) + "° ↓" + Math.round(Weather.low) + "°",
                       root.rain > 0 ? "rain " + root.rain + "%" : "",
                       root.esc(Weather.place)].filter(s => s).join("  ·  ")
        dim: !root.music
        // Its text (centered in the pill), up to the rest of the pill
        width: Math.min(implicitWidth, Math.max(0, root.fixedWidth - 2 * root.pad - 18 - root.spacing
                           - (lead.visible ? lead.width + root.spacing : 0)))
        anchors.verticalCenter: parent.verticalCenter
    }
}
