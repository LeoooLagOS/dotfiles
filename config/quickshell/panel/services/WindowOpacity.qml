pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// SUPER CTRL O (shell.qml: GlobalShortcut quickshell:windowOpacity): the
// focused window's opacity round 100 → 85 → 70 → 50 %, and its level shown by
// the panel itself on the same frame (Notifs.showLevel; where: Settings →
// Notifications → Where popups appear → Window opacity). It replaces KoolDots'
// ToggleOpacity.sh, whose notification only came after a dozen hyprctl / jq /
// awk calls and a D-Bus round trip.
// SUPER CTRL + wheel (windowOpacityUp / Down): ±2 %, without moving the
// pointer off the window (with follow_mouse, reaching for the level's popup
// moves the focus to whatever window the pointer crosses).
// The level's bar can also be dragged (or the wheel turned on it) for an exact
// value, 20–100 % (Notifs.setLevel → set()). The key goes on from there.
// What each window was set to is remembered here; one never set counts as 100 %
// (its window rule's opacity, e.g. 90 % for terminals, isn't read back)
Singleton {
    id: root

    readonly property var steps: [100, 85, 70, 50]
    readonly property int min: 20
    property var levels: ({})                 // window address → %

    function cycle() {
        const w = Hyprland.activeToplevel;
        if (!w) return;
        const addr = "0x" + w.address;
        // The next step down (from a dragged 77 %: 70), after the last one 100 %
        const cur = levels[addr] ?? 100;
        const next = cur <= steps[steps.length - 1] ? 100 : steps.find(s => s < cur);
        set(addr, next, false);
        show(w, addr, next);
    }
    function step(delta) {
        const w = Hyprland.activeToplevel;
        if (!w) return;
        const addr = "0x" + w.address;
        const pct = Math.max(min, Math.min(100, (levels[addr] ?? 100) + delta));
        set(addr, pct, true);
        show(w, addr, pct);
    }
    function show(w, addr, pct) {
        const cls = w.lastIpcObject?.class ?? w.wayland?.appId ?? "";
        Notifs.showLevel("opacity_notif", Tr.t("Window opacity"), pct, DesktopEntries.heuristicLookup(cls)?.name ?? cls,
                         { min: min, max: 100, set: p => root.set(addr, p, true) });
    }

    // live: a drag or the wheel, many values in a row: the window follows them
    // at once instead of fading to each (Hyprland's fadeSwitch is off meanwhile)
    function set(addr, pct, live) {
        const l = Object.assign({}, levels);
        l[addr] = pct;
        levels = l;
        if (live) quick();
        pending = { addr: addr, pct: pct };
        if (!applyTimer.running) applyTimer.start();
    }
    // Straight to Hyprland's socket (no process), at most once a frame, the latest value
    property var pending: null
    Timer {
        id: applyTimer
        interval: 16
        onTriggered: {
            const p = root.pending;
            if (!p) return;
            root.pending = null;
            const v = (p.pct / 100).toFixed(2), win = `window = 'address:${p.addr}'`;
            Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = 'opacity', value = '${v} ${v}', ${win} })`);
            // 100 %: opaque, over the window rule's own opacity too
            Hyprland.dispatch(`hl.dsp.window.set_prop({ prop = 'opaque', value = '${p.pct === 100}', ${win} })`);
        }
    }

    // ---------------- No fading while it's being set ----------------
    // fadeSwitch (also the focus change's fade) goes off, and comes back as it
    // was 0.8 s after the last change: its own values, else the ones it
    // inherits (fade, then global), read from Hyprland
    property bool quickOn: false
    property string restoreExpr: ""
    function quick() {
        quickEnd.restart();
        if (quickOn) return;
        quickOn = true;
        Quickshell.execDetached(["hyprctl", "eval", 'hl.animation({ leaf = "fadeSwitch", enabled = false })']);
    }
    Timer {
        id: quickEnd
        interval: 800
        onTriggered: {
            root.quickOn = false;
            if (root.restoreExpr) Quickshell.execDetached(["hyprctl", "eval", root.restoreExpr]);
        }
    }
    Process {
        id: animProc
        command: ["hyprctl", "animations", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let all;
                try { all = JSON.parse(text)[0]; } catch (e) { return; }
                const by = n => all.find(a => a.name === n);
                const a = ["fadeSwitch", "fade", "global"].map(by).find(x => x?.overridden);
                if (!a) return;
                root.restoreExpr = a.enabled
                    ? `hl.animation({ leaf = "fadeSwitch", enabled = true, speed = ${a.speed}, bezier = "${a.bezier}" })`
                    : 'hl.animation({ leaf = "fadeSwitch", enabled = false })';
            }
        }
    }
    // Read again when Hyprland reloads its config (not while it's off: that's ours)
    function readAnimations() { if (!quickOn && !animProc.running) animProc.running = true; }
    Component.onCompleted: readAnimations()
    // A panel reload in the middle: the fade back anyway
    Component.onDestruction: if (quickOn && restoreExpr) Quickshell.execDetached(["hyprctl", "eval", restoreExpr])
    Connections {
        target: Hyprland
        function onRawEvent(event) { if (event.name === "configreloaded") root.readAnimations(); }
    }
}
