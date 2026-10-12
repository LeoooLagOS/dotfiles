pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

// Shared MPRIS state for the media zones: the list of players and the one
// being shown (the one picked by the user, else one that is playing, else the first).
Singleton {
    id: root
    // playerctld is a proxy that mirrors the active player: skip it (it showed up as a duplicate)
    readonly property var players: Mpris.players.values.filter(p => !(p.dbusName ?? "").includes("playerctld"))
    property var picked: null

    readonly property var player: {
        if (picked && players.includes(picked)) return picked;
        return players.find(p => p.isPlaying) ?? players[0] ?? null;
    }

    function pick(p) { picked = p; }

    // None → whole playlist → current track → None
    function cycleLoop() {
        if (!player) return;
        player.loopState = player.loopState === MprisLoopState.None ? MprisLoopState.Playlist
                         : player.loopState === MprisLoopState.Playlist ? MprisLoopState.Track
                         : MprisLoopState.None;
    }

    // --- Audio outputs (PipeWire sinks), for the output picker ---
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    // "Alder Lake PCH-P High Definition Audio Controller Speaker" → "Speaker":
    // drop the sound card's name, which is the same for all its outputs
    function sinkName(n) {
        if (!n) return "";
        const d = n.description || n.nickname || n.name;
        const i = d.indexOf(" Controller ");
        return i >= 0 ? d.slice(i + " Controller ".length) : d;
    }
    function setSink(n) { Pipewire.preferredDefaultAudioSink = n; }

    // --- App volume: the PipeWire playback streams of a player ---
    // (their properties, and volume, are only there while tracked)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream)
    // Streams whose app name, binary, node name or Flatpak id has one of `keys`
    // as a word: "spotify" → com.spotify.Client, "firefox" → Firefox, "mpd" → mpd.PipeWire
    function streamsFor(keys) {
        const ks = keys.map(k => String(k ?? "").toLowerCase()).filter(k => k.length > 2);
        if (!ks.length) return [];
        return streams.filter(n => {
            if (!n.audio) return false;
            const p = n.properties ?? {};
            if (p["media.class"] && p["media.class"] !== "Stream/Output/Audio") return false;
            const words = [];
            for (const f of ["application.name", "application.process.binary", "node.name", "pipewire.access.portal.app_id", "application.id"]) {
                const v = String(p[f] ?? "").toLowerCase();
                if (v) words.push(v, ...v.split(/[.\s_-]+/));
            }
            return ks.some(k => words.includes(k));
        });
    }
    // The keys for an MPRIS player: its desktop entry and the words of its name
    function playerKeys(p) {
        if (!p) return [];
        const e = String(p.desktopEntry ?? "");
        return [e, e.split(".").pop()].concat(String(p.identity ?? "").split(/\s+/));
    }

    PwObjectTracker { objects: [root.sink].concat(root.streams) }

    function fmt(s) {
        s = Math.max(0, Math.floor(s || 0));
        const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), sec = String(s % 60).padStart(2, "0");
        return h > 0 ? h + ":" + String(m).padStart(2, "0") + ":" + sec : m + ":" + sec;
    }

    readonly property real progress: player && player.length > 0 ? player.position / player.length : 0

    // MPRIS positions don't update on their own
    Timer {
        interval: 1000
        running: (root.player?.isPlaying ?? false) && PanelState.open
        repeat: true
        onTriggered: root.player.positionChanged()
    }
}
