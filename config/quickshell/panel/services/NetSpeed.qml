pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Download / upload speed, for the bar's Wi-Fi reading: the bytes of
// /proc/net/dev every 2 s, summed over the real interfaces (Wi-Fi, cable;
// not the loopback nor the VMs' and containers' bridges). Only while the bar
// shows the Wi-Fi.
//   NetSpeed.down / NetSpeed.up   bytes per second
//   NetSpeed.wired                a cable moved bytes in the last sample
//   NetSpeed.fmt(bps)             "420K", "4.2M": at most 4 characters
//   NetSpeed.cell("↓", bps)       arrow + the same, always as wide (for the bar)
Singleton {
    id: root
    property real down: 0
    property real up: 0
    property bool wired: false
    readonly property bool watching: BarState.enabled && BarState.shown("wifi")

    property var last: null                     // { t, rx, tx, wrx }
    readonly property var virtualIf: /^(lo|virbr|vnet|veth|docker|br-|podman|tun|tap|wg|tailscale|zt)/

    function fmt(bps) {
        const k = bps / 1024;
        if (k < 1) return "0K";
        if (k < 10) return k.toFixed(1) + "K";
        if (k < 1000) return Math.round(k) + "K";
        const m = k / 1024;
        if (m < 10) return m.toFixed(1) + "M";
        if (m < 1000) return Math.round(m) + "M";
        return (m / 1024).toFixed(1) + "G";
    }

    // For the bar: always 4 characters, padded with figure spaces (as wide as a
    // digit) in front, so the numbers sit right-aligned and nothing moves
    // The arrow goes with its number: "  ↓0K", " ↓42K", "↓4.2M"
    function cell(arrow, bps) { const f = fmt(bps); return "\u2007".repeat(Math.max(0, 4 - f.length)) + arrow + f; }

    function sample(text) {
        let rx = 0, tx = 0, wrx = 0;
        for (const line of text.split("\n").slice(2)) {
            const m = line.match(/^\s*([^:\s]+):\s*(.*)$/);
            if (!m || virtualIf.test(m[1])) continue;
            const f = m[2].trim().split(/\s+/).map(Number);
            rx += f[0]; tx += f[8];
            if (/^(en|eth)/.test(m[1])) wrx += f[0];
        }
        const now = Date.now();
        if (last) {
            const dt = (now - last.t) / 1000;
            if (dt > 0) {
                // Counters reset (an interface gone): no negative speed
                down = Math.max(0, (rx - last.rx) / dt);
                up = Math.max(0, (tx - last.tx) / dt);
                wired = wrx > last.wrx;
            }
        }
        last = { t: now, rx: rx, tx: tx, wrx: wrx };
    }

    // A process, not a FileView: procfs files report size 0 and FileView reads nothing
    Process {
        id: dev
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector { onStreamFinished: root.sample(text) }
    }
    Timer {
        interval: 2000
        running: root.watching
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!dev.running) dev.running = true
    }
    onWatchingChanged: if (!watching) { last = null; down = 0; up = 0; wired = false; }
}
