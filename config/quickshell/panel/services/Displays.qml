pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Monitors, for the Controls "Display" tile and its detail. Reads
// `hyprctl monitors all -j` (re-read when Hyprland adds/removes a monitor or
// reloads, and after each change) and applies quick changes at runtime with
// `hyprctl eval 'hl.monitor({...})'`. They last until Hyprland reloads its
// config: nwg-displays (or monitor profiles, SUPER ALT M) saves a layout.
//   monitors   [{ name, description, width, height, refresh, scale, x, y,
//                 disabled, focused, modes: ["1920x1080@100", …] }]
//   setMode(m, mode) · setScale(m, s) · setEnabled(m, on)
Singleton {
    id: root

    property var monitors: []
    readonly property var enabled: monitors.filter(m => !m.disabled)
    readonly property var primary: enabled.find(m => m.focused) ?? enabled[0] ?? null
    property string error: ""

    function refresh() { if (!read.running) read.running = true; }

    // Keep everything else as it is: position, scale, mode
    function apply(m, changes) {
        const o = Object.assign({ output: m.name, mode: m.width + "x" + m.height + "@" + m.refresh,
                                  position: m.x + "x" + m.y, scale: m.scale }, changes);
        const lua = "hl.monitor({ " + Object.keys(o).map(k =>
            k + " = " + (typeof o[k] === "string" ? JSON.stringify(o[k]) : String(o[k]))).join(", ") + " })";
        error = "";
        applier.command = ["hyprctl", "eval", lua];
        applier.running = true;
    }
    function setMode(m, mode) { apply(m, { mode: mode }); }
    function setScale(m, s) { apply(m, { scale: s }); }
    function setEnabled(m, on) {
        if (!on && enabled.length <= 1) return;           // never turn off the last screen
        if (on) apply(m, { mode: "preferred", position: "auto", scale: 1 });
        else {
            error = "";
            applier.command = ["hyprctl", "eval", `hl.monitor({ output = ${JSON.stringify(m.name)}, disabled = true })`];
            applier.running = true;
        }
    }
    function openNwgDisplays() { PanelState.open = false; Quickshell.execDetached(["nwg-displays"]); }
    function openProfiles() {
        PanelState.open = false;
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/MonitorProfiles.sh"]);
    }

    Process {
        id: read
        command: ["hyprctl", "monitors", "all", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(text).map(m => ({
                        name: m.name, description: m.description || m.model || m.name,
                        width: m.width, height: m.height, refresh: Math.round(m.refreshRate * 100) / 100,
                        scale: m.scale, x: m.x, y: m.y, disabled: !!m.disabled, focused: !!m.focused,
                        // "1920x1080@100.00Hz" → "1920x1080@100", unique, as listed (best first)
                        modes: [...new Set((m.availableModes ?? []).map(s => s.replace(/(\.0+)?Hz$/, "").replace(/(\.\d*?)0+$/, "$1")))]
                    }));
                } catch (e) {}
            }
        }
    }
    Process {
        id: applier
        stdout: StdioCollector { id: evalOut }
        onExited: code => {
            const out = evalOut.text.trim();
            if (code !== 0 || (out && out !== "ok")) root.error = out || "hyprctl failed";
            settle.restart();
        }
    }
    // Hyprland applies monitor changes asynchronously
    Timer { id: settle; interval: 600; onTriggered: root.refresh() }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["monitoradded", "monitoraddedv2", "monitorremoved", "monitorremovedv2", "configreloaded", "focusedmon"].includes(event.name))
                settle.restart();
        }
    }
    Component.onCompleted: refresh()
}
