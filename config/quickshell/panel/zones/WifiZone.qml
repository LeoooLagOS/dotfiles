import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../common"
import "../services"

// ZONE: Wi-Fi (Controls tab) — two views, switched next to the title:
//   Networks  on/off tile and the nearby networks. Click a network: the
//             connected one shows its details (below), a saved one connects,
//             a new one opens a terminal with `nmcli --ask` for the password.
//             Above the list, the Ethernet device when there is one.
//   Details   a connection (services/NetInfo.qml): the connected Wi-Fi network,
//             Ethernet, or a VPN — state, speed, addresses (+ signal, band,
//             security for Wi-Fi; server for VPNs); auto-connect, disconnect,
//             forget, advanced settings (nm-connection-editor for it).
//   VPN       the VPNs saved in NetworkManager (services/Vpn.qml): click one
//             to connect, the connected one for its details; › adds or imports one.
Zone {
    id: root
    title: "Wi-Fi"
    icon: "\uf1eb"

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: (device?.networks.values ?? []).slice().sort((a, b) =>
        (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
    readonly property var connected: networks.find(n => n.connected) ?? null
    readonly property bool tabVisible: PanelState.open && Config.tabs[PanelState.tab]?.name === "Controls"
    property string view: "networks"           // "networks" | "details" | "vpn"
    property string backView: "networks"       // where the details view goes back to
    function showDetails(kind, uuid) {
        NetInfo.show(kind, uuid);
        forgetArmed = false;
        backView = kind === "vpn" ? "vpn" : "networks";
        view = "details";
    }
    property bool forgetArmed: false           // Forget asks once more
    Binding { target: NetInfo; property: "watching"; value: root.tabVisible && root.view === "details" }
    Binding { target: NetInfo; property: "listing"; value: root.tabVisible && root.view === "networks" }

    titleActions: [
        Chip { text: Tr.t("Networks"); fontSize: 10; implicitHeight: 22; active: root.view === "networks" || (root.view === "details" && root.backView === "networks"); onClicked: root.view = "networks" },
        Chip {
            text: "VPN"; fontSize: 10; implicitHeight: 22
            icon: Vpn.active ? "\uf023" : ""
            active: root.view === "vpn" || (root.view === "details" && root.backView === "vpn")
            onClicked: root.view = "vpn"
        }
    ]

    // Scan only while the Controls tab is on screen
    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.tabVisible && Networking.wifiEnabled
        when: root.device !== null
    }

    function signalIcon(s) {
        return s > 0.75 ? "\u{f0928}" : s > 0.5 ? "\u{f0925}" : s > 0.25 ? "\u{f0922}" : "\u{f091f}";
    }

    ColumnLayout {
        visible: root.view === "networks"
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 10

        ToggleTile {
            Layout.fillWidth: true
            icon: Networking.wifiEnabled ? "\uf1eb" : "\u{f05aa}"
            label: Networking.wifiEnabled ? Tr.t("On") : Tr.t("Off")
            status: !Networking.wifiHardwareEnabled ? Tr.t("Blocked by hardware switch")
                    : root.connected ? Tr.t("Connected to %1", root.connected.name)
                    : Networking.wifiEnabled ? Tr.t("Not connected") : Tr.t("Wi-Fi is off")
            active: Networking.wifiEnabled && Networking.wifiHardwareEnabled
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
            // ›: the connected network's details, or the connection editor
            onSettingsClicked: {
                if (root.connected) root.showDetails("wifi");
                else { PanelState.open = false; Quickshell.execDetached(["nm-connection-editor"]); }
            }
        }

        // Ethernet: connected → its details; plugged in but down → connect
        Rectangle {
            id: wiredRow
            readonly property var w: NetInfo.wired
            readonly property bool unplugged: !!w && w.state === "unavailable"
            visible: !!w
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 10
            color: w?.connected ? Theme.withAlpha(Theme.accent, 0.14)
                   : (wiredMouse.containsMouse && !unplugged ? Theme.bgHover : "transparent")
            border.color: Theme.border
            function activate() {
                if (w?.connected) root.showDetails("ethernet");
                else if (!unplugged) Quickshell.execDetached(["nmcli", "device", "connect", w.device]);
            }
            activeFocusOnTab: !unplugged
            Keys.onReturnPressed: activate()
            Keys.onSpacePressed: activate()
            FocusRing {}
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10
                Glyph { text: "\u{f0200}"; color: wiredRow.w?.connected ? Theme.accent : wiredRow.unplugged ? Theme.fgDim : Theme.fg; Layout.preferredWidth: 18 }
                Label {
                    Layout.fillWidth: true
                    text: "Ethernet" + (wiredRow.w?.connected && wiredRow.w.connection ? " · " + wiredRow.w.connection : "")
                    dim: wiredRow.unplugged
                    font.pixelSize: 13
                    font.weight: wiredRow.w?.connected ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                }
                Label {
                    text: wiredRow.w?.connected ? Tr.t("Connected") : wiredRow.unplugged ? Tr.t("Cable unplugged")
                        : /connecting/.test(wiredRow.w?.state ?? "") ? Tr.t("Connecting…") : Tr.t("Click to connect")
                    dim: true
                    font.pixelSize: 11
                }
                Glyph { visible: !!wiredRow.w?.connected; text: "\uf054"; font.pixelSize: 9; color: Theme.fgDim }
            }
            MouseArea {
                id: wiredMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: wiredRow.unplugged ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: wiredRow.activate()
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: Networking.wifiEnabled
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: root.networks

            delegate: Rectangle {
                id: item
                required property var modelData
                width: ListView.view.width
                height: 40
                radius: 10
                color: modelData.connected ? Theme.withAlpha(Theme.accent, 0.14)
                       : (netMouse.containsMouse ? Theme.bgHover : "transparent")

                function activate() {
                    const n = item.modelData;
                    if (n.connected) root.showDetails("wifi");
                    else if (n.known || n.security === WifiSecurityType.Open) n.connect();
                    else {
                        PanelState.open = false;
                        Quickshell.execDetached(["kitty", "--title", "Wi-Fi: " + n.name, "-e",
                                                 "nmcli", "--ask", "device", "wifi", "connect", n.name]);
                    }
                }
                // Keyboard: Tab to a network, Enter/Space connects or disconnects
                activeFocusOnTab: true
                Keys.onReturnPressed: activate()
                Keys.onEnterPressed: activate()
                Keys.onSpacePressed: activate()
                FocusRing {}

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10

                    Glyph { text: root.signalIcon(item.modelData.signalStrength); color: item.modelData.connected ? Theme.accent : Theme.fg; Layout.preferredWidth: 18 }
                    Label {
                        Layout.fillWidth: true
                        text: item.modelData.name
                        font.pixelSize: 13
                        font.weight: item.modelData.connected ? Font.DemiBold : Font.Normal
                    }
                    Label {
                        text: item.modelData.stateChanging ? "…" : item.modelData.connected ? Tr.t("Connected") : item.modelData.known ? Tr.t("Saved") : ""
                        dim: true
                        font.pixelSize: 11
                    }
                    Glyph {
                        visible: item.modelData.security !== WifiSecurityType.Open
                        text: "\uf023"
                        font.pixelSize: 10
                        color: Theme.fgDim
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: item.activate()
                }
            }

            Label {
                anchors.centerIn: parent
                visible: parent.count === 0
                text: Tr.t("Scanning…")
                dim: true
            }
        }

        Item { Layout.fillHeight: true; visible: !Networking.wifiEnabled }
    }

    // ---------------- Details view ----------------
    // Back to the list when the network goes away
    Connections {
        target: NetInfo
        function onInfoChanged() { if (root.view === "details" && !NetInfo.info && !NetInfo.reading) root.view = root.backView; }
    }
    ColumnLayout {
        id: details
        visible: root.view === "details"
        readonly property var i: NetInfo.info ?? {}
        readonly property string kind: NetInfo.kind
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 10

        // Network: name, state, back
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 58
            radius: 12
            color: Theme.withAlpha(Theme.accent, 0.14)
            border.color: Theme.withAlpha(Theme.accent, 0.55)
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 12
                Rectangle {
                    implicitWidth: 36; implicitHeight: 36; radius: 18
                    color: Theme.accent
                    Glyph {
                        anchors.centerIn: parent
                        text: details.kind === "ethernet" ? "\u{f0200}" : details.kind === "vpn" ? "\uf023"
                            : root.signalIcon((details.i.signal ?? 0) / 100)
                        font.pixelSize: 16
                        color: Theme.accentText
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: details.i.name || (details.kind === "ethernet" ? "Ethernet" : "…"); font.pixelSize: 14; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label {
                        text: details.kind === "wifi"
                              ? Tr.t("Connected") + (details.i.band ? " · " + details.i.band : "") + (details.i.channel ? " · " + Tr.t("channel %1", details.i.channel) : "")
                            : details.kind === "ethernet"
                              ? (details.i.connected ? Tr.t("Connected") : Tr.t("Disconnected")) + (details.i.speed ? " · " + details.i.speed : "") + " · Ethernet"
                            : (details.i.active ? Tr.t("Connected") : Tr.t("Disconnected")) + " · " + (details.i.type ?? "VPN")
                        dim: true; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                }
                IconButton {
                    icon: "\uf053"
                    iconSize: 11; implicitWidth: 30; implicitHeight: 26
                    onClicked: root.view = root.backView
                }
            }
        }

        // Signal
        StatRow {
            visible: details.kind === "wifi"
            Layout.fillWidth: true
            icon: "\uf1eb"
            label: Tr.t("Signal")
            value: (details.i.signal ?? 0) + "%"
            ratio: (details.i.signal ?? 0) / 100
            barColor: Theme.lowLevel((details.i.signal ?? 0) / 100, 0.45, 0.25)
        }

        // Facts: label · value (selectable, so addresses can be copied)
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 14
            rowSpacing: 7
            Repeater {
                model: (details.kind === "wifi" ? [
                    [Tr.t("Speed"), details.i.rate ?? ""],
                    [Tr.t("Security"), details.i.security || Tr.t("Open")]
                ] : details.kind === "ethernet" ? [
                    [Tr.t("Speed"), details.i.speed ?? ""],
                    [Tr.t("Interface"), details.i.device ?? ""]
                ] : [
                    [Tr.t("Server"), details.i.server ?? ""],
                    [Tr.t("Interface"), details.i.device ?? ""]
                ]).concat([
                    ["IPv4", details.i.ip4 ?? ""],
                    [Tr.t("Gateway"), details.i.gateway ?? ""],
                    ["DNS", (details.i.dns ?? []).join(", ")],
                    ["IPv6", (details.i.ip6 ?? [])[0] ?? ""],
                    ["MAC", details.kind === "vpn" ? "" : details.i.mac ?? ""]
                ]).filter(r => r[1] !== "")
                delegate: Item {
                    required property var modelData
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    implicitHeight: factValue.implicitHeight
                    Label { text: parent.modelData[0]; dim: true; font.pixelSize: 12; width: 70 }
                    TextEdit {
                        id: factValue
                        x: 78
                        width: parent.width - x
                        text: parent.modelData[1]
                        readOnly: true
                        selectByMouse: true
                        wrapMode: TextEdit.WrapAnywhere
                        color: Theme.fg
                        selectionColor: Theme.withAlpha(Theme.accent, 0.35)
                        font.family: Theme.font
                        font.pixelSize: 12
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label { text: Tr.t("Connect automatically"); font.pixelSize: 13; Layout.fillWidth: true }
            Switch { checked: details.i.autoconnect ?? false; onToggled: NetInfo.setAutoconnect(!(details.i.autoconnect ?? false)) }
        }

        Item { Layout.fillHeight: true }

        Label {
            visible: NetInfo.error !== ""
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: 11
            color: Theme.bad
            text: NetInfo.error
        }
        RowLayout {
            spacing: 6
            Chip {
                visible: details.kind === "wifi" || !!(details.i.active || details.i.connected)
                text: Tr.t("Disconnect"); icon: "\uf127"
                onClicked: { NetInfo.disconnect(); root.view = root.backView; }
            }
            Chip {
                visible: details.kind !== "ethernet"
                text: root.forgetArmed ? Tr.t("Forget it? Click again") : Tr.t("Forget")
                icon: "\uf1f8"
                filled: root.forgetArmed
                tint: Theme.bad
                onClicked: {
                    if (!root.forgetArmed) { root.forgetArmed = true; return; }
                    NetInfo.forget();
                    root.view = root.backView;
                }
            }
            Chip { text: Tr.t("Advanced"); icon: "\uf013"; onClicked: NetInfo.edit() }
        }
    }

    // ---------------- VPN view ----------------
    ColumnLayout {
        visible: root.view === "vpn"
        width: parent.width
        height: root.height - root.headerHeight - Theme.zonePadding
        spacing: 10

        ToggleTile {
            Layout.fillWidth: true
            icon: Vpn.active ? "\uf023" : "\uf09c"
            label: Vpn.active ? Vpn.active.name : Tr.t("VPN off")
            status: Vpn.busy ? Tr.t("Switching…")
                  : Vpn.active ? Tr.t("%1 · traffic goes through the VPN", Vpn.active.type)
                  : Vpn.connections.length ? Tr.t("Pick a connection below") : Tr.t("No VPN saved")
            active: !!Vpn.active
            // On: turn the active one off; off: the first saved one on
            onToggled: { const c = Vpn.active ?? Vpn.connections[0]; if (c && !Vpn.busy) Vpn.toggle(c); }
            onSettingsClicked: { PanelState.open = false; Vpn.add(); }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            boundsBehavior: Flickable.StopAtBounds
            model: Vpn.connections

            delegate: Rectangle {
                id: vpnItem
                required property var modelData
                width: ListView.view.width
                height: 40
                radius: 10
                color: modelData.active ? Theme.withAlpha(Theme.accent, 0.14)
                       : (vpnMouse.containsMouse ? Theme.bgHover : "transparent")

                activeFocusOnTab: true
                function activate() {
                    if (modelData.active) root.showDetails("vpn", modelData.uuid);
                    else if (!Vpn.busy) Vpn.toggle(modelData);
                }
                Keys.onReturnPressed: activate()
                Keys.onSpacePressed: activate()
                FocusRing {}

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    Glyph { text: vpnItem.modelData.active ? "\uf023" : "\uf09c"; color: vpnItem.modelData.active ? Theme.accent : Theme.fg; Layout.preferredWidth: 18 }
                    Label {
                        Layout.fillWidth: true
                        text: vpnItem.modelData.name
                        font.pixelSize: 13
                        font.weight: vpnItem.modelData.active ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                    }
                    Label {
                        text: Vpn.busy === vpnItem.modelData.uuid ? "…" : vpnItem.modelData.active ? Tr.t("Connected") : vpnItem.modelData.type
                        dim: true
                        font.pixelSize: 11
                    }
                }
                MouseArea {
                    id: vpnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: vpnItem.activate()
                }
            }

            // Nothing saved yet
            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width - 40
                visible: parent.count === 0
                spacing: 8
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    dim: true
                    text: Tr.t("No VPN connections saved in NetworkManager.")
                }
                Chip {
                    Layout.alignment: Qt.AlignHCenter
                    text: Tr.t("Add or import a VPN")
                    icon: "\uf067"
                    onClicked: { PanelState.open = false; Vpn.add(); }
                }
            }
        }

        Label {
            visible: Vpn.error !== ""
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: 11
            color: Theme.bad
            text: Vpn.error
        }
    }
}
