pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// Communication apps kept running out of sight (so their notifications
// arrive), each in its own hidden Hyprland workspace special:comms-<key>, and
// the dock (CommsDock.qml) to reach them: SUPER Y shows the last one used with
// the dock below; a dock icon switches app (starting it if it isn't running);
// the shown one (or SUPER Y) hides it.
// Which apps: Settings → Comms dock (Settings.v.commsApps: desktop entry ids,
// or "name:<Name>" for one whose id differs per machine, like a browser web app).
// Every special:comms-* workspace has a bottom gap for the dock
// (UserConfigs/user_window_rules.lua), so the app fills the rest of the screen.
// At login scripts/wm/CommsStartup.sh calls startAll(): each app opens hidden.
// Behind the shown app the monitor switches to an empty workspace, "comms", so
// the wallpaper shows through (the apps are a bit translucent: a window rule;
// special workspaces aren't dimmed: user_settings.lua); hiding goes back.
// Keyboard: SUPER SHIFT Y (IPC commsDock) puts the focus on the dock:
// ←/→ choose, Enter opens, 1–9 by position, Esc back to the app.
//   apps      [{ ref, key, name, icon, running, address, badge }] (installed ones)
//   missing   refs in the setting that aren't installed
//   shownOn   { monitor name: key } — the app shown on each monitor
//   toggle() · show(key) · hide() · pick(key) · showFor(notification) · startAll()
Singleton {
    id: root

    // Suggested in Settings when installed (desktop id or "name:…" as above)
    readonly property var suggested: ["name:WhatsApp Web", "net.thunderbird.Thunderbird", "com.github.IsmaelMartinez.teams_for_linux",
        "org.telegram.desktop", "dev.vencord.Vesktop", "com.discordapp.Discord", "com.slack.Slack", "org.signal.Signal",
        "im.riot.Riot", "name:Google Meet"]

    property var clients: []                  // hyprctl clients -j
    property var shownOn: ({})                // monitor → key
    property string last: ""                  // shown by SUPER Y
    property var seenAt: ({})                 // key → when last shown (for the badge)
    property var pending: ({})                // key → { show, since }: started, waiting for its window
    property var home: ({})                   // monitor → the workspace to go back to on hiding
    property bool dockFocus: false            // the dock has the keyboard

    // ---------------- The apps ----------------
    function entryOf(ref) {
        if (!ref) return null;
        const all = DesktopEntries.applications.values;
        if (ref.startsWith("name:")) return all.find(e => e.name === ref.slice(5)) ?? null;
        return DesktopEntries.byId(ref) ?? all.find(e => e.id.toLowerCase() === ref.toLowerCase()) ?? null;
    }
    function slug(s) { return String(s).toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, ""); }
    // Window classes of an entry: its StartupWMClass and id; a Brave/Chrome web
    // app (crx_<id>) is brave-<id>-Default / chrome-<id>-Default on Wayland
    function classesOf(e) {
        const out = [e.startupClass, e.id, e.id.split(".").pop()].filter(x => x).map(x => x.toLowerCase());
        const m = /^crx_(.+)$/i.exec(e.startupClass || "");
        if (m) out.push(("brave-" + m[1] + "-default").toLowerCase(), ("chrome-" + m[1] + "-default").toLowerCase());
        return out;
    }
    // Short name for the dock: "WhatsApp Web" → "WhatsApp", "Teams for Linux" → "Teams"
    function shortName(n) { return String(n).replace(/\s+(Web|for Linux|Desktop)$/i, ""); }
    function iconOf(e) {
        const ic = e.icon || "";
        if (ic.startsWith("/")) return "file://" + ic;
        return Quickshell.iconPath(ic, true) || Quickshell.iconPath(e.id, true);
    }

    readonly property var defs: (Settings.v.commsApps ?? []).map(ref => {
        const e = entryOf(ref);
        return e ? { ref: ref, entry: e, key: slug(shortName(e.name)), name: shortName(e.name), classes: classesOf(e) } : null;
    }).filter(d => d)
    readonly property var missing: (Settings.v.commsApps ?? []).filter(ref => !entryOf(ref))

    function windowsOf(d) { return clients.filter(c => d.classes.includes(String(c.class).toLowerCase())); }
    // The main window: the one already in its workspace, else the one titled
    // with the app's name ("Mozilla Thunderbird", not "Calendar Reminders"),
    // tiled rather than floating (dialogs), the biggest
    function mainOf(d) {
        const word = d.name.split(/\s+/)[0].toLowerCase();
        const score = c => (c.workspace.name === "special:comms-" + d.key ? 8 : 0)
                         + (((c.initialTitle || "") + " " + (c.title || "")).toLowerCase().includes(word) ? 4 : 0)
                         + (c.floating ? 0 : 2);
        return windowsOf(d).sort((a, b) => score(b) - score(a) || b.size[0] * b.size[1] - a.size[0] * a.size[1])[0] ?? null;
    }
    // Notifications from this app: its desktop entry, or its name in the app name
    function isFrom(d, n) {
        if (!n) return false;
        if (n.desktopEntry && n.desktopEntry === d.entry.id) return true;
        const word = d.name.split(/\s+/)[0].toLowerCase();
        if (word === "thunderbird") return !!Notifs.mailOf(n);
        const app = ((n.appName || "") + " " + (n.desktopEntry || "")).toLowerCase();
        return word.length > 2 && (app.includes(word) || (Notifs.webService(n)?.name ?? "").toLowerCase() === word);
    }
    function unseen(d) {
        const since = seenAt[d.key] ?? 0;
        return Notifs.list.filter(n => isFrom(d, n) && (Notifs.received[n.id]?.getTime() ?? 0) > since).length;
    }

    readonly property var apps: defs.map(d => {
        const w = mainOf(d);
        // Web apps put the unread count in the title: "(3) WhatsApp"
        const m = /^\((\d+)\)/.exec(w?.title ?? "");
        return { ref: d.ref, key: d.key, name: d.name, icon: iconOf(d.entry), running: !!w, address: w?.address ?? "",
                 badge: m ? Number(m[1]) : unseen(d) };
    })
    readonly property string focusedMonitor: Hyprland.focusedMonitor?.name ?? ""
    readonly property string shown: shownOn[focusedMonitor] ?? ""
    // SUPER Y brings back the last one seen, however it was shown. Hidden
    // (whichever way): back from the empty workspace to the one you were in
    onShownChanged: {
        if (quiet) return;                    // a quick reply passing through
        if (shown) { last = shown; markSeen(shown); return; }
        dockFocus = false;
        const m = Hyprland.focusedMonitor;
        if (m?.activeWorkspace?.name === "comms" && home[m.name] !== undefined)
            dispatch(`hl.dsp.focus({ workspace = "${home[m.name]}" })`);
    }

    // ---------------- Actions ----------------
    function dispatch(expr) { Quickshell.execDetached(["hyprctl", "dispatch", expr]); }
    // Several in one go, in this order
    function dispatchAll(exprs) { Quickshell.execDetached(["hyprctl", "--batch", exprs.map(e => "dispatch " + e).join(" ; ")]); }
    // Before showing: the empty workspace behind, remembering where we were
    function backdrop() {
        const m = Hyprland.focusedMonitor, ws = m?.activeWorkspace;
        if (shown || !ws || ws.name === "comms") return [];
        const h = Object.assign({}, home);
        h[m.name] = ws.id;
        home = h;
        return [`hl.dsp.focus({ workspace = "name:comms" })`];
    }
    function markSeen(key) { const s = Object.assign({}, seenAt); s[key] = Date.now(); seenAt = s; }
    function moveIn(d, w, focus) {
        const ws = "special:comms-" + d.key, cmds = [];
        if (w.workspace.name !== ws)
            cmds.push(`hl.dsp.window.move({ workspace = "${ws}", follow = false, window = "address:${w.address}" })`);
        // Focusing a window in a hidden special workspace shows it (and hides another one)
        if (focus) cmds.push(...backdrop(), `hl.dsp.focus({ window = "address:${w.address}" })`);
        if (cmds.length) dispatchAll(cmds);
    }
    function launch(d, show) {
        const p = Object.assign({}, pending);
        p[d.key] = { show: show, since: Date.now() };
        pending = p;
        // Through Hyprland, so the app isn't a child of the panel's service
        dispatch(`hl.dsp.exec_cmd("gtk-launch ${d.entry.id}")`);
        pendingTimer.start();
    }

    function show(key) {
        const d = defs.find(x => x.key === key);
        if (!d) return;
        last = key;
        markSeen(key);
        const w = mainOf(d);
        if (w) moveIn(d, w, true); else launch(d, true);
    }
    function hide() {
        if (shown) dispatch(`hl.dsp.workspace.toggle_special("comms-${shown}")`);
    }
    function toggle() {
        if (shown) { hide(); return; }
        show(defs.some(d => d.key === last) ? last : (defs.find(d => mainOf(d))?.key ?? defs[0]?.key ?? ""));
    }
    function pick(key) { key === shown ? hide() : show(key); }
    // SUPER SHIFT Y: the keyboard to the dock (showing an app first if none is)
    function focusDock() {
        if (!defs.length) return;
        if (!shown) toggle();
        dockFocus = true;
    }
    // A notification clicked: if it's from one of these apps, bring it up
    function showFor(n) {
        if (Notifs.isTest(n)) return;
        const d = defs.find(x => isFrom(x, n));
        if (!d) return;
        PanelState.open = false;
        show(d.key);
    }
    // ---------------- Quick reply ----------------
    // From the notification: the app's own inline reply when it offers one;
    // else, for a message from a dock app (not mail), its action opens the chat
    // and scripts/reply.sh pastes the text there and presses Enter
    function canReply(n) {
        if (!n || Notifs.isTest(n)) return false;
        if (n.hasInlineReply) return true;
        const d = defs.find(x => isFrom(x, n));
        return !!d && !Notifs.mailOf(n) && Notifs.placeKind(n) === "message"
            && !!mainOf(d) && (n.actions ?? []).some(a => a.identifier === "default");
    }
    // A reply in progress (ReplyBox.qml shows it): kept apart from the
    // notification, which the app may close at any moment (WhatsApp closes its
    // own when clicked, and after a few seconds anyway)
    //   { who, app, key, address, notif (inline replies only), openedAt }
    property var session: null
    property string sessionState: ""          // "" | "sending" | "sent" | "failed"
    // Reply clicked: open that chat now (the notification's action), hidden,
    // so sending is quick; the box takes the keyboard
    function startReply(n) {
        if (!canReply(n)) return;
        const d = defs.find(x => isFrom(x, n));
        const w = d ? mainOf(d) : null;
        const ic = Notifs.webAppIcon(n) || (d ? iconOf(d.entry) : "");
        session = { who: Notifs.titleOf(n), app: Notifs.appLabel(n),
                    icon: ic.includes("://") || ic.startsWith("/") ? ic : Quickshell.iconPath(ic, true),
                    key: d?.key ?? "", address: w?.address ?? "", notif: n.hasInlineReply ? n : null,
                    openedAt: Date.now() };
        sessionState = "";
        console.info("quick reply: box opened |", n.hasInlineReply ? "inline" : "paste into " + (d?.key ?? "?"), "| app", n.appName);
        if (!n.hasInlineReply) {
            const def = (n.actions ?? []).find(a => a.identifier === "default");
            if (def) def.invoke();
        }
    }
    function cancelReply() { session = null; sessionState = ""; }
    // While reply.sh pastes, the app's workspace shows for a moment: no dock
    property bool quiet: false
    Timer { id: quietTimer; interval: 1500; onTriggered: root.quiet = false }
    Timer { id: closeTimer; interval: 1200; onTriggered: root.cancelReply() }
    function sendReply(text) {
        const s = session;
        text = String(text ?? "").trim();
        if (!s || !text) return;
        if (s.notif) {
            console.info("quick reply: inline");
            try { s.notif.sendInlineReply(text); sessionState = "sent"; }
            catch (e) { sessionState = "failed"; }
            closeTimer.restart();
            return;
        }
        // The window may have changed since (closed, restarted): look it up again
        const d = defs.find(x => x.key === s.key);
        const w = d ? mainOf(d) : null;
        if (!w) { console.info("quick reply: no window for", s.key); sessionState = "failed"; return; }
        const waited = Date.now() - s.openedAt;
        console.info("quick reply: paste into", s.key, "| chat opened", waited, "ms ago");
        quiet = true;
        quietTimer.restart();
        sessionState = "sending";
        sendProc.command = [Quickshell.shellDir + "/scripts/reply.sh", w.address, text, waited > 700 ? "0.25" : "0.9"];
        sendProc.running = true;
    }
    Process {
        id: sendProc
        onExited: code => {
            root.sessionState = code === 0 ? "sent" : "failed";
            console.info("quick reply: reply.sh exited", code);
            if (code === 0) closeTimer.restart();
        }
    }

    // At login: open each one, hidden
    function startAll() {
        for (const d of defs) {
            const w = mainOf(d);
            if (w) moveIn(d, w, false); else launch(d, false);
        }
    }
    // An app taken out of the dock (Settings): its windows come back to the
    // current workspace instead of staying hidden
    onDefsChanged: releaseSoon.restart()
    Timer {
        id: releaseSoon
        interval: 300
        onTriggered: {
            const keys = root.defs.map(d => d.key);
            const ws = Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1;
            for (const c of root.clients) {
                const name = c.workspace.name;
                if (name.startsWith("special:comms-") && !keys.includes(name.slice("special:comms-".length)))
                    root.dispatch(`hl.dsp.window.move({ workspace = "${ws}", follow = false, window = "address:${c.address}" })`);
            }
        }
    }

    // Started apps: once their window shows up, into their workspace
    function settlePending() {
        const p = Object.assign({}, pending);
        let changed = false;
        for (const key in p) {
            const d = defs.find(x => x.key === key);
            const w = d ? mainOf(d) : null;
            if (w) { moveIn(d, w, p[key].show); delete p[key]; changed = true; }
            else if (!d || Date.now() - p[key].since > 90000) { delete p[key]; changed = true; }
        }
        if (changed) pending = p;
        if (Object.keys(p).length === 0) pendingTimer.stop();
    }
    // Polled while waiting: a window can take a while to get its final class
    Timer { id: pendingTimer; interval: 700; repeat: true; onTriggered: root.refresh() }

    // ---------------- Hyprland state ----------------
    Process {
        id: clientsProc
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.clients = JSON.parse(text); } catch (e) { return; }
                if (Object.keys(root.pending).length) root.settlePending();
            }
        }
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
