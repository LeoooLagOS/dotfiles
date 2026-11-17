import QtQuick
import "../common"
import "../services"

// A level (volume, brightness, progress…; BarState.level) as one row:
// icon · title · bar · percentage, the bar sliding from the last value.
// Shown by the island (bar/Island.qml) and, over a fullscreen window that
// covers the bar, by LevelOsd.qml.
Row {
    id: row

    property var lvl: null
    property color accent: Theme.accent
    property color ink: "#f1f3f5"

    spacing: 10
    readonly property real value: lvl ? Notifs.progressOf(lvl) : 0
    readonly property string glyph: { value; return lvl ? Notifs.levelGlyph(lvl) : ""; }
    // Slides from the last value to the new one (not while dragged)
    property real shown: value
    Behavior on shown { enabled: !barMouse.pressed; NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    // With the pointer on it, it stays (BarState.levelHolds)
    HoverHandler {
        onHoveredChanged: BarState.levelHolds = Math.max(0, BarState.levelHolds + (hovered ? 1 : -1))
    }
    Glyph {
        visible: row.glyph !== ""
        optical: true; text: row.glyph; color: row.accent; font.pixelSize: 14
        anchors.verticalCenter: parent.verticalCenter
    }
    Image {
        visible: row.glyph === ""
        width: 16; height: 16; sourceSize: Qt.size(32, 32)
        source: row.glyph === "" && row.lvl ? Notifs.appIconOf(row.lvl) : ""
        anchors.verticalCenter: parent.verticalCenter
    }
    // The name only when the icon doesn't say it (a download's file, not "Brightness")
    Label {
        visible: row.glyph === ""
        text: row.lvl ? Notifs.titleOf(row.lvl) : ""
        color: row.ink; font.pixelSize: 13; font.weight: Font.DemiBold
        elide: Text.ElideRight; width: Math.min(implicitWidth, 180)
        anchors.verticalCenter: parent.verticalCenter
    }
    Rectangle {
        width: 120; height: 6; radius: 3
        color: Qt.rgba(1, 1, 1, 0.14)
        anchors.verticalCenter: parent.verticalCenter
        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, row.shown / 100))
            height: parent.height; radius: parent.radius
            color: row.value > 100 ? Theme.warn : row.accent
        }
        // Dragged or clicked: that value, for a level that can be set by hand
        MouseArea {
            id: barMouse
            enabled: Notifs.adjustable(row.lvl)
            anchors.fill: parent
            anchors.topMargin: -10
            anchors.bottomMargin: -10
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            preventStealing: true
            function setAt(x) { Notifs.setLevel(row.lvl, x / width * 100); }
            onPressed: m => setAt(m.x)
            onPositionChanged: m => { if (pressed) setAt(m.x); }
        }
    }
    // The widest it gets ("100%", "150%": same width with tabular digits), so
    // it never elides and the pill doesn't jump between 9% and 10%
    TextMetrics { id: widest; font: pct.font; text: "100%" }
    Label {
        id: pct
        text: Math.round(row.value) + "%"
        color: row.value > 100 ? Theme.warn : row.ink
        font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 }
        width: Math.ceil(Math.max(widest.advanceWidth, implicitWidth))
        horizontalAlignment: Text.AlignRight
        anchors.verticalCenter: parent.verticalCenter
    }
}
