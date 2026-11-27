pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// Modes (vault ADR-0016): what the desktop is for right now. A mode is a data
// file: which notifications get through, which apps the comms dock shows,
// caffeine / night light / dark theme / game mode, apps to open, a timer or
// Pomodoro. Built in: panel/modes/*.json; yours: ~/.config/lagos/modes/*.json
// (one with a built-in's id replaces it). The switches a mode sets come back
// when it ends.
//   modes · current · isPersonal · timerText
//   set(id, what)       what: "" (until turned off) | "1h" | "tomorrow"
//   end()               back to Personal
//   silences(n)         a notification the mode keeps quiet (services/Notifs.qml)
//   commsAllows(def)    an app the comms dock shows (services/Comms.qml)
//   save(m) · remove(id) · exportMode(id) · importFile(path) · refresh()
Singleton {
    id: root
    readonly property string builtinDir: Quickshell.shellDir + "/modes"
    readonly property string userDir: Quickshell.env("HOME") + "/.config/lagos/modes"
    readonly property string statePath: Quickshell.env("HOME") + "/.config/lagos/mode-state.json"

    property var builtins: []
    property var mine: []
    // Yours replace a built-in with the same id; ordered by `order`, then name
    readonly property var modes: {
        const by = {};
        for (const m of builtins) by[m.id] = Object.assign({ builtin: true }, m);
        for (const m of mine) by[m.id] = Object.assign({ builtin: !!by[m.id], custom: true }, m);
        return Object.values(by).sort((a, b) => (a.order ?? 99) - (b.order ?? 99) || String(a.name).localeCompare(String(b.name)));
    }
    function byId(id) { return modes.find(m => m.id === id) ?? null; }
    function isBuiltin(id) { return builtins.some(m => m.id === id); }
    function isCustom(id) { return mine.some(m => m.id === id); }
    function nameOf(m) { return m ? (m.builtin ? Tr.t(m.name) : m.name) : ""; }

    // ---------------- State (survives panel restarts) ----------------
    property string currentId: "personal"
    property var until: null                    // ms since epoch, or null
    property var restore: ({})                  // { caffeine, night, dark, game } as they were before
    property var pomo: null                     // { phase: "work" | "break" | "long", endsAt, done }
    property bool stateRead: false
    readonly property var current: byId(currentId) ?? byId("personal")
    readonly property bool isPersonal: !current || current.id === "personal"
    readonly property string icon: current?.icon ?? ""

    function writeState() {
        stateFile.setText(JSON.stringify({ id: currentId, until: until, restore: restore, pomo: pomo }, null, 2));
    }
    FileView {
        id: stateFile
        path: root.statePath
        atomicWrites: true
        printErrors: false
        onLoaded: {
            try {
                const s = JSON.parse(text());
                root.currentId = s.id || "personal";
                root.until = s.until ?? null;
                root.restore = s.restore ?? {};
                root.pomo = s.pomo ?? null;
            } catch (e) {}
            root.stateRead = true;
            root.tick();
            root.reapply();
        }
        onLoadFailed: root.stateRead = true
    }
    // After a panel restart the mode is still on, but caffeine (a process of
    // the panel's) isn't: its switches again, once both the state and the
    // modes are read
    property bool reapplied: false
    function reapply() {
        if (reapplied || !stateRead || !builtins.length || isPersonal) return;
        reapplied = true;
        for (const k of switches) if (typeof current[k] === "boolean") setSwitch(k, current[k]);
    }

    // ---------------- Files ----------------
    Process {
        id: loader
        command: ["bash", "-c", `shopt -s nullglob
            printf '{"builtin":'; for f in "$1"/*.json; do jq -c . "$f" 2>/dev/null; done | jq -s .
            printf ',"user":'; for f in "$2"/*.json; do jq -c . "$f" 2>/dev/null; done | jq -s .
            printf '}'`, "_", root.builtinDir, root.userDir]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const ok = m => m && typeof m.id === "string" && /^[a-z0-9-]+$/.test(m.id);
                    root.builtins = d.builtin.filter(ok);
                    root.mine = d.user.filter(ok);
                    root.reapply();
                } catch (e) { console.warn("modes:", e); }
            }
        }
    }
    function refresh() { if (!loader.running) loader.running = true; else reloadSoon.restart(); }
    Timer { id: reloadSoon; interval: 300; onTriggered: root.refresh() }
    Component.onCompleted: refresh()

    // One command at a time, then the list again
    property var queue: []
    function run(args) { queue = queue.concat([args]); if (!writer.running) next(); }
    function next() {
        if (!queue.length) { refresh(); return; }
        writer.command = queue[0];
        queue = queue.slice(1);
        writer.running = true;
    }
    Process { id: writer; onExited: root.next() }

    function slug(s) { return String(s).toLowerCase().normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "") || "mode"; }
    function clean(m) {
        const o = Object.assign({}, m);
        delete o.builtin; delete o.custom;
        return o;
    }
    function save(m) {
        run(["bash", "-c", 'mkdir -p "$1" && printf "%s\\n" "$2" > "$1/$3.json"', "_", userDir, JSON.stringify(clean(m), null, 2), m.id]);
    }
    // A new mode: a copy of `from` (or Personal) with a free id
    function duplicate(from, name) {
        const src = clean(byId(from) ?? byId("personal") ?? {});
        let id = slug(name), n = 2;
        while (byId(id)) id = slug(name) + "-" + n++;
        const m = Object.assign({}, src, { id: id, name: name, order: 50 });
        mine = mine.concat([m]);                // shown at once; the file follows
        save(m);
        return id;
    }
    // Yours: deleted. A built-in you changed: back to how it ships
    function remove(id) {
        if (currentId === id && !isBuiltin(id)) end();
        mine = mine.filter(m => m.id !== id);
        run(["rm", "-f", userDir + "/" + id + ".json"]);
    }
    readonly property string downloads: Quickshell.env("HOME") + "/Downloads"
    function exportMode(id) {
        const m = byId(id);
        if (!m) return;
        run(["bash", "-c", 'mkdir -p "$1" && printf "%s\\n" "$2" > "$1/$3.lagos-mode.json"', "_", downloads, JSON.stringify(clean(m), null, 2), id]);
        BarState.say("", Tr.t("Saved in Downloads: %1", id + ".lagos-mode.json"));
    }
    // Mode files waiting in ~/Downloads, for Import
    property var importable: []
    Process {
        id: finder
        command: ["bash", "-c", 'shopt -s nullglob; for f in "$1"/*.lagos-mode.json; do printf "%s\\n" "$f"; done', "_", root.downloads]
        stdout: StdioCollector { onStreamFinished: root.importable = text.split("\n").filter(l => l) }
    }
    function findImportable() { if (!finder.running) finder.running = true; }
    function importFile(path) {
        run(["bash", "-c", 'm=$(jq -c "select(.id | test(\\"^[a-z0-9-]+$\\"))" "$2") && [ -n "$m" ] && mkdir -p "$1" && id=$(jq -r .id <<<"$m") && jq . <<<"$m" > "$1/$id.json"', "_", userDir, path]);
    }

    // ---------------- Entering and leaving ----------------
    readonly property var switches: ["caffeine", "night", "dark", "game"]
    function now(key) {
        return key === "caffeine" ? Toggles.caffeine : key === "night" ? Toggles.night
             : key === "dark" ? !Theme.systemLight : Toggles.game;
    }
    function setSwitch(key, on) {
        if (now(key) === on) return;
        if (key === "caffeine") Toggles.setCaffeine(on, 0);
        else if (key === "night") Toggles.toggleNight();
        else if (key === "game") Toggles.toggleGame();
        else if (key === "dark") Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/SystemMode.sh",
                                                           on ? "Dark" : "Light"]);
    }
    function untilOf(what) {
        const d = new Date();
        if (what === "1h") return d.getTime() + 3600000;
        if (what === "tomorrow") { d.setDate(d.getDate() + 1); d.setHours(7, 0, 0, 0); return d.getTime(); }
        return null;
    }
    function set(id, what) {
        const m = byId(id);
        if (!m) return;
        // Leaving: the switches back as they were
        for (const k in restore) setSwitch(k, restore[k]);
        restore = {};
        pomo = null;
        currentId = m.id;
        until = untilOf(what ?? "");
        if (m.id !== "personal") {
            const r = {};
            for (const k of switches) if (typeof m[k] === "boolean") { r[k] = now(k); setSwitch(k, m[k]); }
            restore = r;
            const p = m.timer?.pomodoro;
            if (p) pomo = { phase: "work", endsAt: Date.now() + (p.work || 25) * 60000, done: 0 };
            else if (!until && m.timer?.minutes) until = Date.now() + m.timer.minutes * 60000;
            for (const app of m.open ?? []) openApp(app);
        }
        writeState();
        BarState.say(m.icon, m.id === "personal" ? Tr.t("Mode: Personal") : Tr.t("Mode: %1", nameOf(m)));
    }
    function end() { set("personal", ""); }
    function openApp(id) {
        const e = DesktopEntries.byId(id) ?? DesktopEntries.heuristicLookup(id);
        if (!e) return;
        const word = String(id).split(".").pop().toLowerCase();
        const running = Hyprland.toplevels.values.some(t => String(t.wayland?.appId ?? t.lastIpcObject?.class ?? "").toLowerCase().includes(word));
        if (!running) e.execute();
    }

    // ---------------- Timer and Pomodoro ----------------
    property real nowMs: Date.now()
    Timer {
        interval: 1000
        repeat: true
        running: root.stateRead && (root.until !== null || root.pomo !== null)
        onTriggered: root.tick()
    }
    function tick() {
        nowMs = Date.now();
        if (until !== null && nowMs >= until) { end(); return; }
        const p = current?.timer?.pomodoro;
        if (pomo && p && nowMs >= pomo.endsAt) {
            let next;
            if (pomo.phase === "work") {
                const done = pomo.done + 1;
                const long = done % (p.every || 4) === 0;
                next = { phase: long ? "long" : "break", endsAt: nowMs + (long ? p.long || 15 : p.break || 5) * 60000, done: done };
                BarState.say("", long ? Tr.t("Long break: %1 min", p.long || 15) : Tr.t("Break: %1 min", p.break || 5));
            } else {
                next = { phase: "work", endsAt: nowMs + (p.work || 25) * 60000, done: pomo.done };
                BarState.say("", Tr.t("Focus: %1 min", p.work || 25));
            }
            pomo = next;
            writeState();
        }
    }
    function clock(ms) {
        const s = Math.max(0, Math.round(ms / 1000));
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), ss = s % 60;
        return h ? h + ":" + String(m).padStart(2, "0") + " h" : String(m).padStart(2, "0") + ":" + String(ss).padStart(2, "0");
    }
    // What the island shows next to the clock: Pomodoro's phase and time left,
    // or how long the mode has left
    readonly property string timerText: pomo ? clock(pomo.endsAt - nowMs)
        : until !== null ? clock(until - nowMs) : ""
    readonly property string timerIcon: pomo ? (pomo.phase === "work" ? "" : "") : until !== null ? icon : ""
    readonly property string untilText: until === null ? ""
        : Tr.t(new Date(until).getDate() !== new Date().getDate() ? "Until %1 tomorrow" : "Until %1", Qt.formatTime(new Date(until), "HH:mm"))

    // ---------------- What a mode lets through ----------------
    // Always: system notices (the battery, the recording, Hyprland's: layouts…)
    readonly property var alwaysApps: ["battery", "screen recording", "hyprland"]
    function words(list) { return (list ?? []).map(w => String(w).toLowerCase().trim()).filter(w => w); }
    function silences(n) {
        const rule = current?.notifications;
        if (isPersonal || !rule || rule.allow === "all") return false;
        const app = ((n?.appName || "") + " " + (n?.desktopEntry || "")).toLowerCase();
        if (alwaysApps.some(a => app.includes(a))) return false;
        if (rule.allow === "none") return true;
        const who = String(n?.summary || "").toLowerCase();
        return !(words(rule.apps).some(w => app.includes(w)) || words(rule.people).some(w => who.includes(w)));
    }
    function commsAllows(def) {
        const list = current?.comms;
        if (isPersonal || list === null || list === undefined) return true;
        const hay = (String(def.ref) + " " + String(def.name)).toLowerCase();
        return words(list).some(w => hay.includes(w));
    }
}
