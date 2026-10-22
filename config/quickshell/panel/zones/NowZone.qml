import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"

// ZONE: Now — weather on the left, clock on the right.
//   Left, top:    icon · temperature · conditions with today's low/high below
//   Left, bottom: wind (speed + direction) · air quality · visibility · pressure
//   Right:        rotating fact (every 8 s) above the clock: rain alert (if rain
//                 is ≥ 50% within 6 h, repeated between the others), feels like
//                 + humidity, sunrise/sunset countdown. Hover pauses it.
// Click anywhere to open the Weather tab.
Zone {
    id: root
    centered: true
    clickable: true
    onClicked: {
        const i = Config.tabs.findIndex(t => t.name === "Weather");
        if (i >= 0) PanelState.tab = i;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property real inner: root.height - 2 * Theme.zonePadding   // usable height

    // "2h 05m" / "35m"
    function span(mins) {
        const h = Math.floor(mins / 60), m = mins % 60;
        return h > 0 ? h + "h " + String(m).padStart(2, "0") + "m" : m + "m";
    }
    function minutesUntil(hhmm) {
        const [h, m] = hhmm.split(":").map(Number);
        const t = new Date(clock.date);
        t.setHours(h, m, 0, 0);
        return Math.round((t - clock.date) / 60000);
    }

    // Facts above the clock: [{ icon, text }]
    readonly property var facts: {
        clock.date;                              // re-evaluate every minute
        const hours = Forecast.hourly, days = Forecast.daily, out = [];

        const wet = hours.slice(0, 6).find(h => h.rain >= 50);
        const rain = wet ? { icon: "\uf0e9", color: Theme.rain, text: (wet === hours[0] ? Tr.t("Rain now") : Tr.t("Rain around %1", wet.time)) + " · " + wet.rain + "%" } : null;

        if (Weather.ready)
            out.push({ icon: "\uf2c9", text: Tr.t("Feels %1° · %2% humidity", Math.round(Weather.feelsLike), Weather.humidity) });
        if (days.length > 0) {
            const toRise = minutesUntil(days[0].sunrise), toSet = minutesUntil(days[0].sunset);
            if (toRise > 0) out.push({ icon: "\u{f059c}", text: Tr.t("Sunrise in %1", span(toRise)) });
            else if (toSet > 0) out.push({ icon: "\u{f059b}", text: Tr.t("Sunset in %1", span(toSet)) });
            else if (days.length > 1) out.push({ icon: "\u{f059c}", text: Tr.t("Sunrise in %1", span(toRise + 1440)) });
        }
        if (!rain) return out;
        // rain, a, rain, b, …
        return out.length ? out.reduce((acc, f) => acc.concat([rain, f]), []) : [rain];
    }

    property int factIndex: 0
    readonly property var fact: facts.length ? facts[factIndex % facts.length] : null

    Timer {
        interval: 8000
        repeat: true
        running: root.facts.length > 1 && PanelState.open && !hoverWatch.containsMouse
        onTriggered: fade.restart()
    }
    SequentialAnimation {
        id: fade
        NumberAnimation { target: factRow; property: "opacity"; to: 0; duration: 180 }
        ScriptAction { script: root.factIndex = (root.factIndex + 1) % Math.max(1, root.facts.length) }
        NumberAnimation { target: factRow; property: "opacity"; to: 1; duration: 220 }
    }
    MouseArea { id: hoverWatch; parent: root; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) root.factIndex = 0; } }

    RowLayout {
        width: parent.width
        height: root.inner
        spacing: 14

        // ---------------- Weather ----------------
        // Takes whatever width the clock leaves (its own content never pushes the clock)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 0
            Layout.minimumWidth: 0
            spacing: 6

            Label { visible: !Weather.ready; text: Tr.t("Loading weather…"); dim: true }

            // Icon · temperature · conditions + low/high
            RowLayout {
                visible: Weather.ready
                Layout.fillWidth: true
                spacing: 8

                Glyph { text: Weather.icon; font.pixelSize: 28; Layout.preferredWidth: 30; color: Theme.accent }
                Label { text: Math.round(Weather.temp) + "°"; font.pixelSize: 26; font.weight: Font.DemiBold; color: Theme.accent }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Label {
                        text: Weather.description
                        font.pixelSize: 12; font.weight: Font.DemiBold
                        color: Theme.accentSoft
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap        // two lines rather than "Light d…"
                        maximumLineCount: 2
                        lineHeight: 0.9
                    }
                    Label {
                        text: Math.round(Weather.low) + "° / " + Math.round(Weather.high) + "°C"
                        dim: true; font.pixelSize: 10
                        Layout.fillWidth: true
                    }
                }
            }

            // Wind · air quality · visibility · pressure (2 × 2)
            GridLayout {
                visible: Weather.ready
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 2

                Repeater {
                    model: [
                        { icon: "\u{f059d}", text: Math.round(Weather.wind) + " km/h " + Weather.windCompass },
                        { icon: "\uf06c", text: Weather.aqi >= 0 ? "AQI " + Weather.aqi : "AQI –", color: Theme.aqiColor(Weather.aqi) },
                        { icon: "\uf06e", text: Weather.visibility.toFixed(1) + " km" },
                        { icon: "\uf0c3", text: Math.round(Weather.pressure) + " hPa" }
                    ]
                    delegate: Row {
                        required property var modelData
                        spacing: 3
                        Glyph { text: modelData.icon; font.pixelSize: 10; color: modelData.color ?? Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: modelData.text; color: modelData.color ?? Theme.fgDim; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }

        Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: Theme.border }

        // ---------------- Rotating fact + clock ----------------
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: 4
            spacing: 0

            Row {
                id: factRow
                Layout.alignment: Qt.AlignRight
                visible: root.fact !== null
                spacing: 5
                Glyph { text: root.fact?.icon ?? ""; font.pixelSize: 11; color: root.fact?.color ?? Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                Label { text: root.fact?.text ?? ""; dim: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            }
            Label {
                Layout.alignment: Qt.AlignRight
                text: Qt.formatTime(clock.date, "HH:mm")
                font.family: Theme.clockFont
                color: Theme.accentSoft
                font.pixelSize: Math.min(50, root.inner * 0.64)
                font.weight: Font.DemiBold
                font.features: { "tnum": 1 }
            }
        }
    }
}
