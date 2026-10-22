import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Temperature chart (Weather tab) — next 24 hours as a smooth curve
// in the saturated accent (Theme.vivid) with a fading fill, condition
// icons and temperatures every few hours, sunrise /
// sunset markers, and rain chance + hour labels along the bottom.
Zone {
    id: root
    title: Tr.t("Next 24 hours")
    icon: "\uf201"

    readonly property var hours: Forecast.hourly
    readonly property int n: hours.length
    readonly property real tMin: n ? Math.min(...hours.map(h => h.temp)) : 0
    readonly property real tMax: n ? Math.max(...hours.map(h => h.temp)) : 1
    readonly property int labelEvery: 3        // temperature/icon labels every 3 hours

    // Sunrise/sunset markers that fall inside the chart, from real dates (so
    // today's sunset that already passed isn't drawn as tomorrow's)
    readonly property var sunEvents: {
        if (!n) return [];
        const start = new Date();
        start.setMinutes(0, 0, 0);                         // the chart starts at the current hour
        const spanMin = (n - 1) * 60, out = [];
        for (const day of Forecast.daily.slice(0, 2)) {
            for (const [kind, t] of [["rise", day.sunrise], ["set", day.sunset]]) {
                const when = new Date(day.date + "T" + t + ":00");
                const off = (when - start) / 60000;
                if (off >= 0 && off <= spanMin) out.push({ kind: kind, time: t, offset: off });
            }
        }
        return out;
    }

    Label { visible: root.n === 0; text: Forecast.error || Tr.t("Loading forecast…"); dim: true }

    Item {
        id: chartArea
        visible: root.n > 0
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding

        // Layout of the drawing area
        readonly property real topPad: 44        // room for icons + temperature labels
        readonly property real bottomPad: 40     // rain row + hour labels
        readonly property real plotH: height - topPad - bottomPad
        readonly property real padX: 18          // keeps edge labels inside the card
        readonly property real stepX: root.n > 1 ? (width - 2 * padX) / (root.n - 1) : width

        function xAt(i) { return padX + i * stepX; }
        function yAt(t) {
            const span = Math.max(1, root.tMax - root.tMin);
            // keep the curve in the middle 70% of the plot height
            return topPad + plotH * (0.15 + 0.7 * (1 - (t - root.tMin) / span));
        }

        // --- Curve + gradient fill ---
        Canvas {
            id: canvas
            anchors.fill: parent
            renderStrategy: Canvas.Cooperative

            readonly property color bgc: Theme.bgAlt
            onBgcChanged: requestPaint()
            readonly property color curve: Theme.vivid
            onCurveChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections { target: Forecast; function onHourlyChanged() { canvas.requestPaint(); } }

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const hs = root.hours;
                if (hs.length < 2) return;
                const pts = hs.map((h, i) => ({ x: chartArea.xAt(i), y: chartArea.yAt(h.temp) }));

                // Smooth path (midpoint quadratic curves)
                function trace() {
                    ctx.moveTo(pts[0].x, pts[0].y);
                    for (let i = 1; i < pts.length - 1; i++) {
                        const mx = (pts[i].x + pts[i + 1].x) / 2, my = (pts[i].y + pts[i + 1].y) / 2;
                        ctx.quadraticCurveTo(pts[i].x, pts[i].y, mx, my);
                    }
                    ctx.lineTo(pts[pts.length - 1].x, pts[pts.length - 1].y);
                }

                const base = chartArea.topPad + chartArea.plotH;
                const x0 = pts[0].x, x1 = pts[pts.length - 1].x;

                // Curve and fill in the saturated accent
                const c = Theme.vivid;
                const strokeGrad = c;
                const fillGrad = ctx.createLinearGradient(0, chartArea.topPad, 0, base);
                fillGrad.addColorStop(0, Qt.rgba(c.r, c.g, c.b, 0.42));
                fillGrad.addColorStop(1, Qt.rgba(c.r, c.g, c.b, 0.04));

                ctx.beginPath();
                trace();
                ctx.lineTo(x1, base);
                ctx.lineTo(x0, base);
                ctx.closePath();
                ctx.fillStyle = fillGrad;
                ctx.fill();

                // Fade the fill out towards the bottom with the zone's background
                const bgc = Theme.bgAlt;
                const fade = ctx.createLinearGradient(0, chartArea.topPad, 0, base);
                fade.addColorStop(0, Qt.rgba(bgc.r, bgc.g, bgc.b, 0));
                fade.addColorStop(1, Qt.rgba(bgc.r, bgc.g, bgc.b, 0.9));
                ctx.fillStyle = fade;
                ctx.fill();

                ctx.beginPath();
                trace();
                ctx.lineWidth = 2.5;
                ctx.strokeStyle = strokeGrad;
                ctx.stroke();
            }
        }

        // --- Sunrise / sunset markers: label at the very top, dotted line down ---
        Repeater {
            model: root.sunEvents
            delegate: Item {
                required property var modelData
                x: chartArea.xAt(modelData.offset / 60) - width / 2
                y: 0
                width: 70
                height: chartArea.topPad + chartArea.plotH

                Row {
                    id: sunLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 3
                    Glyph { text: modelData.kind === "rise" ? "\u{f059c}" : "\u{f059b}"; font.pixelSize: 11; color: Theme.fgDim }
                    Label { text: modelData.time; dim: true; font.pixelSize: 10 }
                }
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: sunLabel.height + 3
                    spacing: 3
                    Repeater {
                        model: Math.max(0, Math.floor((parent.parent.height - sunLabel.height - 3) / 6))
                        delegate: Rectangle { width: 1; height: 3; color: Theme.withAlpha(Theme.fg, 0.22) }
                    }
                }
            }
        }

        // --- Points: icon + temperature (every few hours), rain %, hour ---
        Repeater {
            model: root.hours
            delegate: Item {
                required property var modelData
                required property int index
                readonly property bool labeled: index % root.labelEvery === 0
                x: chartArea.xAt(index) - width / 2
                width: 40
                height: chartArea.height

                // Dot on the curve
                Rectangle {
                    visible: parent.labeled
                    x: parent.width / 2 - 3
                    y: chartArea.yAt(modelData.temp) - 3
                    width: 6; height: 6; radius: 3
                    color: Theme.vivid
                }
                // Icon + temperature above the curve
                Column {
                    visible: parent.labeled
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: chartArea.yAt(modelData.temp) - height - 6
                    spacing: 0
                    Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: WeatherIcons.icon(modelData.code, modelData.isDay); font.pixelSize: 15 }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: Math.round(modelData.temp) + "°"; font.pixelSize: 12; font.weight: Font.DemiBold }
                }
                // Rain chance + hour along the bottom
                Column {
                    visible: parent.labeled
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    spacing: 2
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2
                        Glyph { text: "\uf043"; font.pixelSize: 8; color: modelData.rain >= 50 ? Theme.rain : Theme.fgDim }
                        Label { text: modelData.rain + "%"; color: modelData.rain >= 50 ? Theme.rain : Theme.fgDim; font.pixelSize: 10 }
                    }
                    Label {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: index === 0 ? Tr.t("Now") : modelData.time
                        dim: index !== 0
                        font.pixelSize: 10
                        font.weight: index === 0 ? Font.DemiBold : Font.Normal
                    }
                }
            }
        }
    }
}
