pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// The flavors (dotfiles/flavors) and the mode in use, for the start menu
// (bar/StartMenu.qml). The logic is scripts/wm/FlavorMode.sh, shared with the
// rofi menu (SUPER ALT F → FlavorMenu.sh): one command, two front ends
// (ADR-0014). Picking a flavor switches its audio profile right away; installing
// one isn't offered here yet (the flavor engine, ROADMAP Phase 6).
//   all        every flavor: { id, name, description, icon, profile, audio,
//              installed, active, apps: [{ id, name }] }, names in the
//              desktop's language
Singleton {
    id: root

    readonly property string cmd: Quickshell.env("HOME") + "/.config/hypr/scripts/FlavorMode.sh"
    property var all: []
    readonly property var installed: all.filter(f => f.installed)
    readonly property var current: all.find(f => f.active) ?? null

    function refresh() { if (!lister.running) lister.running = true; }
    function set(id) {
        // Shown at once; the list read again confirms it
        all = all.map(f => Object.assign({}, f, { active: f.id === id }));
        setter.command = [cmd, "set", id];
        setter.running = true;
    }

    Process {
        id: lister
        command: [root.cmd, "list"]
        stdout: StdioCollector {
            onStreamFinished: { try { root.all = JSON.parse(text); } catch (e) {} }
        }
    }
    Process {
        id: setter
        onRunningChanged: if (!running) root.refresh()
    }

    // The names come in the panel's language
    Connections {
        target: Settings
        function onChanged(key) { if (key === "language") root.refresh(); }
    }
    Component.onCompleted: refresh()
}
