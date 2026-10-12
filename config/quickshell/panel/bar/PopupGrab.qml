import QtQuick
import Quickshell.Hyprland
import "../services"

// Closes a bar popup (system popup, system monitor, tray list) on a click
// outside its windows — except while a screenshot region is picked: slurp's
// layer takes the focus, which clears the grab, and the popup would vanish
// before the capture (PanelState.capturing). Then it waits, and grabs again
// once the capture is done.
//   PopupGrab { open: root.open; windows: [root, bar]; onClose: … }
Item {
    id: root
    property bool open: false
    property var windows: []
    property bool armed: true
    signal close()

    HyprlandFocusGrab {
        active: root.open && root.armed
        windows: root.windows
        onCleared: { root.armed = false; check.restart(); }
    }
    // The capture layer may show up a moment after the grab clears
    Timer { id: check; interval: 250; onTriggered: if (root.open && !PanelState.capturing) root.close() }
    Connections {
        target: PanelState
        function onCapturingChanged() { if (!PanelState.capturing && root.open) root.armed = true; }
    }
    onOpenChanged: if (open) armed = true
}
