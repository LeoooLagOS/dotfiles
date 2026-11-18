import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// What's under the pointer in the bar (an item's `tip`), below it:
//   { title, desc, rows: [[label, value]], keys: [[label, "SUPER SHIFT T"]], hist, hint }
// the title, a line saying what it is, label / value rows, the keys that open
// it (each combo as key caps; the label "" for the main one) and, for CPU /
// RAM / temperature, the last minute as a line. Shows after a short hover,
// follows its item; not clickable.
// Items inside others (the tray's chevron in the workspaces' card, a
// reading in its card): the innermost hovered one shows, and leaving it
// gives the tip back to the one around it.
Rectangle {
    id: root
    property Item target: null
    property var info: target?.tip ?? null
    property real barBottom: 0
    property var hovered: []                    // the items under the pointer that asked
    function inside(a, b) { for (let p = b?.parent; p; p = p.parent) if (p === a) return true; return false; }
    // The innermost: no other hovered item inside it (the last one on a tie)
    function pick() {
        const live = hovered.filter(i => !hovered.some(j => j !== i && inside(i, j)));
        return live.length ? live[live.length - 1] : null;
    }
    function show(item) { hovered = hovered.filter(i => i !== item).concat([item]); update(); }
    // Leaving the last one, the tip stays a moment: a screenshot (SUPER SHIFT S)
    // puts slurp's layer over the bar, which takes the pointer away before
    // PanelState.capturing knows; while it's picking the tip stays, so it can
    // be in the picture, and goes when the capture is over
    function hide(item) {
        hovered = hovered.filter(i => i !== item);
        if (target && !pick()) leave.restart();
        else update();
    }
    Timer { id: leave; interval: 200; onTriggered: if (!PanelState.capturing) root.update() }
    Connections {
        target: PanelState
        function onCapturingChanged() { if (!PanelState.capturing) root.update(); }
    }
    // From nothing, after a short hover; from one tip to another, at once
    function update() {
        const next = pick();
        if (!next) { delay.stop(); leave.stop(); target = null; }
        else if (target) target = next;
        else delay.restart();
    }
    Timer { id: delay; interval: 350; onTriggered: root.target = root.pick() }

    visible: opacity > 0
    opacity: target && info ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 120 } }
    // Lined up with its card, as wide as it: a reading's tip under the whole
    // readings card, the tray's under the workspaces'. Wider only when its
    // rows need it (or the card is a single button): then it grows away from
    // the screen's edge on its side, or both ways in the middle
    readonly property Item card: {
        for (let p = target; p; p = p.parent) if (p.isCard === true) return p;
        return target;
    }
    width: Math.max(card ? card.width : 0, 220, col.implicitWidth + 24)
    height: col.implicitHeight + 20
    radius: 12
    color: Theme.withAlpha(Theme.panel.base, 0.94)
    border.color: Theme.border
    y: barBottom + 6
    x: {
        if (!card || !parent) return 0;
        const left = card.mapToItem(parent, 0, 0).x, right = left + card.width, mid = (left + right) / 2;
        const third = parent.width / 3;
        const want = mid < third ? left : mid > 2 * third ? right - width : mid - width / 2;
        return Math.max(8, Math.min(parent.width - width - 8, want));
    }

    ColumnLayout {
        id: col
        x: 12
        y: 10
        width: root.width - 24
        spacing: 3
        Label { text: root.info?.title ?? ""; font.pixelSize: 13; font.weight: Font.DemiBold }
        // Wraps to the tip's width; it doesn't make the tip wider
        Label {
            visible: !!root.info?.desc
            text: root.info?.desc ?? ""
            dim: true
            font.pixelSize: 12
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.preferredWidth: 0
            Layout.bottomMargin: 2
        }
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
        // The keys: each combo as key caps, like Settings → Keyboard
        Repeater {
            model: root.info?.keys ?? []
            delegate: RowLayout {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: index === 0 ? 4 : 0
                spacing: 18
                Label { text: modelData[0] || Tr.t("Shortcut"); dim: true; font.pixelSize: 12 }
                Item { Layout.fillWidth: true }
                Row {
                    spacing: 3
                    Repeater {
                        model: String(modelData[1]).split(" ")
                        delegate: Rectangle {
                            required property string modelData
                            implicitHeight: 20
                            implicitWidth: capLabel.implicitWidth + 10
                            radius: 5
                            color: Theme.withAlpha(Theme.fg, 0.06)
                            border.color: Theme.border
                            Label { id: capLabel; anchors.centerIn: parent; text: Tr.t(parent.modelData); font.family: "JetBrains Mono"; font.pixelSize: 10 }
                        }
                    }
                }
            }
        }
        Label { visible: !!root.info?.hint; text: root.info?.hint ?? ""; dim: true; font.pixelSize: 11; Layout.topMargin: 2
                wrapMode: Text.Wrap; Layout.fillWidth: true; Layout.preferredWidth: 0 }
    }
}
