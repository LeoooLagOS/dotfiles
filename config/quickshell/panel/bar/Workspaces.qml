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
        model: root.ids
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
            implicitWidth: wsRow.implicitWidth + (empty ? 12 : 16)
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
                    text: ws.modelData
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    color: ws.on ? Theme.fg : Theme.fgDim
                    opacity: ws.empty && !ws.on ? 0.6 : 1
                    anchors.verticalCenter: parent.verticalCenter
                }
                Repeater {
                    model: Settings.v.barWsIcons ? ws.apps.slice(0, 4) : []
                    delegate: IconImage {
                        required property string modelData
                        source: modelData
                        implicitSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    visible: Settings.v.barWsIcons && ws.apps.length > 4
                    text: "+" + (ws.apps.length - 4)
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
