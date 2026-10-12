import QtQuick
import "../common"
import "../services"

// One reading in the bar: icon + value. Neutral while normal; amber / red past
// its thresholds (level). Hovering shows its details (BarTip) after a moment.
//   StatItem { icon: ""; text: "12%"; level: ""; tip: ({ title, rows: [[k, v]], hist }) ; tipHost: tip }
Row {
    id: root
    property string icon: ""
    property string text: ""
    property string level: ""              // "" | "warn" | "bad"
    property int iconSize: 13
    property var tip: null                 // { title, rows, hist }
    property var tipHost: null             // the bar's BarTip
    readonly property color tint: level === "bad" ? Theme.bad : level === "warn" ? Theme.warn : Theme.fg
    spacing: 5
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    HoverHandler {
        onHoveredChanged: if (root.tipHost) hovered ? root.tipHost.show(root) : root.tipHost.hide(root)
    }

    Glyph {
        text: root.icon
        font.pixelSize: root.iconSize
        color: root.level ? root.tint : Theme.fgDim
        anchors.verticalCenter: parent.verticalCenter
    }
    Label {
        visible: root.text !== ""
        text: root.text
        color: root.tint
        font.pixelSize: 12
        font.weight: Font.DemiBold
        font.features: { "tnum": 1 }
        anchors.verticalCenter: parent.verticalCenter
    }
}
