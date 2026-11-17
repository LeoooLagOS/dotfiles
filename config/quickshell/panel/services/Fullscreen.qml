pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

// Whether a fullscreen window covers the bar on the focused monitor: Hyprland
// hides the Top layer (the bar's) under it. Then the island's levels and
// messages show on their own (LevelOsd.qml) and the popups go up to the screen's
// edge (NotificationPopups.qml). A maximized window (fullscreen mode 1) leaves
// the bar visible: only mode 2 counts.
Singleton {
    id: root

    readonly property var monitor: Hyprland.focusedMonitor
    readonly property var ws: monitor?.activeWorkspace ?? null
    readonly property bool covered: !!ws?.hasFullscreen
        && ws.toplevels.values.some(t => t.lastIpcObject?.fullscreen === 2)
    readonly property string monitorName: covered ? monitor?.name ?? "" : ""

    // Hyprland's toplevels don't refresh their IPC data (lastIpcObject.fullscreen)
    // on their own: on each fullscreen change, and when a window opens or moves
    // (one opened already fullscreen sends no fullscreen event)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "fullscreen" || event.name === "openwindow" || event.name === "movewindowv2")
                Hyprland.refreshToplevels();
        }
    }
    Component.onCompleted: Hyprland.refreshToplevels()
}
