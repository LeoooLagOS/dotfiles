import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../common"
import "../services"

// Everything running in the background, from a chevron next to the power
// button. Three views:
//   Tray      the apps' tray icons (Teams, Vesktop, Telegram…): click opens
//             the app · right click: its menu · middle click: secondary action
//   Apps      every program with a window, grouped (hidden ones marked: the
//             comms dock's, other special workspaces), and Flatpak apps
//             running without one: click goes to it · × closes / stops it
//   Services  daemons: your systemd user services (restart, stop: click ■
//             twice), and the system's (read only)
// Processes are in the system monitor (the footer link). The lists are read
// while it's open. Closes on a click outside (TopBar's focus grab).
// `dropdown` is the list, for the bar's input mask.
BarPill {
    id: root
    property var barWindow: null
    property bool open: false
    property string view: "tray"
    readonly property var items: SystemTray.items.values
    property alias dropdown: drop
    square: true
    clickable: true
    active: open
    onClicked: open = !open

    Glyph {
        text: root.open ? "" : ""
        font.pixelSize: 10
        color: root.open ? Theme.fg : Theme.fgDim
    }

    // ---------------- Data ----------------
    // Programs with a window, one row per app (class)
    readonly property var apps: {
        const by = {};
        for (const t of Hyprland.toplevels.values) {
            const id = String(t.wayland?.appId ?? t.lastIpcObject?.class ?? "");
            if (!id) continue;
            const ws = t.workspace?.name ?? "";
            const e = by[id] ?? (by[id] = { id: id, entry: root.entryFor(id), windows: [], hidden: false, where: [] });
            e.windows.push(t);
            if (ws.startsWith("special:")) e.hidden = true;
            const w = ws.startsWith("special:comms-") ? "comms dock" : ws.startsWith("special:") ? "hidden" : ws;
            if (w && !e.where.includes(w)) e.where.push(w);
        }
        return Object.values(by).sort((a, b) => (a.entry?.name ?? a.id).localeCompare(b.entry?.name ?? b.id));
    }
    // Flatpak apps running without any window (flatpak ps)
    property var flatpaks: []
    readonly property var headless: flatpaks.filter(f => !apps.some(a => a.id.toLowerCase() === f.app.toLowerCase()
        || (a.entry?.id ?? "").toLowerCase() === f.app.toLowerCase()))
    property var userServices: []
    property var systemServices: []

    function refresh() {
        if (!fpProc.running) fpProc.running = true;
        if (!userProc.running) userProc.running = true;
        if (!sysProc.running) sysProc.running = true;
    }
    onOpenChanged: if (open) refresh()
    Timer { interval: 3000; repeat: true; running: root.open; onTriggered: root.refresh() }
    function units(text) {
        return text.split("\n").filter(l => l.trim()).map(l => {
            const p = l.trim().split(/\s+/);
            return { unit: p[0], desc: p.slice(4).join(" "), name: p[0].replace(/\.service$/, "").replace(/\\x2d/g, "-") };
        });
    }
    Process {
        id: fpProc
        command: ["flatpak", "ps", "--columns=application,pid"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                for (const l of text.split("\n")) {
                    const [app, pid] = l.trim().split(/\s+/);
                    if (app && !seen[app]) seen[app] = { app: app, pid: pid, entry: DesktopEntries.heuristicLookup(app) };
                }
                root.flatpaks = Object.values(seen);
            }
        }
    }
    Process {
        id: userProc
        command: ["systemctl", "--user", "list-units", "--type=service", "--state=running", "--no-legend", "--plain"]
        stdout: StdioCollector { onStreamFinished: root.userServices = root.units(text) }
    }
    Process {
        id: sysProc
        command: ["systemctl", "list-units", "--type=service", "--state=running", "--no-legend", "--plain"]
        stdout: StdioCollector { onStreamFinished: root.systemServices = root.units(text) }
    }

    property string confirm: ""                 // a row waiting for its second click
    Timer { id: confirmTimer; interval: 3000; onTriggered: root.confirm = "" }
    function twice(key, action) {
        if (confirm !== key) { confirm = key; confirmTimer.restart(); return; }
        confirm = "";
        action();
        refreshSoon.restart();
    }
    Timer { id: refreshSoon; interval: 700; onTriggered: root.refresh() }
    function dispatch(expr) { Quickshell.execDetached(["hyprctl", "dispatch", expr]); }
    // A window class's desktop entry; a Brave / Chrome web app (brave-<id>-Default)
    // has its launcher under the browser's Flatpak prefix
    function entryFor(id) {
        return DesktopEntries.heuristicLookup(id) ?? DesktopEntries.byId("com.brave.Browser.flextop." + id)
            ?? DesktopEntries.byId(id.replace(/^brave-/, "chrome-")) ?? null;
    }
    function iconFor(entry, id) {
        return Quickshell.iconPath(entry?.icon ?? String(id).toLowerCase(), true) || Quickshell.iconPath("application-x-executable", true);
    }

    // ---------------- The dropdown ----------------
    Rectangle {
        id: drop
        parent: root
        visible: root.open
        anchors.top: parent.bottom
        anchors.topMargin: 8
        anchors.right: parent.right
        width: root.open ? 380 : 0
        height: root.open ? Math.min(520, list.implicitHeight + seg.height + foot.height + 36) : 0
        radius: 16
        color: Theme.bg
        border.color: Theme.border

        Segmented {
            id: seg
            x: 10
            y: 10
            width: parent.width - 20
            options: [{ value: "tray", label: "Tray " + root.items.length },
                      { value: "apps", label: "Apps " + (root.apps.length + root.headless.length) },
                      { value: "services", label: "Services " + root.userServices.length }]
            value: root.view
            onSelected: v => root.view = v
        }

        Flickable {
            anchors.top: seg.bottom
            anchors.topMargin: 8
            anchors.bottom: foot.top
            anchors.bottomMargin: 8
            x: 10
            width: parent.width - 20
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: list
                width: parent.width
                spacing: 2

                // ---------------- Tray ----------------
                Label { visible: root.view === "tray" && !root.items.length; text: "No tray icons"; dim: true; font.pixelSize: 12; Layout.margins: 8 }
                Repeater {
                    model: root.view === "tray" ? root.items : []
                    delegate: Row_ {
                        id: trow
                        required property var modelData
                        icon: modelData.icon
                        title: modelData.tooltipTitle || modelData.title || modelData.id
                        subtitle: modelData.tooltipDescription ?? ""
                        menu: modelData.hasMenu
                        onClicked: m => {
                            const it = trow.modelData;
                            if (m.button === Qt.MiddleButton) { it.secondaryActivate(); root.open = false; }
                            else if (m.button === Qt.RightButton || it.onlyMenu) {
                                if (it.hasMenu && root.barWindow) {
                                    const p = trow.mapToItem(null, trow.width - 8, trow.height / 2);
                                    it.display(root.barWindow, p.x, p.y);
                                }
                            } else { it.activate(); root.open = false; }
                        }
                    }
                }

                // ---------------- Apps ----------------
                Section { visible: root.view === "apps"; text: "WITH A WINDOW" }
                Repeater {
                    model: root.view === "apps" ? root.apps : []
                    delegate: Row_ {
                        required property var modelData
                        icon: root.iconFor(modelData.entry, modelData.id)
                        title: modelData.entry?.name ?? modelData.id
                        subtitle: (modelData.windows.length > 1 ? modelData.windows.length + " windows · " : "")
                                  + "workspace " + modelData.where.join(", ")
                        badge: modelData.hidden ? "hidden" : ""
                        actionIcon: ""
                        confirming: root.confirm === "app:" + modelData.id
                        onClicked: { root.dispatch(`hl.dsp.focus({ window = "address:${modelData.windows[0].address}" })`); root.open = false; }
                        onAction: root.twice("app:" + modelData.id, () => {
                            for (const w of modelData.windows) root.dispatch(`hl.dsp.window.close({ window = "address:${w.address}" })`);
                        })
                    }
                }
                Section { visible: root.view === "apps" && root.headless.length > 0; text: "RUNNING WITHOUT A WINDOW" }
                Repeater {
                    model: root.view === "apps" ? root.headless : []
                    delegate: Row_ {
                        required property var modelData
                        icon: root.iconFor(modelData.entry, modelData.app)
                        title: modelData.entry?.name ?? modelData.app
                        subtitle: "Flatpak · " + modelData.app
                        actionIcon: ""
                        confirming: root.confirm === "fp:" + modelData.app
                        onClicked: { if (modelData.entry) modelData.entry.execute(); root.open = false; }
                        onAction: root.twice("fp:" + modelData.app, () => Quickshell.execDetached(["flatpak", "kill", modelData.app]))
                    }
                }

                // ---------------- Services ----------------
                Section { visible: root.view === "services"; text: "YOURS · systemd --user" }
                Repeater {
                    model: root.view === "services" ? root.userServices : []
                    delegate: Row_ {
                        required property var modelData
                        glyph: modelData.unit.includes("@autostart") ? "" : ""
                        title: modelData.desc || modelData.name
                        subtitle: modelData.name
                        actionIcon: ""
                        action2Icon: ""
                        confirming: root.confirm === "svc:" + modelData.unit
                        onAction: root.twice("svc:" + modelData.unit, () => Quickshell.execDetached(["systemctl", "--user", "stop", modelData.unit]))
                        onAction2: { Quickshell.execDetached(["systemctl", "--user", "restart", modelData.unit]); refreshSoon.restart(); }
                    }
                }
                Section { visible: root.view === "services"; text: "SYSTEM · read only" }
                Repeater {
                    model: root.view === "services" ? root.systemServices : []
                    delegate: Row_ {
                        required property var modelData
                        glyph: ""
                        title: modelData.desc || modelData.name
                        subtitle: modelData.name
                        dimmed: true
                    }
                }
            }
        }

        // Footer: processes live in the system monitor
        Rectangle {
            id: foot
            x: 10
            width: parent.width - 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            height: 32
            radius: 10
            color: footMouse.containsMouse ? Theme.bgHover : Theme.withAlpha(Theme.fg, 0.04)
            Row {
                anchors.centerIn: parent
                spacing: 8
                Glyph { text: ""; font.pixelSize: 12; color: BarState.accent; anchors.verticalCenter: parent.verticalCenter }
                Label { text: "Processes and resources: system monitor"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
            }
            MouseArea {
                id: footMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { root.open = false; BarState.toggleMonitor(root.barWindow?.screen?.name ?? ""); }
            }
        }
    }

    // ---------------- Pieces ----------------
    component Section: Label {
        Layout.topMargin: 6
        Layout.leftMargin: 8
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 0.8
        color: Theme.fgDim
    }
    // One row: icon (or glyph), title, subtitle, a badge, up to two actions
    // (shown on hover; the first, stop / close, asks twice)
    component Row_: Rectangle {
        id: r
        property string icon: ""
        property string glyph: ""
        property string title: ""
        property string subtitle: ""
        property string badge: ""
        property bool menu: false
        property bool dimmed: false
        property string actionIcon: ""
        property string action2Icon: ""
        property bool confirming: false
        signal clicked(var mouse)
        signal action()
        signal action2()
        Layout.fillWidth: true
        implicitHeight: 42
        radius: 10
        color: rowMouse.containsMouse && !dimmed ? Theme.bgHover : "transparent"
        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: !r.dimmed
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: m => r.clicked(m)
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 10
            Item {
                implicitWidth: 20
                implicitHeight: 20
                IconImage { anchors.fill: parent; visible: r.icon !== ""; source: r.icon; implicitSize: 20 }
                Glyph { anchors.centerIn: parent; visible: r.icon === ""; text: r.glyph; font.pixelSize: 13; color: r.dimmed ? Theme.fgDim : BarState.accent }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                RowLayout {
                    spacing: 6
                    Layout.fillWidth: true
                    Label { text: r.title; font.pixelSize: 13; dim: r.dimmed; Layout.fillWidth: true }
                    Rectangle {
                        visible: r.badge !== ""
                        implicitHeight: 15
                        implicitWidth: badgeLabel.implicitWidth + 10
                        radius: 8
                        color: Theme.withAlpha(BarState.accent, 0.18)
                        Label { id: badgeLabel; anchors.centerIn: parent; text: r.badge; color: BarState.accent; font.pixelSize: 9; font.weight: Font.DemiBold }
                    }
                }
                Label { visible: r.subtitle !== ""; text: r.subtitle; dim: true; font.pixelSize: 10; Layout.fillWidth: true }
            }
            Glyph { visible: r.menu; text: ""; font.pixelSize: 11; color: Theme.fgDim }
            Repeater {
                model: [r.action2Icon, r.actionIcon].filter(x => x)
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool primary: modelData === r.actionIcon
                    readonly property bool asking: primary && r.confirming
                    implicitWidth: asking ? askLabel.implicitWidth + 16 : 26
                    implicitHeight: 24
                    radius: 12
                    opacity: rowMouse.containsMouse || actMouse.containsMouse || asking ? 1 : 0
                    color: asking ? Theme.bad : actMouse.containsMouse ? Theme.withAlpha(primary ? Theme.bad : Theme.fg, 0.16) : "transparent"
                    Glyph { anchors.centerIn: parent; visible: !parent.asking; text: modelData; font.pixelSize: 10; color: parent.primary ? Theme.bad : Theme.fg }
                    Label { id: askLabel; anchors.centerIn: parent; visible: parent.asking; text: "Sure?"; font.pixelSize: 11; font.weight: Font.DemiBold; color: Theme.onColor(Theme.bad) }
                    MouseArea {
                        id: actMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: parent.primary ? r.action() : r.action2()
                    }
                }
            }
        }
    }
}
