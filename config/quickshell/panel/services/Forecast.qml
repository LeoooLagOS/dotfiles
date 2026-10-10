pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Hourly (24 h) and daily (7 d) forecast from scripts/forecast.py (Open-Meteo,
// same location as waybar's weather, cached 30 min).
Singleton {
    id: root
    property var hourly: []      // [{time, temp, code, rain, isDay}]
    property var daily: []       // [{date, code, max, min, rain, sunrise, sunset}]
    property int usAqi: -1       // US EPA AQI (-1 = unknown)
    property string error: ""

    function refresh() { if (!proc.running) proc.running = true; }

    Process {
        id: proc
        command: ["python3", Quickshell.shellDir + "/scripts/forecast.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.error = d.error ?? "";
                    if (!d.error) {
                        root.hourly = d.hourly; root.daily = d.daily;
                        root.usAqi = d.usAqi ?? -1;
                    }
                } catch (e) { root.error = String(e); }
            }
        }
    }

    // Refresh when the panel opens (cheap: the script serves its cache) and every 30 min
    Connections {
        target: PanelState
        function onOpenChanged() { if (PanelState.open) root.refresh(); }
    }
    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
