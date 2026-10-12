import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import "../common"
import "../services"

// What the focused window shows: its app's icon, the app's name and the
// window title (for a browser, the page). The app's name is dropped from the
// end of the title ("… — Brave"). Hidden on an empty workspace.
BarPill {
    id: root
    property int maxWidth: 480
    readonly property var win: Hyprland.activeToplevel
    readonly property bool onThisWorkspace: !!win && win.workspace?.id === Hyprland.focusedWorkspace?.id
    readonly property string appId: String(win?.wayland?.appId ?? win?.lastIpcObject?.class ?? "")
    readonly property var entry: appId ? DesktopEntries.heuristicLookup(appId) : null
    readonly property string appName: entry?.name ?? appId
    readonly property string title: {
        let t = String(win?.title ?? "");
        const n = appName.split(" ")[0];
        if (n) t = t.replace(new RegExp("\\s+[—–-]\\s+[^—–-]*" + n.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "[^—–-]*$", "i"), "");
        return t === appName ? "" : t;
    }
    visible: onThisWorkspace && (title !== "" || appName !== "")
    implicitWidth: Math.min(maxWidth, contentWidth + 2 * pad)
    clip: true

    IconImage {
        source: Quickshell.iconPath(root.entry?.icon ?? root.appId.toLowerCase(), true)
        implicitSize: 16
        visible: status === Image.Ready
        anchors.verticalCenter: parent.verticalCenter
    }
    Label {
        text: root.appName
        font.pixelSize: 13
        font.weight: Font.DemiBold
        anchors.verticalCenter: parent.verticalCenter
    }
    Label {
        visible: root.title !== ""
        text: "·  " + root.title
        dim: true
        font.pixelSize: 13
        width: Math.min(implicitWidth, root.maxWidth - 2 * root.pad - x)
        anchors.verticalCenter: parent.verticalCenter
    }
}
