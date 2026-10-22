pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../common"

// Default output / input (PipeWire), the devices to choose from, and short
// names for them ("Jabra EVOLVE 20" instead of "Jabra EVOLVE 20 MS Analog Stereo").
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.audio && !n.isSink && !n.isStream)

    // Volumes can only be read/written on tracked nodes
    PwObjectTracker { objects: [root.sink, root.source] }

    function name(node) {
        if (!node) return Tr.t("None");
        let s = node.nickname || node.description || node.name || Tr.t("Unknown");
        s = s.replace(/ (Analog|Digital) (Stereo|Mono|Surround.*)$/, "")
             .replace(/ \((Stereo|Mono)\)$/, "")
             .replace(/^.*High Definition Audio Controller /, "")
             .replace(/ (MS|USB)$/, "");
        return s;
    }
    function icon(node) {
        const s = ((node?.description ?? "") + " " + (node?.name ?? "")).toLowerCase();
        if (s.includes("hdmi") || s.includes("displayport")) return "";
        if (s.includes("headset") || s.includes("headphone") || s.includes("jabra") || s.includes("bluez")) return "";
        if (s.includes("mic")) return "";
        return node?.isSink ? "" : "";
    }
    // ---------------- Volume keys ----------------
    // Hyprland sends them to the panel (shell.qml, GlobalShortcut): the volume
    // is set on the PipeWire node right here and the level shown by the panel
    // (Notifs.showLevel), with no script or notification in between.
    // As Volume.sh did: ±delta %, up to 150 (boost); a step while muted unmutes.
    function stepVolume(delta) {
        const a = sink?.audio;
        if (!a) return;
        if (a.muted) a.muted = false;
        else {
            a.volume = Math.max(0, Math.min(150, Math.round(a.volume * 100) + delta)) / 100;
            Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/Sounds.sh", "--volume"]);
        }
        showVolume();
    }
    function toggleMute() {
        const a = sink?.audio;
        if (!a) return;
        a.muted = !a.muted;
        showVolume();
    }
    function toggleMic() {
        const a = source?.audio;
        if (!a) return;
        a.muted = !a.muted;
        Notifs.showLevel("mic_notif", Tr.t("Microphone"), a.muted ? 0 : Math.round(a.volume * 100), a.muted ? Tr.t("Muted") : "");
    }
    function showVolume() {
        const a = sink?.audio;
        Notifs.showLevel("volume_notif", Tr.t("Volume"), a.muted ? 0 : Math.round(a.volume * 100), a.muted ? Tr.t("Muted") : "");
    }

    function useSink(node) { Pipewire.preferredDefaultAudioSink = node; }
    function useSource(node) { Pipewire.preferredDefaultAudioSource = node; }
}
