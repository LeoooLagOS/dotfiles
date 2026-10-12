pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness through brightnessctl. value is 0..1; read every 5 s while
// the panel or the bar's system popup is open
Singleton {
    id: root
    property real value: 0

    function set(v) {
        root.value = v;
        Quickshell.execDetached(["brightnessctl", "-q", "set", Math.max(1, Math.round(v * 100)) + "%"]);
    }

    Process {
        id: proc
        command: ["brightnessctl", "-m"]   // name,class,current,percent,max
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length >= 4) root.value = parseInt(parts[3]) / 100;
            }
        }
    }

    Timer {
        interval: 5000
        running: PanelState.open || BarState.popupOn !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }
}
