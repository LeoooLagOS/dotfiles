pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// A video call going on (the bar's right twin shows it, bar/Glance.qml): a
// window of a known call app, by its title. Its microphone and camera are
// switched with the app's own shortcuts sent to its window (Meet: Ctrl+D /
// Ctrl+E · Teams: Ctrl+Shift+M / Ctrl+Shift+O), so the call shows the same.
// Their state (scripts/call.py, every 1.5 s): the app's own buttons through
// accessibility when it's on (exact, also when switched in the call);
// without it the camera from the device being open, and the microphone as
// last switched from the bar (a mute done inside the call isn't seen).
//   active · name ("Meet") · detail ("kai-rxpp-mqx") · micMuted · micKnown ·
//   camOn · exact (read from the app) · toggleMic() · toggleCam() · show()
Singleton {
    id: root

    readonly property var apps: [
        { name: "Meet", re: /Meet\s*[-–]\s*([a-z]{3}-[a-z]{4}-[a-z]{3})/i,
          mic: { mods: "CTRL", key: "d" }, cam: { mods: "CTRL", key: "e" } },
        { name: "Teams", re: /^(?:.*\b(?:Meeting|Call|Llamada|Reunión)\b[^|]*)\|\s*Microsoft Teams/i,
          mic: { mods: "CTRL SHIFT", key: "m" }, cam: { mods: "CTRL SHIFT", key: "o" } }
    ]
    readonly property var found: {
        for (const t of Hyprland.toplevels.values) {
            const title = String(t.title ?? "");
            for (const a of apps) {
                const m = a.re.exec(title);
                if (m) return { win: t, app: a, detail: m[1] ?? "" };
            }
        }
        return null;
    }
    readonly property bool active: !!found
    // Where the bar shows it: the left twin (more room), unless something
    // urgent has it (Events.soon) — then the right one (bar/Glance.qml)
    readonly property bool onLeft: active && !Events.soon
    readonly property string name: found?.app.name ?? ""
    readonly property string detail: found?.detail ?? ""
    readonly property string address: found ? "0x" + found.win.address : ""
    readonly property string title: String(found?.win?.title ?? "")
    // The program the call runs in ("brave", "teams-for-linux"): from its
    // window's PID (Comms keeps `hyprctl clients`)
    readonly property int pid: Number(Comms.clients.find(c => c.address === address)?.pid ?? 0)
    property string binary: ""
    Component.onCompleted: if (pid) pidChanged()
    onPidChanged: {
        binary = "";
        binProc.running = false;
        if (!pid) return;
        binProc.command = ["cat", "/proc/" + pid + "/comm"];
        binProc.running = true;
    }
    onActiveChanged: { if (active) { micAssumedMuted = false; Comms.refresh(); } }
    Process {
        id: binProc
        stdout: StdioCollector { onStreamFinished: if (text.trim()) root.binary = text.trim() }
    }

    property string micState: "unknown"              // "live" | "muted" | "none" (not recording) | "unknown"
    property bool micAssumedMuted: false              // without accessibility: as last switched from here
    property bool camOn: false
    property bool exact: false
    readonly property bool micKnown: micState !== "none"
    readonly property bool micMuted: micState === "muted" || (micState === "unknown" && micAssumedMuted)
    function poll() { if (binary && !stateProc.running) stateProc.running = true; }
    Process {
        id: stateProc
        command: ["python3", Quickshell.shellDir + "/scripts/call.py", "state", root.binary, root.detail || root.title]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.micState = d.mic; root.camOn = d.cam; root.exact = d.source === "a11y";
                } catch (e) {}
            }
        }
    }
    Timer { interval: 1500; repeat: true; running: root.active && root.binary !== ""; triggeredOnStart: true; onTriggered: root.poll() }
    // The app needs a moment to open / close the camera
    Timer { id: pollSoon; interval: 1200; onTriggered: root.poll() }

    function send(c) {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.send_shortcut({ mods = "${c.mods}", key = "${c.key}", window = "address:${address}" })`]);
        pollSoon.restart();
    }
    function toggleMic() {
        if (!found) return;
        if (micState === "unknown") micAssumedMuted = !micAssumedMuted;
        else if (micState !== "none") micState = micState === "muted" ? "live" : "muted";   // right away; the poll confirms
        send(found.app.mic);
    }
    function toggleCam() {
        if (!found) return;
        camOn = !camOn;                                   // right away; the poll confirms
        send(found.app.cam);
    }
    // To the call's window (its comms app or its workspace)
    function show() {
        if (address) Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:${address}" })`]);
    }
}
