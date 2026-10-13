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
// For a comms app (Comms.infoOf): its unread count, then what its title says
// besides the app (Thunderbird's folder and account, Teams' section) and its
// latest messages ("who: text").
// For a terminal in a git repository (scripts/gitstatus.sh): the repo, its
// branch and what's pending (↑ ahead ↓ behind · + staged · ~ modified · ? new
// · ! conflicts, ✓ when clean), checked as its title changes and every few seconds.
// Always the width it's given (the gap to the center stays the same); what it
// shows is centered in it while it's shorter.
// Fades out (keeping its place, so the bar doesn't shift) on an empty workspace,
// where the next event shows instead (bar/Agenda.qml, TopBar.qml).
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
    // A comms app (services/Comms.qml): its unread count, what its title says
    // and its latest messages instead of the bare title
    readonly property var comms: Comms.infoOf(appId, rawTitle)
    function esc(s) { return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }
    readonly property string commsText: !comms ? ""
        : comms.context.map(esc).concat(comms.messages.map(m => (m.who ? "<b>" + esc(m.who) + "</b>: " : "") + esc(m.text))).join("  ·  ")
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
    // A comms app lives in its own special workspace, shown over the empty "comms" one
    readonly property bool commsShown: !!comms && String(win?.workspace?.name ?? "").startsWith("special:comms-")
        && (Comms.shown !== "" || Hyprland.focusedWorkspace?.name === "comms")
    // A window to show (else bar/Agenda.qml takes the place)
    readonly property bool hasWindow: (onThisWorkspace || commsShown) && (title !== "" || appName !== "")
    readonly property bool shown: !hide && hasWindow

    // Git, for a terminal: [repo, branch, ahead, behind, staged, modified, untracked, conflicts]
    readonly property bool terminal: /^(kitty|foot|footclient|alacritty|com\.mitchellh\.ghostty|org\.wezfurlong\.wezterm|wezterm)$/i.test(appId)
    readonly property int pid: terminal ? Number(win?.lastIpcObject?.pid ?? 0) : 0
    property var git: null
    readonly property string gitText: {
        if (!git) return "";
        const c = (col, s) => "<font color='" + col + "'>" + s + "</font>";
        const n = i => Number(git[i]);
        const parts = [c(Theme.fgDim, esc(git[0])), "<b>" + esc(git[1]) + "</b>"];
        if (n(2)) parts.push(c(Theme.accent, "↑" + n(2)));
        if (n(3)) parts.push(c(Theme.accent, "↓" + n(3)));
        if (n(7)) parts.push(c(Theme.bad, "!" + n(7)));
        if (n(4)) parts.push(c(Theme.good, "+" + n(4)));
        if (n(5)) parts.push(c(Theme.warn, "~" + n(5)));
        if (n(6)) parts.push(c(Theme.fgDim, "?" + n(6)));
        if (!n(4) && !n(5) && !n(6) && !n(7)) parts.push(c(Theme.good, "✓"));
        return parts.join(" ");
    }
    function checkGit() {
        if (!pid) { git = null; return; }
        gitProc.running = false;
        gitProc.running = true;
    }
    onPidChanged: checkGit()
    onRawTitleChanged: if (terminal) checkGit()
    onWinChanged: if (terminal && !pid) Hyprland.refreshToplevels()
    Process {
        id: gitProc
        command: [Quickshell.shellDir + "/scripts/gitstatus.sh", String(root.pid)]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\t");
                root.git = f.length === 8 ? f : null;
            }
        }
    }
    Timer {
        interval: 4000
        repeat: true
        running: root.shown && root.pid > 0
        onTriggered: root.checkGit()
    }

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
        text: root.comms?.name || root.page?.domain || root.appName
        font.pixelSize: 13
        font.weight: Font.DemiBold
        width: Math.min(implicitWidth, (root.fixedWidth - 2 * root.pad) / 2)
        anchors.verticalCenter: parent.verticalCenter
    }
    // Unread (comms apps)
    Rectangle {
        id: badge
        visible: (root.comms?.badge ?? 0) > 0
        anchors.verticalCenter: parent.verticalCenter
        height: 16
        width: visible ? Math.max(16, badgeText.implicitWidth + 8) : 0
        radius: 8
        color: BarState.accent
        Label {
            id: badgeText
            anchors.centerIn: parent
            text: (root.comms?.badge ?? 0) > 99 ? "99+" : root.comms?.badge ?? ""
            color: BarState.accentText
            font.pixelSize: 10
            font.weight: Font.Bold
            font.features: { "tnum": 1 }
        }
    }
    // Git (terminals in a repository)
    Row {
        id: gitInfo
        visible: root.gitText !== ""
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        Glyph { text: "\ue725"; font.pixelSize: 13; color: BarState.accent; anchors.verticalCenter: parent.verticalCenter }
        Label {
            text: root.gitText
            textFormat: Text.StyledText
            font.pixelSize: 13
            font.features: { "tnum": 1 }
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Marquee {
        id: marquee
        visible: text !== ""
        textFormat: root.comms ? Text.StyledText : Text.PlainText
        text: root.comms ? (root.commsText ? "·  " + root.commsText : "")
            : root.title ? "·  " + root.title : ""
        dim: true
        // Its text, up to the rest of the pill (the row is pad + icon + spacing + name + spacing + this + pad)
        width: Math.min(implicitWidth, Math.max(0, root.fixedWidth - 2 * root.pad - 16 - name.width - 2 * root.spacing
                           - (badge.visible ? badge.width + root.spacing : 0)
                           - (gitInfo.visible ? gitInfo.width + root.spacing : 0)))
        anchors.verticalCenter: parent.verticalCenter
    }
}
