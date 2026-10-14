pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

// What starts at login (scripts/startup.py): XDG autostart entries (uwsm runs
// them as app-<id>@autostart.service) and the commands of Hyprland's
// UserConfigs/user_startup.lua. Shown in the tray's Startup view and in
// Settings → Startup apps; read while one of them is open (`watching`) and
// after each change.
//   apps            [{ id, kind (xdg | hypr), name, comment, icon, exec, enabled,
//                      locked, state (running | exited | failed | skipped | stopped), memory }]
//   setEnabled(a, on)   at login or not (from the next login)
//   start(a) / stop(a)  now
//   open(a)         its tray icon's window, its window, or start it
//   iconOf(a), stateText(a)
Singleton {
    id: root

    property var apps: []
    // Running, once each: the same program can be in both places (xwaylandvideobridge),
    // and a commented-out Hyprland line can name one started some other way
    readonly property var running: apps.filter((a, i) => a.state === "running" && (a.kind === "xdg" || a.enabled)
        && !apps.slice(0, i).some(b => b.state === "running" && norm(b.name) === norm(a.name)))
    readonly property real memory: running.reduce((s, a) => s + a.memory, 0)
    property bool trayWatching: false
    readonly property bool watching: trayWatching
        || (PanelState.open && PanelState.controlsView === "settings" && PanelState.settingsSection === "startup")
    property string busy: ""                    // id being changed
    property string error: ""

    readonly property string script: Quickshell.shellDir + "/scripts/startup.py"
    function refresh() { if (!list.running) list.running = true; }
    function run(a, args) {
        busy = a.id;
        error = "";
        action.command = [script].concat(args);
        action.running = true;
    }
    function setEnabled(a, on) { if (!a.locked) run(a, ["set", a.id, on ? "on" : "off"]); }
    function start(a) { run(a, ["start", a.id]); }
    function stop(a) { run(a, ["stop", a.id]); }

    // ---------------- Finding its icon and window ----------------
    function norm(s) { return String(s ?? "").toLowerCase().replace(/[^a-z0-9]/g, ""); }
    function same(x, y) { return x.length > 2 && y.length > 2 && (x.includes(y) || y.includes(x)); }
    function keys(a) {
        const e = entryOf(a);
        return [norm(a.id.replace(/^hypr:/, "")), norm(a.name), norm(e?.id), norm(e?.name)].filter(k => k.length > 2);
    }
    // Its launcher in the app menu (the autostart file usually has a twin there)
    function entryOf(a) {
        return a.kind === "xdg" ? DesktopEntries.byId(a.id) ?? DesktopEntries.heuristicLookup(a.id)
                                : DesktopEntries.heuristicLookup(a.name);
    }
    function trayItemOf(a) {
        const k = keys(a);
        return SystemTray.items.values.find(it => [norm(it.id), norm(it.title), norm(it.tooltipTitle)]
            .some(t => k.some(x => same(t, x)))) ?? null;
    }
    function windowOf(a) {
        const k = keys(a);
        return Hyprland.toplevels.values.find(t => {
            const c = norm(t.wayland?.appId ?? t.lastIpcObject?.class);
            return k.some(x => same(c, x));
        }) ?? null;
    }
    // Whether clicking it shows something
    function openable(a) { return a.state !== "running" || !!trayItemOf(a) || !!windowOf(a) || !!entryOf(a); }
    function open(a) {
        const it = trayItemOf(a), w = windowOf(a), e = entryOf(a);
        if (a.state === "running" && it && !it.onlyMenu) it.activate();
        else if (a.state === "running" && w) Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:0x${w.address}" })`]);
        else if (a.state === "running" && e) e.execute();          // single-instance apps show their window
        else if (a.state !== "running") start(a);
    }

    function iconOf(a) {
        const name = a.icon || entryOf(a)?.icon || "";
        return name ? Quickshell.iconPath(name, true) : "";
    }
    function size(b) {
        return b >= 1073741824 ? (b / 1073741824).toFixed(1) + " GB" : Math.max(1, Math.round(b / 1048576)) + " MB";
    }
    function stateText(a) {
        const s = a.state === "running" ? "Running" + (a.memory > 0 ? " · " + size(a.memory) : "")
                : a.state === "exited" ? "Ran at login and finished"
                : a.state === "failed" ? "Failed at login"
                : a.state === "skipped" ? "Skipped (not for this desktop)"
                : "Not running";
        return a.enabled ? s : "Off at login · " + s.charAt(0).toLowerCase() + s.slice(1);
    }

    Process {
        id: list
        command: [root.script, "list"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.apps = JSON.parse(text); } catch (e) {} }
        }
    }
    Process {
        id: action
        stderr: StdioCollector { id: actionErr }
        onExited: code => {
            root.error = code === 0 ? "" : (actionErr.text.trim().split("\n").pop() || "startup.py failed");
            root.busy = "";
            refreshSoon.restart();
        }
    }
    // Starting and stopping take a moment to show
    Timer { id: refreshSoon; interval: 800; onTriggered: root.refresh() }
    Timer { interval: 4000; repeat: true; running: root.watching; triggeredOnStart: true; onTriggered: root.refresh() }
}
