pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// Communication apps kept running out of sight (so their notifications
// arrive), each in its own hidden Hyprland workspace special:comms-<key>, and
// the dock (CommsDock.qml) to reach them: SUPER Y shows the last one used with
// the dock below; a dock icon switches app; the shown one (or SUPER Y) hides it.
// Each special workspace has a bottom gap for the dock (UserConfigs/user_window_rules.lua),
// so the app fills the rest of the screen. Apps not running are started by
// scripts/wm/CommsStartup.sh <key>, which also runs them all at login.
//   apps      [{ key, name, icon, running, address, badge }]
//   shownOn   { monitor name: key } — the app shown on each monitor
//   toggle() · show(key) · hide() · showFor(notification)
Singleton {
    id: root

    readonly property string startup: Quickshell.env("HOME") + "/.config/hypr/scripts/CommsStartup.sh"
    // Which windows are each app's: class, and for a web app its title (every
    // Brave web app has a class brave-<id>-Default); `main` picks the main window
    // when an app has several (Thunderbird's reminders and composer stay where they are)
    readonly property var defs: [
        { key: "whatsapp", name: "WhatsApp", cls: /^(brave-.+-Default|crx_.+)$/, title: /WhatsApp/,
          main: /WhatsApp/, iconName: "", webApp: "WhatsApp" },
        { key: "mail", name: "Thunderbird", cls: /^(net\.thunderbird\.Thunderbird|thunderbird)$/, title: /Thunderbird/,
          main: /Mozilla Thunderbird$|Thunderbird$/, iconName: "thunderbird", webApp: "" }
    ]

    property var clients: []                  // hyprctl clients -j
    property var shownOn: ({})                // monitor → key
    property string last: "whatsapp"          // shown by SUPER Y
    property var seenAt: ({})                 // key → when last shown (for the badge)

    function windowsOf(d) {
        return clients.filter(c => d.cls.test(c.class) && (d.title.test(c.initialTitle || "") || d.title.test(c.title || "")));
    }
    function mainOf(d) {
        const ws = windowsOf(d);
        return ws.find(c => c.workspace.name === "special:comms-" + d.key) ?? ws.find(c => d.main.test(c.title)) ?? ws[0] ?? null;
    }
    function iconOf(d) {
        if (d.webApp) {
            const a = Notifs.webApps.find(w => w.name.toLowerCase().startsWith(d.webApp.toLowerCase()));
            if (a?.icon) return a.icon.startsWith("file://") ? a.icon : Quickshell.iconPath(a.icon, true);
        }
        return d.iconName ? Quickshell.iconPath(d.iconName, true) : "";
    }
    // Notifications from this app since it was last shown
    function isFrom(d, n) {
        if (d.key === "mail") return !!Notifs.mailOf(n);
        return Notifs.webService(n)?.name === d.webApp || (n.appName || "").toLowerCase().startsWith(d.webApp.toLowerCase());
    }
    function unseen(d) {
        const since = seenAt[d.key] ?? 0;
        return Notifs.list.filter(n => isFrom(d, n) && (Notifs.received[n.id]?.getTime() ?? 0) > since).length;
    }

    readonly property var apps: defs.map(d => {
        const w = mainOf(d);
        // WhatsApp puts the unread count in its title: "(3) WhatsApp"
        const m = /^\((\d+)\)/.exec(w?.title ?? "");
        return { key: d.key, name: d.name, icon: iconOf(d), running: !!w, address: w?.address ?? "",
                 badge: m ? Number(m[1]) : unseen(d) };
    })
    readonly property string focusedMonitor: Hyprland.focusedMonitor?.name ?? ""
    readonly property string shown: shownOn[focusedMonitor] ?? ""
    // SUPER Y brings back the last one seen, however it was shown
    onShownChanged: if (shown) { last = shown; markSeen(shown); }

    function dispatch(expr) { Quickshell.execDetached(["hyprctl", "dispatch", expr]); }
    function markSeen(key) { const s = Object.assign({}, seenAt); s[key] = Date.now(); seenAt = s; }

    function show(key) {
        const d = defs.find(x => x.key === key);
        if (!d) return;
        last = key;
        markSeen(key);
        const w = mainOf(d);
        if (!w) {                                 // not running: start it, shown
            Quickshell.execDetached([startup, key, "--show"]);
            return;
        }
        const ws = "special:comms-" + key;
        if (w.workspace.name !== ws)
            dispatch(`hl.dsp.window.move({ workspace = "${ws}", follow = false, window = "address:${w.address}" })`);
        // Focusing a window in a hidden special workspace shows it (and hides another one)
        dispatch(`hl.dsp.focus({ window = "address:${w.address}" })`);
    }
    function hide() {
        if (shown) dispatch(`hl.dsp.workspace.toggle_special("comms-${shown}")`);
    }
    function toggle() { shown ? hide() : show(last); }
    function pick(key) { key === shown ? hide() : show(key); }
    // A notification clicked: if it's from one of these apps, bring it up
    function showFor(n) {
        const d = defs.find(x => isFrom(x, n));
        if (!d) return;
        PanelState.open = false;
        show(d.key);
    }

    // ---------------- Hyprland state ----------------
    Process {
        id: clientsProc
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector { onStreamFinished: { try { root.clients = JSON.parse(text); } catch (e) {} } }
    }
    Process {
        id: monitorsProc
        command: ["hyprctl", "-j", "monitors"]
        stdout: StdioCollector {
            onStreamFinished: {
                let ms;
                try { ms = JSON.parse(text); } catch (e) { return; }
                const s = {};
                for (const m of ms) {
                    const name = m.specialWorkspace?.name ?? "";
                    if (name.startsWith("special:comms-")) s[m.name] = name.slice("special:comms-".length);
                }
                root.shownOn = s;
            }
        }
    }
    function refresh() {
        if (!clientsProc.running) clientsProc.running = true;
        if (!monitorsProc.running) monitorsProc.running = true;
    }
    Timer { id: refreshSoon; interval: 120; onTriggered: root.refresh() }
    Component.onCompleted: refresh()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["activespecial", "openwindow", "closewindow", "movewindow", "windowtitle", "monitoradded", "monitorremoved"].includes(event.name))
                refreshSoon.restart();
        }
    }
}
