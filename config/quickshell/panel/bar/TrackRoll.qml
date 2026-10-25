import QtQuick
import "../common"

// The playing track on the bar (bar/Glance.qml, bar/Agenda.qml): title (bold)
// · artist · album, side by side as far as they fit in `maxWidth` (the most
// the twin can give). What doesn't fit rolls, like the island's day and date
// (fade + slide): title 5 s → artist 3 s → album 3 s, or "title · artist"
// 5 s → album 3 s when those two fit. As wide as its widest page, so the card
// doesn't change size on each roll; a page too long scrolls (bar/Marquee.qml)
// and is held until its turn is over. Hovering holds it still; a new track
// starts again on its first page.
//   TrackRoll { title: p.trackTitle; artist: p.trackArtist; album: p.trackAlbum; maxWidth: 300 }
Item {
    id: root
    property string title
    property string artist
    property string album
    property real maxWidth: 300
    property int pixelSize: 13
    property int page: 0
    readonly property string sep: "  ·  "
    function esc(s) { return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }

    // Each part as StyledText, and the lines they make together
    readonly property string tText: "<b>" + esc(title) + "</b>"
    readonly property string taText: tText + (artist ? sep + esc(artist) : "")
    readonly property string allText: taText + (album ? sep + esc(album) : "")
    function fits(w) { return w <= maxWidth + 0.5; }
    readonly property var pages: {
        if (fits(mAll.implicitWidth)) return [{ text: allText, hold: 5000, w: mAll.implicitWidth }];
        if (artist && album && fits(mTa.implicitWidth))
            return [{ text: taText, hold: 5000, w: mTa.implicitWidth },
                    { text: esc(album), hold: 3000, w: mAlbum.implicitWidth }];
        return [{ text: tText, hold: 5000, w: mTitle.implicitWidth },
                artist ? { text: esc(artist), hold: 3000, w: mArtist.implicitWidth } : null,
                album ? { text: esc(album), hold: 3000, w: mAlbum.implicitWidth } : null].filter(p => p);
    }
    readonly property var current: pages[Math.min(page, pages.length - 1)]
    readonly property bool rolls: pages.length > 1 && visible

    implicitWidth: Math.ceil(Math.max(...pages.map(p => p.w)))
    implicitHeight: line.implicitHeight
    width: Math.min(implicitWidth, Math.max(0, maxWidth))
    height: implicitHeight
    clip: true

    // Hidden copies, only to measure
    component Measure: Label { visible: false; textFormat: Text.StyledText; font.pixelSize: root.pixelSize }
    Measure { id: mAll; text: root.allText }
    Measure { id: mTa; text: root.taText }
    Measure { id: mTitle; text: root.tText }
    Measure { id: mArtist; text: root.esc(root.artist) }
    Measure { id: mAlbum; text: root.esc(root.album) }

    Marquee {
        id: line
        textFormat: Text.StyledText
        text: root.current.text
        pixelSize: root.pixelSize
        width: Math.min(implicitWidth, root.width)
        // A shorter page centered in the widest one's width
        x: Math.round((root.width - width) / 2)
        anchors.verticalCenter: parent.verticalCenter
    }

    HoverHandler { id: hover }

    // A page that scrolls stays for its whole turn (Marquee's 2 s pause + the scroll)
    Timer {
        interval: line.overflows ? Math.max(root.current.hold, 2000 + (line.implicitWidth + line.gap) / line.speed * 1000)
                                 : root.current.hold
        repeat: true
        running: root.rolls && !hover.hovered && !roll.running
        onTriggered: roll.restart()
    }
    SequentialAnimation {
        id: roll
        ParallelAnimation {
            NumberAnimation { target: line; property: "opacity"; to: 0; duration: 450; easing.type: Easing.InOutSine }
            NumberAnimation { target: line; property: "anchors.verticalCenterOffset"; to: -6; duration: 450; easing.type: Easing.InOutSine }
        }
        ScriptAction { script: root.page = (Math.min(root.page, root.pages.length - 1) + 1) % root.pages.length }
        PropertyAction { target: line; property: "anchors.verticalCenterOffset"; value: 6 }
        ParallelAnimation {
            NumberAnimation { target: line; property: "opacity"; to: 1; duration: 600; easing.type: Easing.OutSine }
            NumberAnimation { target: line; property: "anchors.verticalCenterOffset"; to: 0; duration: 600; easing.type: Easing.OutSine }
        }
    }
    function reset() {
        roll.stop();
        page = 0;
        line.opacity = 1;
        line.anchors.verticalCenterOffset = 0;
    }
    onTitleChanged: reset()
    onRollsChanged: if (!rolls) reset()
}
