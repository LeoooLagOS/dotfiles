pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Audio visualizer: runs cava (scripts/cava.conf, raw output) only while some
// zone needs it — zones bump `users` up/down — so it costs nothing otherwise.
Singleton {
    id: root
    property int users: 0
    property var bars: []            // 0..1 per bar

    Process {
        command: ["cava", "-p", Quickshell.shellDir + "/scripts/cava.conf"]
        running: root.users > 0
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(";");
                const out = [];
                for (const p of parts) if (p !== "") out.push(parseInt(p) / 100);
                root.bars = out;
            }
        }
        onRunningChanged: if (!running) root.bars = []
    }
}
