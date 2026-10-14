import QtQuick
import "../common"
import "../services"

// The weather beside the left twin (TopBar.qml), at its inner edge: the sky's
// icon and the temperature. Given a `fixedWidth` (the window title left room:
// a git repository's details are short), it fills it with what fits whole,
// in order: high / low, rain, the sky, the place (one that doesn't fit is
// skipped, a later shorter one may still). Nothing scrolls.
// Click: the Weather tab.
BarPill {
    id: root
    property int fixedWidth: 0                  // 0: just the icon and the temperature
    signal openTab(string name)
    // The narrowest it gets: icon + temperature
    readonly property real minWidth: 2 * pad + icon.width + spacing + temp.width
    readonly property int rain: Math.max(0, ...(Weather.rainNext.length ? Weather.rainNext : [0]))
    // What fits after the temperature, each part whole
    readonly property string extra: {
        if (fixedWidth <= 0) return "";
        const room = fixedWidth - minWidth - spacing;
        const parts = [Math.round(Weather.high) + "°/" + Math.round(Weather.low) + "°",
                       rain > 0 ? "\u2614 " + rain + "%" : "",
                       Weather.description,
                       Weather.place].filter(s => s);
        let out = "";
        for (const p of parts) {
            const t = out ? out + "  ·  " + p : p;
            if (metrics.advanceWidth(t) <= room) out = t;
        }
        return out;
    }

    implicitWidth: fixedWidth > 0 ? fixedWidth : minWidth
    clip: true
    clickable: true
    spacing: 5
    onClicked: root.openTab("Weather")

    FontMetrics { id: metrics; font.family: Theme.font; font.pixelSize: 12 }
    Glyph { id: icon; optical: true; text: Weather.icon; font.pixelSize: 14; color: BarState.accent; anchors.verticalCenter: parent.verticalCenter }
    Label { id: temp; text: Math.round(Weather.temp) + "°"; font.pixelSize: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 }; anchors.verticalCenter: parent.verticalCenter }
    Label { visible: root.extra !== ""; text: root.extra; dim: true; elide: Text.ElideNone; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
}
