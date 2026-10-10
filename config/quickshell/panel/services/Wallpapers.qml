pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Wallpaper list (scripts/wallpapers.py) and applying one through the existing
// scripts/wm/WallpaperSelect.sh (awww + wallust + waybar/swaync refresh).
Singleton {
    id: root
    property var items: []          // [{path, name, folder, thumb}]
    property var folders: []        // distinct sub-folders ("" = top level)
    property string current: ""
    property int pending: 0         // thumbnails still being generated
    property string applying: ""    // path being applied right now

    function refresh() { if (!list.running) list.running = true; }

    function apply(path) {
        if (applying !== "") return;
        applying = path;
        current = path;
        applyProc.command = ["bash", "-c", Config.wallpaperApplyCmd + " \"$0\"", path];
        applyProc.running = true;
    }

    Process {
        id: list
        command: ["python3", Quickshell.shellDir + "/scripts/wallpapers.py", Config.wallpaperDir]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.items = d.items;
                    root.folders = [...new Set(d.items.map(i => i.folder))];
                    root.current = d.current;
                    root.pending = d.pending;
                } catch (e) { console.warn("wallpapers:", e); }
            }
        }
    }

    Process {
        id: applyProc
        onRunningChanged: if (!running) root.applying = ""
    }

    // While thumbnails are being generated, re-list every few seconds to pick them up
    Timer {
        interval: 4000
        running: root.pending > 0 && PanelState.open
        repeat: true
        onTriggered: root.refresh()
    }
}
