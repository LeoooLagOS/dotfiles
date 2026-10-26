pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "../common"

// Shared MPRIS state for the media zones: the list of players and the one
// being shown (the one picked by the user, else one that is playing, else the first).
Singleton {
    id: root
    // playerctld is a proxy that mirrors the active player: skip it (it showed up as a duplicate)
    // A stopped player with nothing loaded is left over (a browser keeps one
    // after a video ends, e.g. WhatsApp's in Brave): hidden too. So is a
    // YouTube hover preview (isPreview)
    readonly property var players: Mpris.players.values.filter(p => !(p.dbusName ?? "").includes("playerctld")
        && !(p.playbackState === MprisPlaybackState.Stopped && !p.trackTitle) && !isPreview(p))
    property var picked: null

    // ---------------- Previews aren't music ----------------
    // Hovering a video on a site plays it muted, and the browser reports that
    // as a player. Two rules keep it out of the bar:
    //   1. isPreview: a YouTube page that isn't a video (the feed, search, a
    //      channel: the url is the page's, e.g. https://www.youtube.com/) is a
    //      hover preview: the player is hidden altogether
    //   2. counts: a browser's track only counts as music once its audio stream
    //      has made sound (a peak, PwNodePeakMonitor). A muted preview has no
    //      stream at all; an idle stream left by a paused video never peaks
    function isBrowser(p) {
        const s = [p?.desktopEntry, p?.identity, p?.dbusName].join(" ").toLowerCase();
        return /firefox|brave|chrom|librewolf|zen|vivaldi|edge|opera|epiphany/.test(s);
    }
    function urlOf(p) { return String(p?.metadata?.["xesam:url"] ?? ""); }
    function isPreview(p) {
        const m = urlOf(p).match(/^https?:\/\/(?:www\.|m\.)?youtube\.com(\/[^?#]*)?/);
        return !!m && !/^\/(watch|shorts\/|live\/|embed\/)/.test(m[1] ?? "/");
    }
    // Browser tracks that made sound: "<player>|<title>" → true
    property var heard: ({})
    function keyOf(p) { return (p?.dbusName ?? "") + "|" + (p?.trackTitle ?? ""); }
    function counts(p) { return !!p && (!isBrowser(p) || !!heard[keyOf(p)]); }
    // Listen to the shown player's streams while it plays and hasn't been heard yet
    readonly property bool listening: !!player && player.isPlaying && isBrowser(player) && !heard[keyOf(player)]
    function markHeard() {
        const h = Object.keys(heard).length > 100 ? {} : Object.assign({}, heard);
        h[keyOf(player)] = true;
        heard = h;
    }
    Instantiator {
        model: root.listening ? root.streamsFor(root.playerKeys(root.player)) : []
        delegate: PwNodePeakMonitor {
            required property var modelData
            node: modelData
            onPeakChanged: if (peak > 0.01 && root.listening) root.markHeard()
        }
    }

    function pick(p) { picked = p; }

    // ---------------- Its app ----------------
    // The chosen player's chip clicked again (MediaZone.qml) goes to its app:
    // one in the Comms dock (Spotify) shows there; MPD has no window, its app
    // is the panel's own Library; else its window is focused (leaving a Comms
    // app shown first), or the player raises itself (MPRIS Raise)
    function isMpd(p) { return /(^|\.)mpd(\.|$)/i.test(String(p?.dbusName ?? "")); }
    // How its window may be named: desktop entry, the D-Bus name's app part, identity
    function appKeys(p) {
        const bus = String(p?.dbusName ?? "").replace(/^org\.mpris\.MediaPlayer2\./, "").split(".")[0];
        return [String(p?.desktopEntry ?? ""), bus, String(p?.identity ?? "")]
            .map(k => k.toLowerCase()).filter(k => k.length > 2);
    }
    function goTo(p) {
        if (!p) return;
        if (isMpd(p)) { Settings.set("mediaMode", "library"); return; }
        const keys = appKeys(p);
        const d = Comms.defs.find(x => keys.some(k => x.classes.includes(k) || x.name.toLowerCase() === k));
        PanelState.open = false;
        if (d) { Comms.show(d.key); return; }
        const w = Comms.clients.find(c => {
            const cls = String(c.class).toLowerCase();
            return !c.workspace.name.startsWith("special:") && keys.some(k => cls === k || cls.includes(k));
        });
        if (!w) { if (p.canRaise) p.raise(); return; }
        focusAddress = w.address;
        if (Comms.leaveTo(w.workspace.id)) focusLater.restart(); else focusLater.triggered();
    }
    property string focusAddress: ""
    // After a Comms app has hidden (its way back moves the workspace)
    Timer {
        id: focusLater
        interval: 300
        onTriggered: Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.focus({ window = "address:${root.focusAddress}" })`])
    }

    // "Something is playing", for the bar (its right twin and the island):
    // still true a little after a pause, so pausing from the island keeps
    // play at hand instead of switching to the weather under the pointer
    readonly property bool hasTrack: !!player && !!player.trackTitle && counts(player)
    readonly property bool playing: hasTrack && player.isPlaying
    readonly property bool active: playing || (hasTrack && pausedJustNow.running)
    onPlayingChanged: if (!playing) pausedJustNow.restart()
    Timer { id: pausedJustNow; interval: 20000 }

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
