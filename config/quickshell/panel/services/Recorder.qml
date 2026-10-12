pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"

// Screen recording with gpu-screen-recorder (hardware encoding, almost no CPU).
//   start()   records what Settings.v.recTarget says: "screen" (the focused
//             monitor) or "region" (picked with slurp); audio per recAudio:
//             "none" · "system" · "both" (system + microphone, one track)
//   stop()    SIGINT: gpu-screen-recorder finishes the file and exits
// Files: ~/Recordings/Screen_<date>.mp4 (Config.recordingsDir). The panel closes on start so
// it isn't recorded; the Controls tile shows the elapsed time.
// IPC: `qs -c panel ipc call panel record` (start / stop).
Singleton {
    id: root

    readonly property bool installed: whichProc.found
    readonly property bool recording: proc.running
    readonly property string dir: Config.recordingsDir
    property string file: ""
    property string lastFile: ""
    property string error: ""
    property real startedAt: 0
    property real now: 0
    readonly property string elapsed: {
        const s = Math.max(0, Math.floor((now - startedAt) / 1000));
        const h = Math.floor(s / 3600), m = Math.floor(s / 60) % 60, sec = s % 60;
        return (h ? h + ":" + String(m).padStart(2, "0") : String(m)) + ":" + String(sec).padStart(2, "0");
    }

    function toggle() { recording ? stop() : start(); }
    function stop() { if (proc.running) proc.signal(2); }   // SIGINT
    function start() {
        if (recording) return;
        if (!installed) { checkInstalled(); return; }
        const stamp = Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss");   // local time
        file = dir + "/Screen_" + stamp + ".mp4";
        error = "";
        const audio = Settings.v.recAudio === "both" ? ["-a", "default_output|default_input"]
                    : Settings.v.recAudio === "system" ? ["-a", "default_output"] : [];
        // H.264 + AAC: what phones, WhatsApp, Telegram… accept (the default audio,
        // Opus in MP4, made WhatsApp hang on "loading")
        const base = ["gpu-screen-recorder", "-f", String(Settings.v.recFps), "-c", "mp4", "-k", "h264", "-ac", "aac",
                      "-q", "very_high", "-cursor", "yes", ...audio, "-o", file];
        const monitor = Hyprland.focusedMonitor?.name ?? "screen";
        // Region: pick it first; exec so the SIGINT reaches gpu-screen-recorder
        const q = a => "'" + a.replace(/'/g, "'\\''") + "'";
        const script = `mkdir -p ${q(dir)}; `
            + (Settings.v.recTarget === "region"
               ? `g=$(slurp -f '%wx%h+%x+%y') || exit 130; exec ${base.map(q).join(" ")} -w region -region "$g"`
               : `exec ${base.map(q).join(" ")} -w ${q(monitor)}`);
        PanelState.open = false;
        proc.command = ["bash", "-c", script];
        proc.running = true;
        startedAt = Date.now();
        now = startedAt;
    }

    Process {
        id: proc
        stderr: StdioCollector { id: err }
        // 130: picking the region was cancelled. Otherwise the file decides:
        // stopping with SIGINT doesn't always exit with 0
        onExited: code => { if (code !== 130) check.running = true; }
    }
    Process {
        id: check
        command: ["test", "-s", root.file]
        onExited: code => {
            if (code === 0) {
                root.lastFile = root.file;
                Quickshell.execDetached(["notify-send", "-a", "Screen recording", "-i", "video-x-generic",
                                         "Recording saved", root.file.replace(Quickshell.env("HOME"), "~")]);
            } else {
                root.error = err.text.trim().split("\n").pop() || "gpu-screen-recorder didn't write the file";
                Quickshell.execDetached(["notify-send", "-a", "Screen recording", "Recording failed", root.error]);
            }
        }
    }
    Timer { interval: 1000; repeat: true; running: root.recording; onTriggered: root.now = Date.now() }

    function openFolder() {
        PanelState.open = false;
        Quickshell.execDetached(["bash", "-c", `mkdir -p "$1"; xdg-open "$1"`, "_", dir]);
    }

    // Is gpu-screen-recorder installed? (at start, and again before recording
    // or when the detail opens, so installing it doesn't need a restart)
    function checkInstalled() { if (!whichProc.running) whichProc.running = true; }
    Process {
        id: whichProc
        property bool found: false
        running: true
        command: ["bash", "-c", "command -v gpu-screen-recorder"]
        onExited: code => found = code === 0
    }
}
