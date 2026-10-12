import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// Details of the reading under the pointer (StatItem.tip), below the bar:
// title, label / value rows and, for CPU / RAM / temperature, the last minute
// as a line. Shows after a short hover, follows its item; not clickable.
Rectangle {
    id: root
    property Item target: null
    property var info: target?.tip ?? null
    property real barBottom: 0
    function show(item) { pending = item; delay.restart(); }
    function hide(item) { if (pending === item) { delay.stop(); pending = null; } if (target === item) target = null; }
    property Item pending: null
    Timer { id: delay; interval: 350; onTriggered: root.target = root.pending }

    visible: opacity > 0
    opacity: target && info ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    width: Math.max(200, col.implicitWidth + 24)
    height: col.implicitHeight + 20
    radius: 12
    color: Theme.withAlpha(Theme.panel.base, 0.94)
    border.color: Theme.border
    y: barBottom + 8
    x: {
        if (!target || !parent) return 0;
        const p = target.mapToItem(parent, target.width / 2, 0);
        return Math.max(8, Math.min(parent.width - width - 8, p.x - width / 2));
    }

    ColumnLayout {
        id: col
        x: 12
        y: 10
        width: root.width - 24
        spacing: 3
        Label { text: root.info?.title ?? ""; font.pixelSize: 13; font.weight: Font.DemiBold }
        Repeater {
            model: root.info?.rows ?? []
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 18
                Label { text: modelData[0]; dim: true; font.pixelSize: 12 }
                Item { Layout.fillWidth: true }
                Label { text: modelData[1]; font.pixelSize: 12; font.features: { "tnum": 1 } }
            }
        }
        // Last minute (0–100 scale, or the values' own range for °C)
        Canvas {
            id: spark
            visible: (root.info?.hist ?? []).length > 1
            Layout.fillWidth: true
            Layout.topMargin: 4
            implicitHeight: 36
            property var hist: root.info?.hist ?? []
            onHistChanged: requestPaint()
            onWidthChanged: requestPaint()
            onPaint: {
                const g = getContext("2d");
                g.reset();
                const h = hist, n = h.length;
                if (n < 2) return;
                const lo = root.info?.min ?? 0, hi = root.info?.max ?? 100;
                const px = i => i / (n - 1) * width, py = v => height - 2 - (Math.max(lo, Math.min(hi, v)) - lo) / (hi - lo) * (height - 4);
                g.beginPath();
                g.moveTo(0, height);
                for (let i = 0; i < n; i++) g.lineTo(px(i), py(h[i]));
                g.lineTo(width, height);
                g.closePath();
                g.fillStyle = Theme.withAlpha(BarState.accent, 0.16);
                g.fill();
                g.beginPath();
                for (let i = 0; i < n; i++) i ? g.lineTo(px(i), py(h[i])) : g.moveTo(px(i), py(h[i]));
                g.strokeStyle = BarState.accent;
                g.lineWidth = 1.6;
                g.stroke();
            }
        }
        Label { visible: !!root.info?.hint; text: root.info?.hint ?? ""; dim: true; font.pixelSize: 11; Layout.topMargin: 2 }
    }
}
