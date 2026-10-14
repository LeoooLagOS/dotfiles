import QtQuick
import "../common"

// A line of text in a fixed width: when it doesn't fit it scrolls sideways
// in a loop, pausing at the start of each turn; hovering it holds it still.
// Settings → Bar → Long text (barScroll "hover"): it rests at the start and
// scrolls only while hovered, finishing the turn when left. Every frame of a
// scroll redraws the bar (and Hyprland with it) at the monitor's rate.
//   Marquee { width: 200; text: "…"; dim: true }
Item {
    id: root
    property string text
    property int textFormat: Text.PlainText
    property bool dim: false
    property int pixelSize: 13
    property int weight: Font.Normal
    property int gap: 48
    property real speed: 32                     // px per second
    readonly property bool overflows: first.implicitWidth > width + 1
    readonly property bool always: Settings.v.barScroll !== "hover"
    // Hover only, left mid-turn: that turn finishes, then it rests
    property bool finishing: false

    implicitWidth: first.implicitWidth
    implicitHeight: first.implicitHeight
    clip: true

    HoverHandler { id: hover; onHoveredChanged: if (!root.always && !hovered && scroll.running) root.finishing = true }

    Row {
        id: strip
        spacing: root.gap
        anchors.verticalCenter: parent.verticalCenter
        Label {
            id: first
            text: root.text
            textFormat: root.textFormat
            dim: root.dim
            elide: Text.ElideNone
            font.pixelSize: root.pixelSize
            font.weight: root.weight
        }
        // A second copy follows the first, so the loop has no jump
        Label {
            visible: root.overflows
            text: root.text
            textFormat: root.textFormat
            dim: root.dim
            elide: Text.ElideNone
            font.pixelSize: root.pixelSize
            font.weight: root.weight
        }
    }

    SequentialAnimation {
        id: scroll
        running: root.overflows && root.visible && (root.always || hover.hovered || root.finishing)
        paused: root.always && running && hover.hovered
        loops: Animation.Infinite
        PropertyAction { target: strip; property: "x"; value: 0 }
        PauseAnimation { duration: root.always ? 2000 : 400 }
        NumberAnimation {
            target: strip; property: "x"
            from: 0; to: -(first.implicitWidth + root.gap)
            duration: (first.implicitWidth + root.gap) / root.speed * 1000
        }
        // The copy now sits where the text started: rest there unless hovered
        ScriptAction { script: if (!root.always && !hover.hovered) root.finishing = false }
    }
    onTextChanged: { strip.x = 0; if (scroll.running) scroll.restart(); }
    onAlwaysChanged: { strip.x = 0; finishing = false; }
    onOverflowsChanged: if (!overflows) strip.x = 0
}
