pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

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
        if (!node) return "None";
        let s = node.nickname || node.description || node.name || "Unknown";
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
    function useSink(node) { Pipewire.preferredDefaultAudioSink = node; }
    function useSource(node) { Pipewire.preferredDefaultAudioSource = node; }
}
