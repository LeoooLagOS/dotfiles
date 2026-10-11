pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Network details for the Wi-Fi zone's details view, read from `nmcli`.
//   show(kind, uuid)  kind: "wifi" (the connected network), "ethernet" (the
//                     wired device) or "vpn" (the connection `uuid`)
//   info   { kind, name, uuid, device, ip4, gateway, dns: [], ip6: [], mac,
//            autoconnect, … } or null; per kind:
//            wifi      signal, rate, band, channel, security
//            ethernet  speed (Mb/s), connected
//            vpn       type, server, active
//   Refreshed every few seconds while shown (`watching`).
//   disconnect() · forget() · setAutoconnect(on) · edit() (nm-connection-editor)
// Also `wired`: the Ethernet device for the Networks list ({ device, state,
// connection, connected } or null), read with `devices` while `listing`.
Singleton {
    id: root

    property string kind: "wifi"
    property string uuid: ""
    property var info: null
    property bool watching: false
    property bool listing: false
    property string error: ""
    readonly property bool reading: reader.running
    property var wired: null

    function show(k, id) {
        if (k !== kind || id !== uuid) info = null;
        kind = k;
        uuid = id ?? "";
        error = "";
        load();
    }
    function load() { if (!reader.running) reader.running = true; else again = true; }
    property bool again: false
    function run(cmd) {
        error = "";
        action.command = cmd;
        action.running = true;
    }
    function disconnect() {
        if (!info) return;
        run(info.kind === "vpn" ? ["nmcli", "connection", "down", "uuid", info.uuid]
                                : ["nmcli", "device", "disconnect", info.device]);
    }
    function forget() { if (info?.uuid) run(["nmcli", "connection", "delete", "uuid", info.uuid]); }
    function setAutoconnect(on) {
        if (info?.uuid) run(["nmcli", "connection", "modify", "uuid", info.uuid, "connection.autoconnect", on ? "yes" : "no"]);
    }
    function edit() {
        if (!info?.uuid) return;
        PanelState.open = false;
        Quickshell.execDetached(["nm-connection-editor", "--edit", info.uuid]);
    }

    // One script per read, printing "key=value" lines
    readonly property string common: `
show_dev() {
  nmcli -t -f GENERAL.CONNECTION,GENERAL.CON-UUID,GENERAL.HWADDR,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS,IP6.ADDRESS device show "$1" \\
    | sed -E 's/^GENERAL\\.CONNECTION:/name=/; s/^GENERAL\\.CON-UUID:/uuid=/; s/^GENERAL\\.HWADDR:/mac=/;
              s/^IP4\\.ADDRESS\\[[0-9]+\\]:/ip4=/; s/^IP4\\.GATEWAY:/gateway=/; s/^IP4\\.DNS\\[[0-9]+\\]:/dns=/;
              s/^IP6\\.ADDRESS\\[[0-9]+\\]:/ip6=/'
}
autoconnect() { nmcli -t -f connection.autoconnect connection show uuid "$1" | sed 's/^connection\\.autoconnect:/autoconnect=/'; }
`
    readonly property var scripts: ({
        wifi: `
dev=$(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="wifi" && $3=="connected" {print $1; exit}')
[ -z "$dev" ] && exit 0
echo "device=$dev"; show_dev "$dev"
nmcli -t -f IN-USE,CHAN,FREQ,RATE,SIGNAL,SECURITY device wifi list ifname "$dev" --rescan no \\
  | awk -F: '$1=="*" {print "channel="$2; print "freq="$3; print "rate="$4; print "signal="$5; print "security="$6; exit}'
autoconnect "$(nmcli -t -f GENERAL.CON-UUID device show "$dev" | cut -d: -f2)"`,
        ethernet: `
dev=$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="ethernet" {print $1; exit}')
[ -z "$dev" ] && exit 0
echo "device=$dev"; show_dev "$dev"
echo "speed=$(cat /sys/class/net/$dev/speed 2>/dev/null)"
echo "connected=$(nmcli -t -f GENERAL.STATE device show "$dev" | grep -q '(connected)' && echo yes || echo no)"
u=$(nmcli -t -f GENERAL.CON-UUID device show "$dev" | cut -d: -f2); [ -n "$u" ] && autoconnect "$u"`,
        vpn: `
u="$1"; [ -z "$u" ] && exit 0
nmcli -t -f connection.id,connection.uuid,connection.type,connection.autoconnect,GENERAL.STATE,GENERAL.DEVICES,IP4.ADDRESS,IP4.GATEWAY,IP4.DNS,IP6.ADDRESS connection show uuid "$u" 2>/dev/null \\
  | sed -E 's/^connection\\.id:/name=/; s/^connection\\.uuid:/uuid=/; s/^connection\\.type:/type=/;
            s/^connection\\.autoconnect:/autoconnect=/; s/^GENERAL\\.STATE:/state=/; s/^GENERAL\\.DEVICES:/device=/;
            s/^IP4\\.ADDRESS\\[[0-9]+\\]:/ip4=/; s/^IP4\\.GATEWAY:/gateway=/; s/^IP4\\.DNS\\[[0-9]+\\]:/dns=/;
            s/^IP6\\.ADDRESS\\[[0-9]+\\]:/ip6=/'
# Type-specific fields (asking for the other type's fields makes nmcli fail)
if [ "$(nmcli -g connection.type connection show uuid "$u")" = wireguard ]; then
  nmcli -g wireguard.peers connection show uuid "$u" | grep -o 'endpoint=[^ ]*' | head -1 | sed 's/^endpoint=/server=/'
else
  nmcli -t -f vpn.data,vpn.service-type connection show uuid "$u" | sed -E 's/^vpn\\.data:/vpndata=/; s/^vpn\\.service-type:/service=/'
  nmcli -t -f VPN.GATEWAY connection show uuid "$u" 2>/dev/null | sed -E 's/^VPN\\.GATEWAY:/server=/'
fi`
    })

    Process {
        id: reader
        command: ["bash", "-c", root.common + root.scripts[root.kind], "_", root.uuid]
        stdout: StdioCollector {
            onStreamFinished: {
                const o = { kind: root.kind, dns: [], ip6: [] };
                for (const line of text.split("\n")) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const k = line.slice(0, i), v = line.slice(i + 1).replace(/\\:/g, ":");
                    if (k === "dns") o.dns.push(v);
                    // Global addresses only (not link-local fe80::), without the prefix
                    else if (k === "ip6") { if (!v.startsWith("fe80")) o.ip6.push(v.split("/")[0]); }
                    else if (!(k in o)) o[k] = v;              // the first one (first IPv4 address)
                }
                const ok = o.kind === "vpn" ? !!o.uuid : !!o.device;
                if (!ok) { root.info = null; return; }
                o.ip4 = (o.ip4 ?? "").split("/")[0];
                o.autoconnect = o.autoconnect === "yes";
                if (o.kind === "wifi") {
                    const mhz = parseInt(o.freq) || 0;
                    o.band = mhz >= 5925 ? "6 GHz" : mhz >= 4900 ? "5 GHz" : mhz ? "2.4 GHz" : "";
                    o.signal = parseInt(o.signal) || 0;
                } else if (o.kind === "ethernet") {
                    const sp = parseInt(o.speed);
                    o.speed = sp > 0 ? (sp >= 1000 ? sp / 1000 + " Gb/s" : sp + " Mb/s") : "";
                    o.connected = o.connected === "yes";
                } else {
                    o.active = /activated/.test(o.state ?? "");
                    o.type = o.type === "wireguard" ? "WireGuard"
                           : /openvpn/.test(o.service ?? "") ? "OpenVPN"
                           : /vpnc/.test(o.service ?? "") ? "Cisco (vpnc)"
                           : /openconnect/.test(o.service ?? "") ? "OpenConnect"
                           : /l2tp/.test(o.service ?? "") ? "L2TP" : "VPN";
                    // Server: VPN.GATEWAY, else "remote"/"gateway" in vpn.data
                    if (!o.server) {
                        const m = /(?:^|, )(?:remote|gateway)\s*=\s*([^,]+)/.exec(o.vpndata ?? "");
                        o.server = m ? m[1].trim() : "";
                    }
                }
                root.info = o;
            }
        }
        onExited: if (root.again) { root.again = false; running = true; }
    }
    Process {
        id: action
        stderr: StdioCollector { id: actionErr }
        onExited: code => {
            if (code !== 0) root.error = actionErr.text.trim().split("\n").pop() || "nmcli failed";
            root.load();
            root.readDevices();
        }
    }
    Timer { interval: 5000; repeat: true; running: root.watching; onTriggered: root.load() }

    // ---------------- Wired device, for the Networks list ----------------
    function readDevices() { if (!devices.running) devices.running = true; }
    Process {
        id: devices
        command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.split(":")[1] === "ethernet");
                if (!line) { root.wired = null; return; }
                const f = line.split(":");
                root.wired = { device: f[0], state: f[2], connection: f.slice(3).join(":"), connected: f[2] === "connected" };
            }
        }
    }
    Timer { interval: 4000; repeat: true; running: root.listing; triggeredOnStart: true; onTriggered: root.readDevices() }
}
