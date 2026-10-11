pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Internet radio for the Media tab's radio view (zones/MediaZone.qml).
// Stations: ~/.config/lagos/radio-stations, one per line (created with the
// defaults below if missing; # comments):
//   Name | stream URL | subtitle (frequency, city…) | logo URL (optional)
// Settings.v.radioStation is the default (the first one if it's gone).
// Playback: mpv (no video) with a JSON IPC socket; the panel observes its
// metadata for what's on air (the stream's ICY title) and its pause state.
// mpv-mpris makes it an MPRIS player too, so it also shows in the player view.
//   play(station) · stop() · toggle() · next() · previous()
Singleton {
    id: root

    readonly property string file: Quickshell.env("HOME") + "/.config/lagos/radio-stations"
    readonly property string socketPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/lagos-radio.sock"
    readonly property string defaults: "# Radio stations for the Quickshell panel (Media tab → radio).\n"
        + "# Name | stream URL | subtitle | logo URL (optional)\n"
        + "Radio BUAP | http://148.228.50.32:8000/ | 96.9 FM · Puebla | https://yt3.ggpht.com/ytc/AMLnZu-_phCfsAWCr_MADJ0UmQdybpjbikuNWCAxyysP=s300-c-k-c0x00ffffff-no-rj\n"

    property var stations: []                  // [{ name, url, subtitle, logo }]
    property var current: null                 // the one selected (playing or not)
    readonly property bool active: mpv.running            // started (connecting or playing)
    readonly property bool playing: mpv.running && !paused
    property bool paused: false
    property bool loading: false               // started, nothing heard from mpv yet
    property string onAir: ""                  // ICY title: the program / song
    property real startedAt: 0
    property real now: 0
    readonly property string elapsed: {
        if (!mpv.running) return "0:00";
        const s = Math.max(0, Math.floor((now - startedAt) / 1000));
        const h = Math.floor(s / 3600), m = Math.floor(s / 60) % 60;
        return (h ? h + ":" + String(m).padStart(2, "0") : String(m)) + ":" + String(s % 60).padStart(2, "0");
    }

    // Switching stations: the old mpv has to exit first, then `pending` starts
    property var pending: null
    function play(st) {
        if (!st) return;
        current = st;
        Settings.set("radioStation", st.name);
        if (mpv.running) { pending = st; stop(); return; }
        start(st);
    }
    function start(st) {
        onAir = "";
        loading = true;
        paused = false;
        mpv.command = ["mpv", "--no-video", "--no-terminal", "--idle=no", "--cache=yes",
                       "--input-ipc-server=" + socketPath, "--force-media-title=" + st.name, st.url];
        mpv.running = true;
        startedAt = Date.now();
        now = startedAt;
        connectTimer.restart();
    }
    function stop() {
        ipc.connected = false;
        if (mpv.running) mpv.signal(15);
        loading = false;
        onAir = "";
    }
    // Live radio: "pause" is stop (resuming a paused live stream lags behind)
    function toggle() { mpv.running ? stop() : play(current ?? stations[0]); }
    function step(d) {
        if (!stations.length) return;
        const i = Math.max(0, stations.findIndex(s => s.name === current?.name));
        play(stations[(i + d + stations.length) % stations.length]);
    }
    function next() { step(1); }
    function previous() { step(-1); }

    Process {
        id: mpv
        onExited: {
            root.loading = false;
            root.onAir = "";
            ipc.connected = false;
            if (root.pending) { const st = root.pending; root.pending = null; root.start(st); }
        }
    }

    // mpv's JSON IPC: watch the metadata (icy-title) and pause
    Socket {
        id: ipc
        path: root.socketPath
        onConnectedChanged: if (connected) {
            write('{"command":["observe_property",1,"metadata"]}\n{"command":["observe_property",2,"pause"]}\n');
            flush();
        }
        parser: SplitParser {
            onRead: line => {
                let m;
                try { m = JSON.parse(line); } catch (e) { return; }
                if (m.event !== "property-change") return;
                if (m.name === "metadata" && m.data) {
                    root.loading = false;
                    const t = m.data["icy-title"] ?? m.data["icy-name"] ?? m.data.title ?? "";
                    // Some stations repeat the title in parentheses: "X (X)"
                    root.onAir = String(t).replace(/^(.+?)\s*\(\1\)$/, "$1").trim();
                } else if (m.name === "pause") root.paused = !!m.data;
            }
        }
    }
    // The socket appears a moment after mpv starts
    Timer {
        id: connectTimer
        interval: 400
        repeat: true
        property int tries: 0
        onRunningChanged: if (running) tries = 0
        onTriggered: {
            if (ipc.connected || !mpv.running || ++tries > 25) { connectTimer.stop(); return; }
            ipc.connected = true;                 // retried until the socket exists
        }
    }
    Timer { interval: 1000; repeat: true; running: mpv.running; onTriggered: root.now = Date.now() }

    // ---------------- Station list ----------------
    FileView {
        id: list
        path: root.file
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoadFailed: setText(root.defaults)          // first run: write the defaults
        onLoaded: {
            const out = [];
            for (const raw of text().split("\n")) {
                const line = raw.trim();
                if (!line || line.startsWith("#")) continue;
                const f = line.split("|").map(s => s.trim());
                if (f.length < 2 || !f[1]) continue;
                out.push({ name: f[0] || "Radio", url: f[1], subtitle: f[2] ?? "", logo: f[3] ?? "" });
            }
            root.stations = out;
            if (!root.current || !out.some(s => s.name === root.current.name))
                root.current = out.find(s => s.name === Settings.v.radioStation) ?? out[0] ?? null;
        }
    }
}
