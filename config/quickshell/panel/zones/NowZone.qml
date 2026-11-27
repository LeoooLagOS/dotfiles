import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"
import "../bar"

// ZONE: Now — weather on the left, clock on the right.
//   Left, top:    icon · temperature · conditions with today's low/high below
//   Left, bottom: wind (speed + direction) · air quality · visibility · pressure
//   Right:        rotating fact (every 8 s) above the clock: rain alert (if rain
//                 is ≥ 50% within 6 h, repeated between the others), feels like,
//                 humidity, sunrise/sunset countdown, one at a time. It rolls like
//                 the bar island's date: out upward, the next in from below.
//                 Hover pauses it.
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

        if (Weather.ready) {
            out.push({ icon: "\uf2c9", text: Tr.t("Feels like %1°", Math.round(Weather.feelsLike)) });
            out.push({ icon: "\uf043", text: Tr.t("%1% humidity", Weather.humidity) });
        }
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
        // 8 s, or longer while a fact too long for the clock's width scrolls (a whole turn and a bit)
        interval: Math.max(8000, factText.turnMs + 1500)
        repeat: true
        running: root.facts.length > 1 && PanelState.open && !hoverWatch.containsMouse
        onTriggered: fade.restart()
    }
    // The bar island's roll (bar/Island.qml): fade and slide up 6 px, then the
    // next one from 6 px below
    SequentialAnimation {
        id: fade
        ParallelAnimation {
            NumberAnimation { target: factRow; property: "opacity"; to: 0; duration: 450; easing.type: Easing.InOutSine }
            NumberAnimation { target: factShift; property: "y"; to: -6; duration: 450; easing.type: Easing.InOutSine }
        }
        ScriptAction { script: root.factIndex = (root.factIndex + 1) % Math.max(1, root.facts.length) }
        PropertyAction { target: factShift; property: "y"; value: 6 }
        ParallelAnimation {
            NumberAnimation { target: factRow; property: "opacity"; to: 1; duration: 600; easing.type: Easing.OutSine }
            NumberAnimation { target: factShift; property: "y"; to: 0; duration: 600; easing.type: Easing.OutSine }
        }
    }
    MouseArea { id: hoverWatch; parent: root; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) root.factIndex = 0; } }

    // The content spans what the profile's does beside it (ProfileZone.qml):
    // from the other cards' titles (NOTIFICATIONS) down to the photo's bottom
    // edge, 6 px past the usual padding at each end. Weather and fact on top,
    // details and clock at the bottom
    Item {
        width: parent.width
        implicitHeight: root.inner

        RowLayout {
            // Compact (Config.qml): in the card's middle 80 % (Zone's band);
            // else 6 px past the padding, like the profile's photo
            y: root.compact ? root.bandTop - Theme.zonePadding : -6
            width: parent.width
            height: root.compact ? root.bandHeight : root.inner + 12
            spacing: 7

            // ---------------- Weather ----------------
            // Takes whatever width the clock leaves (its own content never pushes the clock)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 0
                Layout.minimumWidth: 0
                spacing: 0

                Label { visible: !Weather.ready; text: Tr.t("Loading weather…"); dim: true }

                // Icon · temperature · conditions (low / high: above the clock)
                RowLayout {
                    visible: Weather.ready
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    spacing: 8

                    // Icon · temperature: the details' first column below is as wide.
                    // Measured (TextMetrics): with the clock at 52 px the weather has
                    // ~164 px; icon 36 + 4 + "13°" 48 + 8 + "Overcast" (14 px) 62 = 158
                    Row {
                        id: tempBlock
                        spacing: 4
                        // A Nerd Font weather glyph draws wider than it says (28 px: says
                        // 17, draws 26): its whole width reserved, flush with the card's left
                        Glyph { text: Weather.icon; font.pixelSize: 36; width: 36; horizontalAlignment: Text.AlignLeft; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: Math.round(Weather.temp) + "°"; font.pixelSize: 32; font.weight: Font.DemiBold; color: Theme.accent; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Label {
                        text: Weather.description
                        font.pixelSize: 14; font.weight: Font.DemiBold
                        color: Theme.accentSoft
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap        // two lines rather than "Light d…"
                        maximumLineCount: 2
                        lineHeight: 0.9
                    }
                }

                Item { Layout.fillHeight: true }

                // Wind · air quality · visibility · pressure (2 × 2), at the bottom
                GridLayout {
                    visible: Weather.ready
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 8                   // = the top row's: AQI · pressure under the conditions
                    rowSpacing: root.compact ? 1 : 4

                    Repeater {
                        model: [
                            { icon: "\u{f059d}", text: Math.round(Weather.wind) + " km/h " + Weather.windCompass },
                            { icon: "\uf06c", text: Weather.aqi >= 0 ? "AQI " + Weather.aqi : "AQI –", color: Theme.aqiColor(Weather.aqi) },
                            { icon: "\uf06e", text: Weather.visibility.toFixed(1) + " km" },
                            { icon: "\uf0c3", text: Math.round(Weather.pressure) + " hPa" }
                        ]
                        delegate: Row {
                            required property var modelData
                            required property int index
                            // Wind · visibility under icon · temperature, as wide
                            Layout.preferredWidth: index % 2 === 0 ? Math.max(implicitWidth, tempBlock.implicitWidth) : implicitWidth
                            spacing: 4
                            Glyph { text: modelData.icon; font.pixelSize: 11; color: modelData.color ?? Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                            Label { text: modelData.text; color: modelData.color ?? Theme.fgDim; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; Layout.preferredWidth: 1; color: Theme.border }

            // ---------------- Rotating fact + clock ----------------
            // As wide as the clock: a longer fact is cut short instead of taking
            // room from the weather. The fact on top; at the bottom today's
            // low / high right above the clock
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: clockLabel.implicitWidth
                Layout.maximumWidth: clockLabel.implicitWidth
                spacing: 0

                Row {
                    id: factRow
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    Layout.maximumWidth: clockLabel.implicitWidth
                    visible: root.fact !== null
                    spacing: 5
                    transform: Translate { id: factShift }
                    Glyph { id: factIcon; text: root.fact?.icon ?? ""; font.pixelSize: 13; color: root.fact?.color ?? Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    // Too long for the clock's width ("Rain around 14:00 · 27%"): it scrolls
                    Marquee {
                        id: factText
                        text: root.fact?.text ?? ""; dim: true; pixelSize: 13; always: true
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, clockLabel.implicitWidth - factIcon.implicitWidth - factRow.spacing)
                    }
                }

                Item { Layout.fillHeight: true }

                Label {
                    Layout.alignment: Qt.AlignRight
                    visible: Weather.ready
                    text: Math.round(Weather.low) + "° / " + Math.round(Weather.high) + "°C"
                    dim: true; font.pixelSize: 13
                }

                Label {
                    id: clockLabel
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom
                    // Right under the fact: the font's room above the digits taken back
                    Layout.topMargin: -Math.round(font.pixelSize * 0.2)
                    text: Qt.formatTime(clock.date, "HH:mm")
                    font.family: Theme.clockFont
                    color: Theme.accentSoft
                    font.pixelSize: Math.round(Math.min(52, (root.compact ? root.bandHeight : root.inner + 12) * 0.67))
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    // The font's line box has room below the digits: pull them
                    // down to the photo's bottom edge
                    Layout.bottomMargin: -Math.round(font.pixelSize * 0.16)
                }
            }
        }
    }
}
