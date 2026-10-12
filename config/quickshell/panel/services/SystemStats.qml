pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Polls scripts/sysstats.sh: every 2 s while the panel is open or the bar shows
// the stats (BarState.statsShown), every minute otherwise. Keeps the last
// minute of CPU / RAM / temperature for the bar's graphs.
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

    readonly property int memPct: Math.round(100 * memUsed / memTotal)
    readonly property int diskPct: Math.round(100 * diskUsed / diskTotal)
    // Last 30 samples (a minute at the fast rate), oldest first
    property var cpuHist: []
    property var memHist: []
    property var tempHist: []
    function pushHist(a, v) { const n = a.concat([v]); return n.length > 30 ? n.slice(n.length - 30) : n; }

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
                    root.cpuHist = root.pushHist(root.cpuHist, d.cpu);
                    root.memHist = root.pushHist(root.memHist, root.memPct);
                    root.tempHist = root.pushHist(root.tempHist, d.temp);
                } catch (e) { console.warn("sysstats:", e, text); }
            }
        }
    }

    Timer {
        interval: PanelState.open || BarState.statsShown ? 2000 : 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }
}
