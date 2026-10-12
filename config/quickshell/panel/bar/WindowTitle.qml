import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import "../common"
import "../services"

// What the focused window shows, in the width the bar gives it (TopBar.qml:
// from the workspaces to the gap before the center): its app's icon, the
// app's name and the window title, scrolling when it doesn't fit
// (bar/Marquee.qml). The app's name is dropped from the end of the title
// ("… — Brave"). For a browser, the page (services/WebPages.qml): the site's
// domain and icon instead of the browser's (the browser's stays for searches
// and sites without one), and the site's name dropped from the title ("… - YouTube").
// Fades out (keeping its place, so the bar doesn't shift) on an empty workspace.
BarPill {
    id: root
    property int fixedWidth: 340
    property bool hide: false
    // Quickshell learns the focused window from Hyprland's focus events: until
    // the first one (right after the panel starts) it's hyprctl's answer
    property string bootAddress: ""
    readonly property var win: Hyprland.activeToplevel
        ?? (bootAddress ? Hyprland.toplevels.values.find(t => "0x" + t.address === bootAddress) ?? null : null)
    readonly property bool onThisWorkspace: !!win && win.workspace?.id === Hyprland.focusedWorkspace?.id
    readonly property string appId: String(win?.wayland?.appId ?? win?.lastIpcObject?.class ?? "")
    readonly property var entry: appId ? DesktopEntries.heuristicLookup(appId) : null
    readonly property string appName: entry?.name ?? appId
    readonly property string rawTitle: String(win?.title ?? "")
    readonly property var page: WebPages.of(win)
    readonly property string siteIcon: WebPages.iconOf(win)
    readonly property string title: {
        let t = page?.title || rawTitle;
        const n = appName.split(" ")[0];
        if (n) t = t.replace(new RegExp("\\s+[—–-]\\s+[^—–-]*" + n.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + "[^—–-]*$", "i"), "");
        // "… - YouTube" on youtube.com: the domain already says it
        if (page) {
            const site = page.domain.split(".").slice(-2, -1)[0] ?? "";
            const m = t.match(/^(.*\S)\s+[—–|·-]\s+([^—–|·-]+)$/);
            if (m && site && m[2].toLowerCase().replace(/[^a-z0-9]/g, "") === site.replace(/[^a-z0-9]/g, "")) t = m[1];
        }
        return t === appName ? "" : t;
    }
    readonly property bool shown: !hide && onThisWorkspace && (title !== "" || appName !== "")

    implicitWidth: fixedWidth
    opacity: shown ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true

    Process {
        running: true
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.bootAddress = JSON.parse(text).address ?? ""; } catch (e) {} }
        }
    }

    Item {
        width: 16
        height: 16
        anchors.verticalCenter: parent.verticalCenter
        IconImage {
            id: appIcon
            anchors.fill: parent
            source: Quickshell.iconPath(root.entry?.icon ?? root.appId.toLowerCase(), true)
            visible: !favicon.visible && status === Image.Ready
        }
        Image {
            id: favicon
            anchors.fill: parent
            source: root.siteIcon
            sourceSize: Qt.size(32, 32)
            smooth: true
            asynchronous: true
            visible: root.siteIcon !== "" && status === Image.Ready
        }
    }
    Label {
        id: name
        text: page?.domain || root.appName
        font.pixelSize: 13
        font.weight: Font.DemiBold
        width: Math.min(implicitWidth, (root.fixedWidth - 2 * root.pad) / 2)
        anchors.verticalCenter: parent.verticalCenter
    }
    Marquee {
        text: root.title ? "·  " + root.title : ""
        dim: true
        // The rest of the pill (the row is pad + icon + spacing + name + spacing + this + pad)
        width: Math.max(0, root.fixedWidth - 2 * root.pad - 16 - name.width - 2 * root.spacing)
        anchors.verticalCenter: parent.verticalCenter
    }
}
