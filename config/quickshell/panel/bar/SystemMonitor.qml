import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../common"
import "../services"

// The system monitor that drops from the bar's readings (BarState.monitorOn),
// btop-like in the panel's look, compact:
//   CPU        usage, temperature, frequency, cores / threads and how many are
//              busy; click it for the detail: every thread (usage, frequency,
//              last minute), per-core temperatures, load
//   memory     used · cache, swap   ·   storage: disks and I/O   ·   network rates
//   processes  filter, sort by CPU / memory / name, end one (× twice; Shift: kill -9)
// Data: scripts/sysmon.py, run only while it's open. Closes on a click outside
// (not while a screenshot region is picked: PopupGrab), Esc, or the readings again.
PanelWindow {
    id: root
    property var barWindow: null
    property real rightOffset: 8
    property string screenName: ""
    readonly property bool open: screenName !== "" && BarState.monitorOn === screenName
    property bool cpuDetail: false
    onOpenChanged: if (!open) cpuDetail = false

    visible: open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    anchors { top: true; right: true }
    margins { top: 6; right: Math.max(8, rightOffset) }
    implicitWidth: 600
    implicitHeight: card.implicitHeight + 2
    WlrLayershell.namespace: "quickshell:bar-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    PopupGrab {
        open: root.open
        windows: [root, root.barWindow]
        onClose: BarState.monitorOn = ""
    }

    // ---------------- Data ----------------
    property var d: null
    property var cpuHist: []
    property var coreHist: []                 // per thread, last 40 samples
    property var rxHist: []
    property var txHist: []
    function push(a, v, n) { const o = a.concat([v]); return o.length > n ? o.slice(o.length - n) : o; }
    Process {
        running: root.open
        command: ["python3", "-I", Quickshell.shellDir + "/scripts/sysmon.py"]
        stdout: SplitParser {
            onRead: line => {
                let x;
                try { x = JSON.parse(line); } catch (e) { return; }
                root.d = x;
                root.cpuHist = root.push(root.cpuHist, x.cpu, 60);
                root.coreHist = x.cores.map((v, i) => root.push(root.coreHist[i] ?? [], v, 40));
                root.rxHist = root.push(root.rxHist, x.net.rx, 60);
                root.txHist = root.push(root.txHist, x.net.tx, 60);
            }
        }
    }
    readonly property int busy: d ? d.cores.filter(v => v >= 25).length : 0
    readonly property real avgGHz: d ? d.freqs.reduce((a, b) => a + b, 0) / d.freqs.length / 1000 : 0

    function size(b) {
        const u = ["B", "KiB", "MiB", "GiB", "TiB"];
        let i = 0;
        while (b >= 1024 && i < u.length - 1) { b /= 1024; i++; }
        return (i ? b.toFixed(b < 10 ? 1 : 0) : Math.round(b)) + " " + u[i];
    }
    function rate(b) { return size(b) + "/s"; }
    function dur(s) {
        const dd = Math.floor(s / 86400), h = Math.floor(s % 86400 / 3600), m = Math.floor(s % 3600 / 60);
        return dd ? dd + "d " + h + "h" : h ? h + "h " + m + "m" : m + "m";
    }
    function tint(v, warn, bad) { return v >= bad ? Theme.bad : v >= warn ? Theme.warn : BarState.accent; }

    // Processes: filtered and sorted here
    property string sortKey: "cpu"
    property string filter: ""
    readonly property var procs: {
        if (!d) return [];
        const q = filter.toLowerCase();
        let ps = d.procs.filter(p => !q || p.name.toLowerCase().includes(q) || (p.cmd ?? "").toLowerCase().includes(q) || String(p.pid) === q);
        const k = sortKey;
        ps.sort((a, b) => k === "name" ? a.name.localeCompare(b.name) : k === "mem" ? b.rss - a.rss : b.cpu - a.cpu || b.rss - a.rss);
        return ps;
    }
    property int confirmPid: -1
    Timer { id: confirmTimer; interval: 3000; onTriggered: root.confirmPid = -1 }
    function endProcess(pid, hard) {
        if (confirmPid !== pid) { confirmPid = pid; confirmTimer.restart(); return; }
        confirmPid = -1;
        Quickshell.execDetached(["kill", hard ? "-KILL" : "-TERM", String(pid)]);
    }

    // A line chart (0..max) with a soft fill
    component Graph: Canvas {
        property var values: []
        property real max: 100
        property color stroke: BarState.accent
        property bool autoMax: false
        onValuesChanged: requestPaint()
        onWidthChanged: requestPaint()
        onPaint: {
            const g = getContext("2d");
            g.reset();
            const v = values, n = v.length;
            if (n < 2) return;
            const hi = autoMax ? Math.max(1, ...v) * 1.15 : max;
            const px = i => i / (n - 1) * width, py = y => height - 1 - Math.min(1, y / hi) * (height - 2);
            g.beginPath(); g.moveTo(0, height);
            for (let i = 0; i < n; i++) g.lineTo(px(i), py(v[i]));
            g.lineTo(width, height); g.closePath();
            g.fillStyle = Theme.withAlpha(stroke, 0.16); g.fill();
            g.beginPath();
            for (let i = 0; i < n; i++) i ? g.lineTo(px(i), py(v[i])) : g.moveTo(px(i), py(v[i]));
            g.strokeStyle = stroke; g.lineWidth = 1.5; g.stroke();
        }
    }
    component Card: Rectangle {
        radius: 14
        color: Theme.bgAlt
        border.color: Theme.border
    }
    component Head: Label { font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 0.8; color: Theme.fgDim }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: (root.d ? col.implicitHeight : 120) + 28
        radius: 18
        color: Theme.bg
        border.color: Theme.border
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.98
        transformOrigin: Item.TopRight
        Behavior on opacity { NumberAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on implicitHeight { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        clip: true
        focus: root.open
        Keys.onEscapePressed: root.cpuDetail ? (root.cpuDetail = false) : (BarState.monitorOn = "")

        Label {
            anchors.centerIn: parent
            visible: !root.d
            text: "Reading the system…"
            dim: true
        }

        ColumnLayout {
            id: col
            visible: !!root.d
            x: 14
            y: 14
            width: parent.width - 28
            spacing: 10

            // ---------------- Header ----------------
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Glyph { text: ""; font.pixelSize: 16; color: BarState.accent }
                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Label { text: "System monitor"; font.pixelSize: 14; font.weight: Font.DemiBold }
                    Label {
                        Layout.fillWidth: true
                        dim: true
                        font.pixelSize: 11
                        text: root.d ? "up " + root.dur(root.d.uptime) + "  ·  load " + root.d.load.map(l => l.toFixed(2)).join("  ")
                                       + "  ·  " + root.d.nprocs + " processes" : ""
                    }
                }
                IconButton {
                    icon: ""; iconSize: 12; implicitWidth: 32; implicitHeight: 28
                    onClicked: { BarState.monitorOn = ""; Quickshell.execDetached(["kitty", "--class", "btop", "-T", "btop", "-e", "btop"]); }
                }
                IconButton { icon: ""; iconSize: 12; implicitWidth: 32; implicitHeight: 28; onClicked: BarState.monitorOn = "" }
            }

            // ---------------- CPU · memory / storage · network ----------------
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 10
                rowSpacing: 10

                // CPU (summary; click: every thread)
                Card {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 108
                    border.color: root.cpuDetail ? BarState.accent : cpuMouse.containsMouse ? Theme.withAlpha(BarState.accent, 0.5) : Theme.border
                    color: cpuMouse.containsMouse ? Theme.bgHover : Theme.bgAlt
                    MouseArea { id: cpuMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.cpuDetail = !root.cpuDetail }
                    Graph { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 1; height: 30; values: root.cpuHist; opacity: 0.7 }
                    ColumnLayout {
                        x: 12; y: 10
                        width: parent.width - 24
                        spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            Head { text: "CPU" }
                            Item { Layout.fillWidth: true }
                            Glyph { text: root.cpuDetail ? "" : ""; font.pixelSize: 9; color: Theme.fgDim }
                        }
                        RowLayout {
                            spacing: 10
                            Label { text: Math.round(root.d?.cpu ?? 0) + "%"; font.pixelSize: 22; font.weight: Font.Bold; font.features: { "tnum": 1 }
                                    color: (root.d?.cpu ?? 0) >= 80 ? root.tint(root.d.cpu, 80, 95) : Theme.fg }
                            Label { text: (root.d?.temps.cpu ?? 0) + " °C"; font.pixelSize: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 }
                                    color: (root.d?.temps.cpu ?? 0) >= 80 ? root.tint(root.d.temps.cpu, 80, 90) : Theme.fg }
                            Label { text: root.avgGHz.toFixed(2) + " GHz"; dim: true; font.pixelSize: 12; font.features: { "tnum": 1 } }
                        }
                        Label {
                            dim: true
                            font.pixelSize: 11
                            text: root.d ? root.d.physCores + " cores · " + root.d.cores.length + " threads · " + root.busy + " busy" : ""
                        }
                    }
                }

                // Memory: used · cache · free, and swap
                Card {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: 108
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Head { text: "MEMORY" }
                            Item { Layout.fillWidth: true }
                            Label { text: memBar.m ? root.size(memBar.m.used) + " / " + root.size(memBar.m.total) : ""; font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                        }
                        Rectangle {
                            id: memBar
                            readonly property var m: root.d?.mem
                            Layout.fillWidth: true
                            height: 10
                            radius: 5
                            color: Theme.track
                            clip: true
                            Row {
                                anchors.fill: parent
                                Rectangle { height: parent.height; width: memBar.m ? memBar.width * memBar.m.used / memBar.m.total : 0; color: root.tint(memBar.m ? 100 * memBar.m.used / memBar.m.total : 0, 80, 92) }
                                Rectangle { height: parent.height; width: memBar.m ? memBar.width * Math.min(memBar.m.cache, memBar.m.avail) / memBar.m.total : 0; color: Theme.withAlpha(Theme.accent2, 0.55) }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Label { text: "● used"; color: BarState.accent; font.pixelSize: 10 }
                            Label { text: "● cache " + (memBar.m ? root.size(memBar.m.cache) : ""); color: Theme.accent2; font.pixelSize: 10 }
                        }
                        Label { text: "swap " + (memBar.m ? root.size(memBar.m.swapUsed) + " / " + root.size(memBar.m.swapTotal) : ""); dim: true; font.pixelSize: 10; font.features: { "tnum": 1 } }
                    }
                }

                // Storage and I/O
                Card {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    implicitHeight: Math.max(84, diskCol.implicitHeight + 22)
                    ColumnLayout {
                        id: diskCol
                        x: 12; y: 11
                        width: parent.width - 24
                        spacing: 5
                        RowLayout {
                            Layout.fillWidth: true
                            Head { text: "STORAGE" }
                            Item { Layout.fillWidth: true }
                            Label { text: root.d ? "↓ " + root.rate(root.d.io.read) + "  ↑ " + root.rate(root.d.io.write) : ""; dim: true; font.pixelSize: 10; font.features: { "tnum": 1 } }
                        }
                        // A fixed count (the disks don't change): rows stay, bars don't regrow
                        Repeater {
                            model: root.d?.disks.length ?? 0
                            delegate: RowLayout {
                                required property int index
                                readonly property var disk: root.d?.disks[index] ?? ({ mount: "", used: 0, total: 1 })
                                Layout.fillWidth: true
                                spacing: 8
                                Label { text: disk.mount; font.pixelSize: 10; Layout.preferredWidth: 58; font.family: "JetBrains Mono" }
                                Bar { Layout.fillWidth: true; value: Math.round(1000 * disk.used / disk.total) / 1000; fillColor: root.tint(100 * disk.used / disk.total, 90, 97) }
                                Label { text: Math.round(100 * disk.used / disk.total) + "%"; dim: true; font.pixelSize: 10; font.features: { "tnum": 1 }; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }
                }

                // Network
                Card {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    implicitHeight: 84
                    Graph { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 1; height: parent.height - 34; values: root.rxHist; autoMax: true }
                    Graph { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 1; height: parent.height - 34; values: root.txHist; autoMax: true; stroke: Theme.accent2 }
                    RowLayout {
                        x: 12; y: 11
                        width: parent.width - 24
                        Head { text: "NETWORK" }
                        Item { Layout.fillWidth: true }
                        Label { text: root.d ? "↓ " + root.rate(root.d.net.rx) : ""; color: BarState.accent; font.pixelSize: 11; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                        Label { text: root.d ? "↑ " + root.rate(root.d.net.tx) : ""; color: Theme.accent2; font.pixelSize: 11; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                    }
                }
            }

            // ---------------- CPU detail: every thread ----------------
            Card {
                visible: root.cpuDetail
                Layout.fillWidth: true
                implicitHeight: cpuCol.implicitHeight + 24
                ColumnLayout {
                    id: cpuCol
                    x: 12; y: 12
                    width: parent.width - 24
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Head { text: "THREADS" }
                        Label {
                            Layout.fillWidth: true
                            dim: true
                            font.pixelSize: 11
                            text: root.d ? root.d.model.replace(/\(R\)|\(TM\)|CPU|Processor/g, "").replace(/\s+/g, " ").trim()
                                           + "  ·  " + (Math.min(...root.d.freqs) / 1000).toFixed(1) + "–" + (Math.max(...root.d.freqs) / 1000).toFixed(1) + " GHz now" : ""
                        }
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 6
                        columnSpacing: 6
                        rowSpacing: 6
                        Repeater {
                            model: root.d?.cores.length ?? 0
                            delegate: Rectangle {
                                required property int index
                                readonly property real v: root.d?.cores[index] ?? 0
                                Layout.fillWidth: true
                                implicitHeight: 52
                                radius: 8
                                color: Theme.withAlpha(Theme.fg, 0.035)
                                Graph { anchors.fill: parent; anchors.margins: 1; values: root.coreHist[index] ?? []; stroke: root.tint(v, 80, 95); opacity: 0.8 }
                                Label { x: 7; y: 4; text: "T" + index; dim: true; font.pixelSize: 9; font.weight: Font.DemiBold }
                                Label { anchors.right: parent.right; anchors.rightMargin: 7; y: 3; text: Math.round(v) + "%"
                                        font.pixelSize: 11; font.weight: Font.DemiBold; font.features: { "tnum": 1 }; color: v >= 80 ? root.tint(v, 80, 95) : Theme.fg }
                                Label { anchors.right: parent.right; anchors.rightMargin: 7; anchors.bottom: parent.bottom; anchors.bottomMargin: 3
                                        text: ((root.d?.freqs[index] ?? 0) / 1000).toFixed(1) + " GHz"; dim: true; font.pixelSize: 9; font.features: { "tnum": 1 } }
                            }
                        }
                    }
                    // Per-core temperatures
                    Flow {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: root.d ? Object.keys(root.d.temps.cores).sort((a, b) => Number(a.split(" ")[1]) - Number(b.split(" ")[1])) : []
                            delegate: Rectangle {
                                required property string modelData
                                readonly property int t: root.d?.temps.cores[modelData] ?? 0
                                implicitWidth: tl.implicitWidth + 14
                                implicitHeight: 20
                                radius: 10
                                color: Theme.withAlpha(Theme.fg, 0.05)
                                Label { id: tl; anchors.centerIn: parent; text: parent.modelData.replace("Core ", "C") + "  " + parent.t + "°"
                                        font.pixelSize: 10; font.features: { "tnum": 1 }; color: parent.t >= 80 ? root.tint(parent.t, 80, 90) : Theme.fgDim }
                            }
                        }
                    }
                }
            }

            // ---------------- Processes ----------------
            Card {
                Layout.fillWidth: true
                implicitHeight: 262
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Head { text: "PROCESSES" }
                        Item { Layout.fillWidth: true }
                        TextField {
                            Layout.preferredWidth: 170
                            implicitHeight: 26
                            icon: ""
                            placeholder: "Filter"
                            onTextChanged: root.filter = text
                        }
                        Segmented {
                            options: [{ value: "cpu", label: "CPU" }, { value: "mem", label: "Memory" }, { value: "name", label: "Name" }]
                            value: root.sortKey
                            onSelected: v => root.sortKey = v
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        spacing: 10
                        Head { text: "PID"; Layout.preferredWidth: 50; Layout.maximumWidth: 50 }
                        Head { text: "NAME"; Layout.fillWidth: true; Layout.preferredWidth: 80 }
                        Head { text: "MEMORY"; Layout.preferredWidth: 70; Layout.maximumWidth: 70; horizontalAlignment: Text.AlignRight }
                        Head { text: "CPU"; Layout.preferredWidth: 84; Layout.maximumWidth: 84; horizontalAlignment: Text.AlignRight }
                        Item { Layout.preferredWidth: 40; Layout.maximumWidth: 40 }
                    }
                    // A fixed number of rows reading root.procs[index]: a new model every
                    // update would rebuild the list and lose the scroll position
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: 240
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle {
                            id: prow
                            required property int index
                            readonly property var modelData: root.procs[index] ?? ({ pid: 0, name: "", cmd: "", rss: 0, mem: 0, cpu: 0 })
                            visible: index < root.procs.length
                            width: ListView.view.width
                            height: visible ? 27 : 0
                            radius: 7
                            color: rowHover.hovered ? Theme.bgHover : "transparent"
                            HoverHandler { id: rowHover }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 10
                                Label { text: prow.modelData.pid; dim: true; font.pixelSize: 10; font.family: "JetBrains Mono"; Layout.preferredWidth: 50; Layout.maximumWidth: 50 }
                                Label {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 80
                                    font.pixelSize: 12
                                    textFormat: Text.StyledText
                                    text: "<b>" + prow.modelData.name + "</b>"
                                          + (prow.modelData.cmd ? "  <font color='" + Theme.fgDim + "'>" + prow.modelData.cmd.replace(/&/g, "&amp;").replace(/</g, "&lt;") + "</font>" : "")
                                }
                                Label { text: root.size(prow.modelData.rss); font.pixelSize: 11; font.features: { "tnum": 1 }; Layout.preferredWidth: 70; Layout.maximumWidth: 70; horizontalAlignment: Text.AlignRight
                                        color: prow.modelData.mem >= 10 ? Theme.warn : Theme.fg }
                                RowLayout {
                                    Layout.preferredWidth: 84
                                    Layout.maximumWidth: 84
                                    spacing: 6
                                    Bar { Layout.fillWidth: true; value: Math.min(1, prow.modelData.cpu / 25); fillColor: root.tint(prow.modelData.cpu, 25, 60) }
                                    Label { text: prow.modelData.cpu.toFixed(1) + "%"; font.pixelSize: 11; font.features: { "tnum": 1 }; Layout.preferredWidth: 38; horizontalAlignment: Text.AlignRight
                                            color: prow.modelData.cpu >= 25 ? root.tint(prow.modelData.cpu, 25, 60) : Theme.fg }
                                }
                                // End it: × once, then "End?" (Shift: kill -9)
                                Rectangle {
                                    readonly property bool confirming: root.confirmPid === prow.modelData.pid
                                    Layout.preferredWidth: 40
                                    Layout.maximumWidth: 40
                                    implicitHeight: 20
                                    radius: 10
                                    // opacity, not visible: hidden items leave the layout and the row would shift
                                    opacity: rowHover.hovered || confirming ? 1 : 0
                                    enabled: opacity > 0
                                    color: confirming ? Theme.bad : endMouse.containsMouse ? Theme.withAlpha(Theme.bad, 0.2) : "transparent"
                                    Label { anchors.centerIn: parent; text: parent.confirming ? "End?" : "×"; font.pixelSize: parent.confirming ? 10 : 14
                                            font.weight: Font.DemiBold; color: parent.confirming ? Theme.onColor(Theme.bad) : Theme.bad }
                                    MouseArea {
                                        id: endMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: m => root.endProcess(prow.modelData.pid, m.modifiers & Qt.ShiftModifier)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
