pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Polls scripts/sysstats.sh. Polls fast while the panel is open, slowly otherwise.
Singleton {
    id: root
    property int cpu: 0              // %
    property real memUsed: 0         // bytes
    property real memTotal: 1
    property int temp: 0             // °C
    property real diskUsed: 0        // bytes
    property real diskTotal: 1
    property int battery: 0          // %
    property string batteryStatus: ""
    property string uptime: ""

    function gb(bytes) { return (bytes / 1073741824).toFixed(1); }

    Process {
        id: proc
        command: [Quickshell.shellDir + "/scripts/sysstats.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.cpu = d.cpu; root.memUsed = d.memUsed; root.memTotal = d.memTotal;
                    root.temp = d.temp; root.diskUsed = d.diskUsed; root.diskTotal = d.diskTotal;
                    root.battery = d.battery; root.batteryStatus = d.batteryStatus; root.uptime = d.uptime;
                } catch (e) { console.warn("sysstats:", e, text); }
            }
        }
    }

    Timer {
        interval: PanelState.open ? 2000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }
}
