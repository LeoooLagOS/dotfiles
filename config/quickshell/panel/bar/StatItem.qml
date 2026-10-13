import QtQuick
import "../common"
import "../services"

// One reading in the bar: icon + value. Neutral while normal; amber / red past
// its thresholds (level). A solid mark can make the warning stand out (Settings
// → Appearance → Warnings, Theme.markOf): "pill" — an amber / red pill around
// icon and number, both in the color that reads on it; "icon" — a disc behind
// the icon, the number in the text color. By default only when the wallpaper's
// palette has that hue too (Theme.warnClash / badClash).
// Hovering shows its details (BarTip) after a moment.
//   StatItem { icon: ""; text: "12%"; level: ""; tip: ({ title, rows: [[k, v]], hist }) ; tipHost: tip }
Item {
    id: root
    property string icon: ""
    property string text: ""
    property string level: ""              // "" | "warn" | "bad"
    property int iconSize: 13
    property var tip: null                 // { title, rows, hist }
    property var tipHost: null             // the bar's BarTip
    property bool compact: false           // the icon alone (the bar while the panel is open)
    readonly property color tint: level === "bad" ? Theme.bad : level === "warn" ? Theme.warn : Theme.fg
    readonly property string mark: level ? Theme.markOf(tint) : ""
    readonly property bool pill: mark === "pill"
    readonly property bool disc: mark === "icon"
    readonly property color onTint: Theme.onColor(tint)
    implicitWidth: row.implicitWidth + (pill ? 14 : 0)
    implicitHeight: Math.max(row.implicitHeight, pill ? iconSize + 9 : 0)
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    HoverHandler {
        onHoveredChanged: if (root.tipHost) hovered ? root.tipHost.show(root) : root.tipHost.hide(root)
    }

    Rectangle {
        visible: root.pill
        anchors.fill: parent
        radius: height / 2
        color: root.tint
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Item {
            implicitWidth: root.disc ? root.iconSize + 9 : icon.implicitWidth
            implicitHeight: root.disc ? root.iconSize + 9 : icon.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                visible: root.disc
                anchors.fill: parent
                radius: width / 2
                color: root.tint
            }
            Glyph {
                id: icon
                optical: true
                anchors.centerIn: parent
                text: root.icon
                font.pixelSize: root.iconSize
                color: root.pill || root.disc ? root.onTint : root.level ? root.tint : Theme.fgDim
            }
        }
        Label {
            visible: root.text !== "" && !root.compact
            text: root.text
            color: root.pill ? root.onTint : root.disc ? Theme.fg : root.tint
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.features: { "tnum": 1 }
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
