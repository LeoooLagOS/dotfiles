import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Current weather (Weather tab) — icon, temperature, conditions and
// feels-like, sunrise/sunset beside them, and six detail tiles:
// High/Low, Humidity, Wind, Pressure, Rain chance, Visibility.
Zone {
    title: Weather.place || "Weather"
    icon: "\uf041"

    Label { visible: !Weather.ready; text: "Loading weather…"; dim: true }

    ColumnLayout {
        visible: Weather.ready
        width: parent.width
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Glyph { text: Weather.icon; font.pixelSize: 44; Layout.preferredWidth: 50; color: Theme.accent }
            Label { text: Math.round(Weather.temp) + "°"; font.pixelSize: 40; font.weight: Font.DemiBold; color: Theme.accent }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Label { text: Weather.description; font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true }
                Label { text: "Feels like " + Math.round(Weather.feelsLike) + "°C"; dim: true; font.pixelSize: 12; Layout.fillWidth: true }
            }
            // Sunrise / sunset
            GridLayout {
                columns: 2
                columnSpacing: 6
                rowSpacing: 4
                Glyph { text: "\u{f059c}"; font.pixelSize: 13; color: Theme.fgDim }
                Label { text: Forecast.daily[0]?.sunrise ?? "–"; font.pixelSize: 12 }
                Glyph { text: "\u{f059b}"; font.pixelSize: 13; color: Theme.fgDim }
                Label { text: Forecast.daily[0]?.sunset ?? "–"; font.pixelSize: 12 }
            }
        }

        // Detail tiles (3 × 2)
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: [
                    { icon: "\uf2c9", label: "High / Low", value: Math.round(Weather.high) + "° / " + Math.round(Weather.low) + "°" },
                    { icon: "\uf043", label: "Humidity", value: Weather.humidity + "%" },
                    { icon: "\u{f059d}", label: "Wind", value: Math.round(Weather.wind) + " km/h " + Weather.windCompass },
                    { icon: "\uf0c3", label: "Pressure", value: Math.round(Weather.pressure) + " hPa" },
                    { icon: "\uf0e9", label: "Rain chance", value: (Forecast.daily[0]?.rain ?? 0) + "%", color: Theme.rain },
                    { icon: "\uf06e", label: "Visibility", value: Weather.visibility.toFixed(1) + " km" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 46
                    radius: 10
                    color: Theme.withAlpha(Theme.fg, 0.05)

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            Glyph { text: modelData.icon; font.pixelSize: 10; color: modelData.color ?? Theme.fgDim }
                            Label { text: modelData.label; dim: true; font.pixelSize: 10 }
                        }
                        Label { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.value; font.pixelSize: 13; font.weight: Font.DemiBold }
                    }
                }
            }
        }
    }
}
