import QtQuick
import QtQuick.Layouts

// Icon + label + value, with a bar underneath (colored by `barColor`). Declared once and updated in
// place, so the bar only animates when `ratio` actually changes.
// A warning (barColor amber / red) can carry a solid mark (Settings → Appearance
// → Warnings, Theme.markOf): "pill" — the icon, label and value on an amber /
// red pill; "icon" — a disc behind the icon, the value in the text color.
ColumnLayout {
    property alias icon: glyph.text
    property alias label: name.text
    property alias value: val.text
    property alias ratio: bar.value
    property color barColor: Theme.accent      // semantic level color (Theme.level / lowLevel)
    property color iconColor: Theme.fgDim
    // The value text takes the bar's color only when it signals warn/bad
    readonly property bool alert: Qt.colorEqual(barColor, Theme.warn) || Qt.colorEqual(barColor, Theme.bad)
    readonly property string mark: alert ? Theme.markOf(barColor) : ""
    readonly property color onBar: Theme.onColor(barColor)
    spacing: 5

    Item {
        Layout.fillWidth: true
        implicitHeight: head.implicitHeight + (mark === "pill" ? 6 : 0)
        Rectangle {
            visible: mark === "pill"
            anchors.fill: parent
            anchors.leftMargin: -6
            anchors.rightMargin: -6
            radius: height / 2
            color: barColor
        }
        RowLayout {
            id: head
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Item {
                Layout.preferredWidth: mark === "icon" ? 20 : 16
                Layout.preferredHeight: mark === "icon" ? 20 : glyph.implicitHeight
                Rectangle { visible: mark === "icon"; anchors.fill: parent; radius: width / 2; color: barColor }
                Glyph {
                    id: glyph
                    anchors.centerIn: parent
                    font.pixelSize: 13
                    color: mark ? onBar : iconColor
                }
            }
            Label { id: name; color: mark === "pill" ? onBar : Theme.fgDim; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Label {
                id: val
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: mark === "pill" ? onBar : alert && !mark ? barColor : Theme.fg
            }
        }
    }
    Bar { id: bar; Layout.fillWidth: true; fillColor: barColor }
}
