import QtQuick
import QtQuick.Layouts

// Icon + label + value, with a bar underneath (colored by `barColor`). Declared once and updated in
// place, so the bar only animates when `ratio` actually changes.
ColumnLayout {
    property alias icon: glyph.text
    property alias label: name.text
    property alias value: val.text
    property alias ratio: bar.value
    property color barColor: Theme.accent      // semantic level color (Theme.level / lowLevel)
    property color iconColor: Theme.fgDim
    // The value text takes the bar's color only when it signals warn/bad
    readonly property bool alert: Qt.colorEqual(barColor, Theme.warn) || Qt.colorEqual(barColor, Theme.bad)
    spacing: 5

    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        Glyph { id: glyph; font.pixelSize: 13; color: iconColor; Layout.preferredWidth: 16 }
        Label { id: name; dim: true; font.pixelSize: 12 }
        Item { Layout.fillWidth: true }
        Label { id: val; font.pixelSize: 12; font.weight: Font.DemiBold; color: alert ? barColor : Theme.fg }
    }
    Bar { id: bar; Layout.fillWidth: true; fillColor: barColor }
}
