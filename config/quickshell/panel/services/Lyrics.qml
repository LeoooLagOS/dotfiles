pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Lyrics for the song in the Media tab (player and library views), from
// scripts/lyrics.py: the file's own (.lrc / tag) or LRCLIB. MediaZone sets
// `track` (artist, title, album, duration, file) and `position` while the
// lyrics are on screen; `index` is the line being sung (synced lyrics).
//   status    "" | "loading" | "found" | "none" | "instrumental" | "offline"
//   lines     [{ t: seconds (-1 when not synced), text }]
Singleton {
    id: root

    readonly property string script: Quickshell.shellDir + "/scripts/lyrics.py"
    property bool wanted: false
    property var track: null                   // { artist, title, album, duration, file }
    property real position: 0

    property string status: ""
    property var lines: []
    property bool synced: false
    property string source: ""
    readonly property int index: {
        if (!synced) return -1;
        // A hair early, so the line lights up as it starts
        const p = position + 0.25;
        let i = -1;
        for (let k = 0; k < lines.length && lines[k].t <= p; k++) i = k;
        return i;
    }

    readonly property string key: track ? [track.artist, track.title, track.album, Math.round(track.duration || 0), track.file ?? ""].join("|") : ""
    property string loadedKey: ""
    function load() {
        if (!wanted || !track || !track.title || key === loadedKey) return;
        loadedKey = key;
        status = "loading";
        lines = [];
        synced = false;
        proc.running = false;
        proc.command = ["python3", script, track.artist ?? "", track.title, track.album ?? "",
                        String(track.duration || 0), track.file ?? ""];
        proc.running = true;
    }
    // A new song: wait a moment (skipping through tracks shouldn't query each one)
    onKeyChanged: if (wanted) loadSoon.restart()
    onWantedChanged: if (wanted) load()
    Timer { id: loadSoon; interval: 400; onTriggered: root.load() }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                let d;
                try { d = JSON.parse(text); } catch (e) { root.status = "offline"; root.loadedKey = ""; return; }
                if (d.error) { root.status = "offline"; root.loadedKey = ""; return; }   // tried again later
                if (d.none) { root.status = "none"; return; }
                if (d.instrumental) { root.status = "instrumental"; return; }
                root.lines = d.lines;
                root.synced = d.synced;
                root.source = d.source;
                root.status = "found";
            }
        }
    }
    function retry() { loadedKey = ""; load(); }
}
