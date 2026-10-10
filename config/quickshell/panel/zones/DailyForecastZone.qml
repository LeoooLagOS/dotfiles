import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: 7-day forecast (Weather tab) — day, icon, rain chance and a bar showing
// the day's low–high range against the whole week's range.
Zone {
    id: root
    title: "7-day forecast"
    icon: "\uf073"

    readonly property real weekMin: Math.min(...Forecast.daily.map(d => d.min))
    readonly property real weekMax: Math.max(...Forecast.daily.map(d => d.max))

    Label { visible: Forecast.daily.length === 0; text: Forecast.error || "Loading forecast…"; dim: true }

    ColumnLayout {
        visible: Forecast.daily.length > 0
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 0

        Repeater {
            model: Forecast.daily

            delegate: RowLayout {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Label {
                    Layout.preferredWidth: 56
                    text: index === 0 ? "Today" : Qt.formatDate(new Date(modelData.date + "T12:00"), "ddd")
                    color: index === 0 ? Theme.accent : Theme.fg
                    font.weight: index === 0 ? Font.DemiBold : Font.Normal
                    font.pixelSize: 13
                }
                Glyph { Layout.preferredWidth: 26; text: WeatherIcons.icon(modelData.code, true); font.pixelSize: 18 }
                Label {
                    Layout.preferredWidth: 38
                    text: modelData.rain > 0 ? modelData.rain + "%" : ""
                    color: modelData.rain >= 50 ? Theme.rain : Theme.fgDim
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    Layout.preferredWidth: 30
                    text: Math.round(modelData.min) + "°"
                    dim: true
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignRight
                }

                // Range bar: where this day's low–high sits within the week
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    Rectangle { anchors.fill: parent; radius: 3; color: Theme.track }
                    Rectangle {
                        readonly property real span: Math.max(1, root.weekMax - root.weekMin)
                        x: parent.width * (modelData.min - root.weekMin) / span
                        width: Math.max(6, parent.width * (modelData.max - modelData.min) / span)
                        height: parent.height
                        radius: 3
                        // Low → high in the temperature scale
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.tempColor(modelData.min) }
                            GradientStop { position: 1; color: Theme.tempColor(modelData.max) }
                        }
                    }
                }

                Label {
                    Layout.preferredWidth: 30
                    text: Math.round(modelData.max) + "°"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }
            }
        }
    }
}
