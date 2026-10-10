pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Who and where: full name (GECOS field of /etc/passwd, falls back to $USER),
// host, distro (logo from /etc/os-release) and window manager.
// Used by the Overview profile zone and the Controls identity bar.
Singleton {
    id: root

    readonly property string user: Quickshell.env("USER")
    property string fullName: user
    property string host: ""
    property string distroId: ""
    property string distroName: ""
    readonly property string wm: Quickshell.env("XDG_CURRENT_DESKTOP") || Quickshell.env("DESKTOP_SESSION") || "Wayland"
    readonly property bool hasFullName: fullName !== user
    readonly property string initials: fullName.split(" ").map(w => w[0]).slice(0, 2).join("").toUpperCase()
    readonly property string avatar: "file://" + Quickshell.env("HOME") + "/.face"

    // Nerd Font distro logos (nf-linux-*)
    readonly property var distroLogos: ({
        fedora: "", arch: "", endeavouros: "", manjaro: "",
        ubuntu: "", debian: "", linuxmint: "", pop: "",
        nixos: "", opensuse: "", "opensuse-tumbleweed": "", gentoo: "",
        void: "", alpine: "", centos: "", rhel: "", elementary: ""
    })
    readonly property string distroLogo: distroLogos[distroId] ?? ""   // generic Tux

    Process {
        command: ["bash", "-c", "getent passwd \"$USER\" | cut -d: -f5 | cut -d, -f1; hostname; . /etc/os-release; echo \"$ID\"; echo \"$NAME $VERSION_ID\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines[0]) root.fullName = lines[0];
                if (lines[1]) root.host = lines[1];
                if (lines[2]) root.distroId = lines[2].toLowerCase();
                if (lines[3]) root.distroName = lines[3].replace(" Linux", "");
            }
        }
    }
}
