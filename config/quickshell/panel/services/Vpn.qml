pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// VPN connections saved in NetworkManager (OpenVPN, WireGuard, …), shown in
// the Wi-Fi detail's VPN view. Quickshell.Networking doesn't expose them, so
// this reads `nmcli` while someone is looking (`watching`) and after each
// action, and once at start for the Wi-Fi tile's "· VPN".
//   connections  [{ name, uuid, type, active }]
//   active       the connected one, or null
//   toggle(c)    up / down
//   add()        nm-connection-editor (add or import a VPN)
Singleton {
    id: root

    property var connections: []
    readonly property var active: connections.find(c => c.active) ?? null
    property bool watching: false
    property string busy: ""                  // uuid being switched
    property string error: ""

    function refresh() { if (!list.running) list.running = true; }
    function toggle(c) {
        busy = c.uuid;
        error = "";
        action.command = ["nmcli", "connection", c.active ? "down" : "up", "uuid", c.uuid];
        action.running = true;
    }
    function add() { Quickshell.execDetached(["nm-connection-editor"]); }

    Process {
        id: list
        command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,ACTIVE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const out = [];
                for (const line of text.trim().split("\n")) {
                    if (!line) continue;
                    // NAME:UUID:TYPE:ACTIVE. Only the name can contain ":" (escaped as
                    // "\:"), so take the last three fields from the right. (No regex
                    // lookbehind: QML's JS engine doesn't split with it.)
                    const f = line.split(":");
                    if (f.length < 4) continue;
                    const active = f.pop(), type = f.pop(), uuid = f.pop();
                    const name = f.join(":").replace(/\\:/g, ":");
                    if (type !== "vpn" && type !== "wireguard") continue;
                    out.push({ name: name, uuid: uuid, type: type === "vpn" ? "VPN" : "WireGuard", active: active === "yes" });
                }
                root.connections = out;
            }
        }
    }
    Process {
        id: action
        stderr: StdioCollector { id: actionErr }
        onExited: code => {
            root.error = code === 0 ? "" : (actionErr.text.trim().split("\n").pop() || "nmcli failed");
            root.busy = "";
            root.refresh();
        }
    }
    Timer { interval: 4000; repeat: true; running: root.watching; triggeredOnStart: true; onTriggered: root.refresh() }
    Component.onCompleted: refresh()
}
