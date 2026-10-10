import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Hourly forecast (Weather tab), compact — next 24 hours in a sideways
// scrolling strip: hour, icon, temperature, rain chance. Mouse wheel scrolls.
Zone {
    id: root

    Label { visible: Forecast.hourly.length === 0; text: Forecast.error || "Loading forecast…"; dim: true }

    ListView {
        id: list
        visible: Forecast.hourly.length > 0
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        orientation: ListView.Horizontal
        spacing: 6
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: Forecast.hourly

        WheelHandler {
            onWheel: event => list.flick(event.angleDelta.y * 8, 0)
        }

        delegate: Rectangle {
            required property var modelData
            required property int index
            width: 54
            height: list.height
            radius: 10
            color: index === 0 ? Theme.withAlpha(Theme.accent, 0.16) : Theme.withAlpha(Theme.fg, 0.04)

            Column {
                anchors.centerIn: parent
                spacing: 4
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: index === 0 ? "Now" : modelData.time
                        dim: index !== 0; font.pixelSize: 10; font.weight: Font.DemiBold }
                Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: WeatherIcons.icon(modelData.code, modelData.isDay); font.pixelSize: 18 }
                Label { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(modelData.temp) + "°"; font.pixelSize: 14; font.weight: Font.DemiBold }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 2
                    Glyph { text: "\uf043"; font.pixelSize: 8; color: modelData.rain >= 50 ? Theme.rain : Theme.fgDim }
                    Label { text: modelData.rain + "%"; color: modelData.rain >= 50 ? Theme.rain : Theme.fgDim; font.pixelSize: 10 }
                }
            }
        }
    }
}
