import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../common"
import "../services"

// Workspaces: number + icons of the apps on each; the active one tinted with
// an accent underline. Empty ones 1–5 shown or hidden (Settings → Bar).
// Click: go there · wheel: next / previous. Special workspaces and the
// empty "comms" one behind the comms dock (services/Comms.qml) are skipped.
BarPill {
    id: root
    property var monitor: null                   // HyprlandMonitor of this bar
    pad: 4
    spacing: 3

    readonly property int activeId: monitor?.activeWorkspace?.id ?? Hyprland.focusedWorkspace?.id ?? 1
    readonly property var ids: {
        const s = new Set(Hyprland.workspaces.values.filter(w => w.id > 0 && w.name !== "comms").map(w => w.id));
        if (Settings.v.barEmptyWs === "show") for (let i = 1; i <= 5; i++) s.add(i);
        s.add(activeId);
        return [...s].filter(i => i > 0).sort((a, b) => a - b);
    }
    // As wide as its content, growing with the apps up to `cap` (TopBar.qml);
    // past it each workspace shows fewer app icons ("+N" for the rest)
    property real cap: 100000
    // Icons per workspace that fit in `cap` (4 at most, 1 at least): each
    // workspace is its number + 5 + 15 per icon (+ 5 + "+N") + its padding
    readonly property int iconLimit: {
        layoutTick;
        const items = [];
        for (let i = 0; i < wsRepeater.count; i++) { const it = wsRepeater.itemAt(i); if (it) items.push(it); }
        const widthWith = k => items.reduce((a, it) => {
            const n = Settings.v.barWsIcons ? it.apps.length : 0;
            return a + it.numWidth + Math.min(n, k) * 20 + (n > k ? 21 : 0) + (it.empty ? 12 : 16);
        }, 0) + Math.max(0, items.length - 1) * spacing + 2 * pad;
        for (let k = 4; k > 1; k--) if (widthWith(k) <= cap) return k;
        return 1;
    }
    // When the bar makes the card wider (the panel open: both halves measure
    // the same) the extra is shared among the workspaces, so they spread out
    property int layoutTick: 0
    // Later, once: a delegate's size changing while these are evaluated would loop
    function relayout() { Qt.callLater(bump); }
    function bump() { layoutTick++; }
    readonly property real baseSum: {
        layoutTick;
        let w = 0;
        for (let i = 0; i < wsRepeater.count; i++) w += wsRepeater.itemAt(i)?.baseWidth ?? 0;
        return w;
    }
    readonly property real natural: baseSum + Math.max(0, wsRepeater.count - 1) * spacing + 2 * pad
    readonly property real extraEach: wsRepeater.count ? Math.max(0, (width - natural) / wsRepeater.count) : 0
    function go(target) { Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ workspace = ${target} })`]); }
    onWheel: d => go(d > 0 ? '"e-1"' : '"e+1"')

    // The app of a window: its icon from the desktop entry (or the class as a
    // theme icon); for a browser, the site's (services/WebPages.qml)
    function iconFor(t) {
        const site = WebPages.iconOf(t);
        if (site) return site;
        const id = String(t?.wayland?.appId ?? t?.lastIpcObject?.class ?? "");
        if (!id) return "";
        const e = DesktopEntries.heuristicLookup(id);
        return Quickshell.iconPath(e?.icon ?? id.toLowerCase(), true) || Quickshell.iconPath(id.toLowerCase(), true);
    }

    Repeater {
        id: wsRepeater
        model: root.ids
        onCountChanged: root.relayout()
        delegate: Rectangle {
            id: ws
            required property int modelData
            readonly property bool on: modelData === root.activeId
            readonly property var apps: {
                const seen = new Set(), out = [];
                for (const t of Hyprland.toplevels.values) {
                    if (t.workspace?.id !== modelData) continue;
                    const ic = root.iconFor(t);
                    if (ic && !seen.has(ic)) { seen.add(ic); out.push(ic); }
                }
                return out;
            }
            readonly property bool empty: !Hyprland.toplevels.values.some(t => t.workspace?.id === modelData)
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: Settings.v.barHeight - 16
            readonly property real numWidth: num.implicitWidth
            readonly property real baseWidth: wsRow.implicitWidth + (empty ? 12 : 16)
            onBaseWidthChanged: root.relayout()
            onAppsChanged: root.relayout()
            Component.onCompleted: root.relayout()
            implicitWidth: baseWidth + root.extraEach
            radius: 8
            color: on ? Theme.withAlpha(BarState.accent, 0.18) : wsMouse.containsMouse ? Theme.bgHover : "transparent"
            Behavior on color { ColorAnimation { duration: Theme.anim } }
            Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            // Accent underline on the active one
            Rectangle {
                visible: ws.on
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 12
                height: 2
                radius: 1
                color: BarState.accent
            }
            Row {
                id: wsRow
                anchors.centerIn: parent
                spacing: 5
                Label {
                    id: num
                    text: ws.modelData
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    color: ws.on ? Theme.fg : Theme.fgDim
                    opacity: ws.empty && !ws.on ? 0.6 : 1
                    anchors.verticalCenter: parent.verticalCenter
                }
                Repeater {
                    model: Settings.v.barWsIcons ? ws.apps.slice(0, root.iconLimit) : []
                    delegate: IconImage {
                        required property string modelData
                        source: modelData
                        implicitSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    visible: Settings.v.barWsIcons && ws.apps.length > root.iconLimit
                    text: "+" + (ws.apps.length - root.iconLimit)
                    font.pixelSize: 10
                    dim: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.go(ws.modelData)
            }
        }
    }
}
