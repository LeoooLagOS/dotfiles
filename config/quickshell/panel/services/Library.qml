pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// The Hi-Res music library (Media → Library view): MPD playing ~/Music through
// PipeWire, read and driven by scripts/library.py over MPD's socket.
//   available / problem   MPD reachable, or why not ("mpd" = not installed or
//                         not running: the view shows how to start it)
//   albums                [{ artist, album, year, cover, quality, hires, tracks }]
//   now                   status: state, elapsed, duration, title, artist,
//                         album, cover, quality ("FLAC 24/96"), hires, rate,
//                         cardRate (the sound card's real rate), bitperfect…
//   play(album, track) · queue(album) · toggle() · next() · prev() · seek(s)
//   setRandom(on) · setRepeat(on) · rescan()
//   verify(album)         is each track really lossless? → verdicts[file]
//                         { verdict: ok|fake|lossy|upsampled|padded|error, cutoff (kHz) }
//   spectrum(file)        a track's spectrogram, in the image viewer
//   openImage(path)       a cover or booklet page, in the image viewer
// Status is read every second while `watching` (the Library view is on screen).
Singleton {
    id: root

    readonly property string script: Quickshell.shellDir + "/scripts/library.py"
    property bool watching: false
    property string problem: ""                // "" | "mpd" | other error text
    readonly property bool available: problem === "" && statusLoaded
    property bool statusLoaded: false
    property var albums: []
    property bool loadingAlbums: false
    property var now: ({ state: "stop", elapsed: 0, duration: 0 })
    readonly property bool playing: now.state === "play"
    readonly property bool active: now.state === "play" || now.state === "pause"
    readonly property real progress: now.duration > 0 ? now.elapsed / now.duration : 0

    function run(args) { Quickshell.execDetached(["python3", script].concat(args)); refreshSoon.restart(); }
    function play(album, track) { run(["play", album.artist, album.album, String(track ?? 0)]); }
    function queue(album) { run(["queue", album.artist, album.album]); }
    function toggle() { run(["toggle"]); }
    function next() { run(["next"]); }
    function prev() { run(["prev"]); }
    function seek(s) { run(["seek", String(Math.max(0, Math.floor(s)))]); }
    function setRandom(on) { run(["random", on ? "1" : "0"]); }
    function setRepeat(on) { run(["repeat", on ? "1" : "0"]); }
    function rescan() { run(["update"]); albumsSoon.restart(); }
    function loadAlbums() { if (!albumsProc.running) { loadingAlbums = true; albumsProc.running = true; } }
    function spectrum(file) { Quickshell.execDetached(["python3", script, "spectrum", file]); }
    function openImage(path) { Quickshell.execDetached(["xdg-open", path]); }

    // ---------------- Verify ----------------
    // Decodes a piece of every track (scripts/library.py verify): the first
    // time takes ~a second per track, then the results are cached.
    property var verdicts: ({})                // file → { verdict, cutoff, codec, rate, bits }
    property string verifying: ""              // "artist\nalbum" being checked
    property string verifyError: ""            // "numpy" = not installed
    function verify(album) {
        if (verifyProc.running) return;
        verifying = album.artist + "\n" + album.album;
        verifyError = "";
        verifyProc.command = ["python3", script, "verify", album.artist, album.album];
        verifyProc.running = true;
    }
    Process {
        id: verifyProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.verifying = "";
                let d;
                try { d = JSON.parse(text); } catch (e) { root.verifyError = "failed"; return; }
                if (d.error) { root.verifyError = d.error; return; }
                const v = Object.assign({}, root.verdicts);
                for (const t of d) v[t.file] = t;
                root.verdicts = v;
            }
        }
    }

    Process {
        id: statusProc
        command: ["python3", root.script, "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let d;
                try { d = JSON.parse(text); } catch (e) { root.problem = "The library helper failed"; return; }
                if (d.error) { root.problem = d.error === "mpd" ? "mpd" : d.detail; return; }
                root.problem = "";
                root.statusLoaded = true;
                root.now = d;
            }
        }
    }
    Process {
        id: albumsProc
        command: ["python3", root.script, "albums"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loadingAlbums = false;
                try {
                    const d = JSON.parse(text);
                    if (Array.isArray(d)) root.albums = d;
                } catch (e) {}
            }
        }
    }
    function refresh() { if (!statusProc.running) statusProc.running = true; }
    Timer { interval: 1000; repeat: true; running: root.watching; triggeredOnStart: true; onTriggered: root.refresh() }
    Timer { id: refreshSoon; interval: 250; onTriggered: root.refresh() }
    // A rescan takes a moment: reload the albums after it
    Timer { id: albumsSoon; interval: 3000; onTriggered: root.loadAlbums() }
    onWatchingChanged: if (watching && albums.length === 0) loadAlbums()

    // Elapsed time between status reads, so the bar moves smoothly
    Timer {
        interval: 250; repeat: true
        running: root.watching && root.playing
        onTriggered: { const n = Object.assign({}, root.now); n.elapsed = Math.min(n.duration || 1e9, n.elapsed + 0.25); root.now = n; }
    }
}
