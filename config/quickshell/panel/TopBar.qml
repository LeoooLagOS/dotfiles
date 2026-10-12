import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import "./common"
import "./services"
import "./bar"

// The top bar, one per monitor (replaces waybar; Settings → Bar, services/BarState.qml).
//   left     distro logo (system menu: scripts/wm/RofiSystemMenu.sh) · tray
//            (bar/TrayModule.qml) ·
//            workspaces with their apps · the focused window's app and title
//            (bar/WindowTitle.qml) and, its twin on the right, the music
//            playing or the weather (bar/Glance.qml; the island grown is its bigger view)
//   center   notifications (click: the panel's Notifications · right click:
//            Do Not Disturb) · the island (bar/Island.qml) · caffeine
//   right    CPU, RAM, disk, temperature · Wi-Fi, Bluetooth, battery ·
//            power menu. Clicking the readings opens the
//            system monitor (bar/SystemMonitor.qml), the network / battery the
//            system popup (bar/SystemPopup.qml); hovering one shows its details (bar/BarTip.qml)
// The layer is taller than the bar so the island can grow and the details can
// show below it; only the bar's groups take input (mask), and only the bar's
// height is reserved (exclusiveZone). While the panel dims the screen, the
// bar's strip is dimmed and blurred too, around and behind its groups.
Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property var modelData

            PanelWindow {
                id: win
                screen: perScreen.modelData
                visible: BarState.enabled && !hidden
                property bool hidden: false
                readonly property int h: Settings.v.barHeight
                readonly property bool islands: Settings.v.barStyle === "islands"
                readonly property bool floating: Settings.v.barStyle === "floating"
                readonly property int top: islands || floating ? 6 : 0
                readonly property var monitor: Hyprland.monitorFor(screen)

                anchors { top: true; left: true; right: true }
                implicitHeight: 620
                exclusiveZone: top + h
                exclusionMode: ExclusionMode.Normal
                color: "transparent"
                WlrLayershell.namespace: "quickshell:bar"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                mask: Region {
                    item: barArea
                    Region { item: island }
                    Region { item: tray.dropdown }
                }

                // The tray's list closes on a click anywhere else
                PopupGrab {
                    open: tray.open
                    windows: [win]
                    onClose: tray.open = false
                }
                Connections {
                    target: BarState
                    function onPopupOnChanged() { if (BarState.popupOn) tray.open = false; }
                    function onMonitorOnChanged() { if (BarState.monitorOn) tray.open = false; }
                }
                Connections { target: PanelState; function onOpenChanged() { if (PanelState.open) tray.open = false; } }

                // The panel's dim (Panel.qml's "quickshell:panel-dim" layer stays out
                // of the bar's reserved strip): the same backdrop here, blurred by
                // the bar's layer rule, so the strip looks like the rest of the screen
                Rectangle {
                    width: parent.width
                    height: win.top + win.h
                    color: Theme.backdrop
                    opacity: PanelState.open && PanelState.dimmed && Hyprland.focusedMonitor?.name === win.screen.name ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                // SUPER CTRL ALT B (IPC barToggle)
                Connections { target: BarState; function onToggleRequested() { win.hidden = !win.hidden; } }

                function openTab(name) {
                    BarState.popupOn = "";
                    if (PanelState.open && Config.tabs[PanelState.tab]?.name === name) PanelState.open = false;
                    else { PanelState.open = true; PanelState.goTo(name, ""); }
                }
                function zone(id) { return [].concat(Settings.v.barLeft, Settings.v.barCenter, Settings.v.barRight).includes(id); }
                function lvl(v, warn, bad) { return v >= bad ? "bad" : v >= warn ? "warn" : ""; }

                // Background for the full and floating styles
                Rectangle {
                    id: barArea
                    x: win.floating ? 8 : 0
                    y: win.top
                    width: parent.width - 2 * x
                    height: win.h
                    radius: win.floating ? 14 : 0
                    color: win.islands ? "transparent" : Theme.bg
                    border.width: win.islands ? 0 : 1
                    border.color: Theme.border
                    Behavior on color { ColorAnimation { duration: Theme.anim } }

                    // ---------------- Left ----------------
                    Row {
                        id: left
                        anchors.left: parent.left
                        anchors.leftMargin: win.islands ? 8 : 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // The distro's logo alone, no card behind it (like a start
                        // button): grows and brightens under the pointer
                        Item {
                            id: logo
                            visible: win.zone("logo")
                            implicitWidth: Settings.v.barHeight - 8
                            implicitHeight: Settings.v.barHeight - 8
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.height
                                height: width
                                radius: width / 2
                                color: BarState.accent
                                opacity: logoMouse.containsMouse ? 0.16 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.anim } }
                            }
                            Glyph {
                                anchors.centerIn: parent
                                optical: true
                                text: Profile.distroLogo || ""
                                font.pixelSize: 20
                                color: logoMouse.containsMouse ? Qt.lighter(BarState.accent, 1.2) : BarState.accent
                                scale: logoMouse.pressed ? 0.9 : logoMouse.containsMouse ? 1.1 : 1
                                Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }
                                Behavior on color { ColorAnimation { duration: Theme.anim } }
                            }
                            MouseArea {
                                id: logoMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: m => m.button === Qt.RightButton
                                    ? (PanelState.open = true, PanelState.openSettings("bar"))
                                    : Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/RofiSystemMenu.sh"])
                            }
                        }
                        TrayModule {
                            id: tray
                            visible: win.zone("tray")
                            barWindow: win
                            alignLeft: true
                            onOpenChanged: if (open) { BarState.popupOn = ""; BarState.monitorOn = ""; }
                        }
                        Workspaces {
                            id: workspaces
                            readonly property real natural: contentWidth + 2 * pad
                            implicitWidth: Math.max(natural, details.match(workspaces, [logo, tray, workspaces], left.anchors.leftMargin))
                            visible: win.zone("workspaces")
                            monitor: win.monitor
                        }
                    }

                    // ---------------- The details: window title · music or weather ----------------
                    // Each one fills from its side's fixed group (logo · tray · workspaces,
                    // readings · power) toward the center, up to a gap that is the
                    // same on both sides between it and the center group (bell ·
                    // island · caffeine): Settings → Bar → Gap to the center. While the
                    // island stretches in the bar (messages) they shrink with it, and
                    // one too narrow to read hides. The right one follows the island
                    // grown (its bigger view): see below.
                    QtObject {
                        id: details
                        readonly property real mid: barArea.width / 2
                        readonly property real leftEnd: left.x + left.width + 8
                        readonly property real rightStart: right.x - 8
                        // How far the center group reaches, the longer side (the island is centered).
                        // Held while the island is grown (player, weather): it hangs below the bar
                        readonly property real liveReach: Math.max(mid - (bell.visible ? bell.x : island.x),
                            (caffeine.visible ? caffeine.x + caffeine.width : island.x + island.width) - mid)
                        property real reach: 0
                        onLiveReachChanged: if (!island.grown) reach = liveReach
                        readonly property Connections follow: Connections {
                            target: island
                            function onGrownChanged() { if (!island.grown) details.reach = details.liveReach; }
                        }
                        readonly property real inner: reach + Settings.v.barDetailGap
                        readonly property int wLeft: Math.max(0, mid - inner - leftEnd)
                        readonly property int wRight: Math.max(0, rightStart - mid - inner)
                        // Both hide while the panel is open on this monitor, and the
                        // readings and connections show their icons alone (StatItem.compact);
                        // then both sides measure the same: the narrower one's middle
                        // card (workspaces, readings) widens to the other's width
                        readonly property bool panelOpen: PanelState.open && Hyprland.focusedMonitor?.name === win.screen.name
                        // Each side's width with its cards as wide as their content, from the screen's edge
                        function natural(items, margin) {
                            const shown = items.filter(i => i.visible);
                            return margin + shown.reduce((a, i) => a + (i.natural ?? i.width), 0) + Math.max(0, shown.length - 1) * 8;
                        }
                        readonly property real side: Math.max(natural([logo, tray, workspaces], left.anchors.leftMargin),
                                                              natural([stats, conn, power], right.anchors.rightMargin))
                        // How wide the middle card has to be for its side to measure `side`
                        function match(card, items, margin) {
                            return panelOpen ? side - natural(items, margin) + card.natural : 0;
                        }
                    }
                    WindowTitle {
                        visible: win.zone("window") && details.wLeft >= 100
                        hide: details.panelOpen
                        fixedWidth: details.wLeft
                        x: Math.round(details.mid - details.inner - details.wLeft)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    // While music plays the twin is the music: the weather stays
                    // at hand in a small pill at its inner edge (the gap unchanged).
                    // The island grown is the twin's bigger view: showing the
                    // player, the twin turns to the whole weather; showing the
                    // weather, the twin hides.
                    BarPill {
                        id: miniWeather
                        readonly property bool wanted: win.zone("glance") && Media.active && Weather.ready
                                                       && !island.grown && !details.panelOpen && details.wRight >= 100 + width + 8
                        visible: wanted
                        x: Math.round(details.mid + details.inner)
                        anchors.verticalCenter: parent.verticalCenter
                        clickable: true
                        spacing: 5
                        onClicked: win.openTab("Weather")
                        Glyph { optical: true; text: Weather.icon; font.pixelSize: 14; color: BarState.accent; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: Math.round(Weather.temp) + "°"; font.pixelSize: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 }; anchors.verticalCenter: parent.verticalCenter }
                    }
                    Glance {
                        readonly property int shift: miniWeather.wanted ? miniWeather.width + 8 : 0
                        visible: win.zone("glance") && details.wRight >= 100
                        hide: island.mode === "weather" || details.panelOpen
                        weatherOnly: island.mode === "expanded"
                        fixedWidth: details.wRight - shift
                        x: Math.round(details.mid + details.inner + shift)
                        anchors.verticalCenter: parent.verticalCenter
                        onOpenTab: name => win.openTab(name)
                    }

                    // ---------------- Center: bell · island · caffeine ----------------
                    // The island: centered on the screen, at the bar's top; it
                    // grows down past the bar (barArea doesn't clip)
                    Island {
                        id: island
                        visible: win.zone("island")
                        x: Math.round((barArea.width - width) / 2)
                        y: 3
                    }

                        BarPill {
                            id: bell
                            // Always one icon wide (the bar's gaps stay even): the bell, in the
                            // accent while there are notifications; a new one shows the count
                            // instead of the bell for a second
                            readonly property bool unread: !Notifs.dnd && Notifs.count > 0
                            property int seen: 0
                            Component.onCompleted: seen = Notifs.count
                            readonly property bool counting: countFlash.running
                            Timer { id: countFlash; interval: 1000 }
                            Connections {
                                target: Notifs
                                function onCountChanged() {
                                    if (Notifs.count > bell.seen && !Notifs.dnd) countFlash.restart();
                                    bell.seen = Notifs.count;
                                }
                            }
                            visible: win.zone("bell")
                            anchors.right: island.left
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            square: true
                            clickable: true
                            active: Notifs.dnd
                            onClicked: b => {
                                if (b === Qt.RightButton) {
                                    Notifs.toggleDnd();
                                    BarState.say(Notifs.dnd ? "" : "", Notifs.dnd ? "Do Not Disturb on" : "Do Not Disturb off");
                                } else win.openTab("Notifications");
                            }
                            Glyph { optical: true; visible: !bell.counting; text: Notifs.dnd ? "" : ""; font.pixelSize: 14; color: Notifs.dnd || bell.unread ? BarState.accent : Theme.fg }
                            Label {
                                visible: bell.counting
                                text: Notifs.count > 99 ? "99+" : Notifs.count
                                color: BarState.accent
                                font.pixelSize: Notifs.count > 99 ? 10 : Notifs.count > 9 ? 12 : 14
                                font.weight: Font.Bold
                                font.features: { "tnum": 1 }
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                    BarPill {
                        id: caffeine
                        visible: win.zone("caffeine")
                        anchors.left: island.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        square: true
                        clickable: true
                        active: Toggles.caffeine
                        onClicked: {
                            Toggles.setCaffeine(!Toggles.caffeine, 0);
                            BarState.say(Toggles.caffeine ? "" : "\u{f06ca}", Toggles.caffeine ? "Screen stays awake" : "Idle as usual");
                        }
                        Glyph { optical: true; text: Toggles.caffeine ? "" : "\u{f06ca}"; font.pixelSize: 14; color: Toggles.caffeine ? BarState.accent : Theme.fgDim }
                    }

                    // ---------------- Right ----------------
                    Row {
                        id: right
                        anchors.right: parent.right
                        anchors.rightMargin: win.islands ? 8 : 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // Readings: hover for details, click for the system monitor
                        BarPill {
                            id: stats
                            readonly property real natural: contentWidth + 2 * pad
                            implicitWidth: Math.max(natural, details.match(stats, [stats, conn, power], right.anchors.rightMargin))
                            visible: ["cpu", "ram", "disk", "temp"].some(id => win.zone(id))
                            clickable: true
                            active: BarState.monitorOn === win.screen.name
                            spacing: 13
                            onClicked: BarState.toggleMonitor(win.screen.name)
                            StatItem {
                                visible: win.zone("cpu"); tipHost: tip
                                compact: details.panelOpen
                                icon: ""; text: SystemStats.cpu + "%"; level: win.lvl(SystemStats.cpu, 80, 95)
                                tip: ({ title: "CPU", rows: [["Usage", SystemStats.cpu + " %"], ["Temperature", SystemStats.temp + " °C"]],
                                        hist: SystemStats.cpuHist, hint: "Last minute · click: system monitor" })
                            }
                            StatItem {
                                visible: win.zone("ram"); tipHost: tip
                                compact: details.panelOpen
                                icon: "\uefc5"; text: SystemStats.memPct + "%"; level: win.lvl(SystemStats.memPct, 80, 92)
                                tip: ({ title: "Memory", rows: [["In use", SystemStats.gb(SystemStats.memUsed) + " / " + SystemStats.gb(SystemStats.memTotal) + " GiB"]],
                                        hist: SystemStats.memHist, hint: "Last minute · click: system monitor" })
                            }
                            StatItem {
                                visible: win.zone("disk"); tipHost: tip
                                compact: details.panelOpen
                                icon: "\uf0a0"; text: SystemStats.diskPct + "%"; level: win.lvl(SystemStats.diskPct, 90, 97)
                                tip: ({ title: "Disk ( / )", rows: [["Used", SystemStats.gb(SystemStats.diskUsed) + " / " + SystemStats.gb(SystemStats.diskTotal) + " GiB"],
                                                                    ["Free", SystemStats.gb(SystemStats.diskTotal - SystemStats.diskUsed) + " GiB"]] })
                            }
                            StatItem {
                                visible: win.zone("temp"); tipHost: tip
                                compact: details.panelOpen
                                icon: ""; text: SystemStats.temp + "°"; level: win.lvl(SystemStats.temp, 80, 90)
                                tip: ({ title: "CPU temperature", rows: [["Package", SystemStats.temp + " °C"]], hist: SystemStats.tempHist, min: 30, max: 100,
                                        hint: "Last minute · click: system monitor" })
                            }
                        }

                        // Network, Bluetooth, battery
                        BarPill {
                            id: conn
                            readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
                            readonly property var wifiNet: wifiDevice?.networks.values.find(n => n.connected) ?? null
                            readonly property real signal: wifiNet?.signalStrength ?? 0
                            readonly property var bt: Bluetooth.defaultAdapter
                            readonly property var btOn: Bluetooth.devices.values.filter(d => d.connected)
                            readonly property var bat: UPower.displayDevice
                            readonly property bool hasBat: !!bat && bat.isLaptopBattery
                            readonly property int pct: !bat ? 0 : Math.round(bat.percentage > 1 ? bat.percentage : bat.percentage * 100)
                            readonly property bool charging: bat?.state === UPowerDeviceState.Charging || bat?.state === UPowerDeviceState.FullyCharged
                            function dur(s) { const h = Math.floor(s / 3600), m = Math.round(s % 3600 / 60); return h ? h + " h " + m + " min" : m + " min"; }
                            visible: ["wifi", "bluetooth", "battery"].some(id => win.zone(id))
                            clickable: true
                            active: BarState.popupOn === win.screen.name
                            spacing: 12
                            onClicked: BarState.togglePopup(win.screen.name)
                            StatItem {
                                visible: win.zone("wifi"); tipHost: tip
                                compact: details.panelOpen
                                icon: !Networking.wifiEnabled ? "\u{f092d}" : !conn.wifiNet ? "\u{f092f}"
                                    : ["\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"][Math.min(3, Math.floor(conn.signal * 4))]
                                iconSize: 14
                                tip: ({ title: "Wi-Fi", rows: !Networking.wifiEnabled ? [["State", "Off"]] : conn.wifiNet
                                        ? [["Network", conn.wifiNet.name], ["Signal", Math.round(conn.signal * 100) + " %"]] : [["State", "Not connected"]] })
                            }
                            StatItem {
                                visible: win.zone("bluetooth"); tipHost: tip
                                compact: details.panelOpen
                                icon: !conn.bt?.enabled ? "\u{f00b2}" : conn.btOn.length ? "\u{f00b1}" : ""
                                text: conn.btOn.length > 0 ? String(conn.btOn.length) : ""
                                iconSize: 13
                                tip: ({ title: "Bluetooth", rows: !conn.bt?.enabled ? [["State", "Off"]]
                                        : conn.btOn.length ? conn.btOn.map(d => [d.name, d.batteryAvailable ? Math.round(d.battery * 100) + " %" : "connected"])
                                        : [["State", "No devices connected"]] })
                            }
                            StatItem {
                                visible: win.zone("battery") && conn.hasBat; tipHost: tip
                                compact: details.panelOpen
                                icon: conn.charging ? "\u{f0084}" : ["\u{f008e}", "\u{f007a}", "\u{f007b}", "\u{f007c}", "\u{f007d}", "\u{f007e}", "\u{f007f}", "\u{f0080}", "\u{f0081}", "\u{f0082}", "\u{f0079}"][Math.round(conn.pct / 10)]
                                iconSize: 14
                                text: conn.pct + "%"
                                level: conn.charging ? "" : conn.pct <= 10 ? "bad" : conn.pct <= 20 ? "warn" : ""
                                tip: ({ title: "Battery", rows: [["Charge", conn.pct + " %"],
                                        conn.bat?.state === UPowerDeviceState.FullyCharged ? ["State", "Full"]
                                        : conn.bat?.state === UPowerDeviceState.Charging ? ["Full in", conn.dur(conn.bat.timeToFull)]
                                        : ["Left", conn.bat?.timeToEmpty > 0 ? conn.dur(conn.bat.timeToEmpty) : "…"],
                                        ["Profile", PowerProfiles.profile === PowerProfile.PowerSaver ? "Power saver"
                                                  : PowerProfiles.profile === PowerProfile.Performance ? "Performance" : "Balanced"]] })
                            }
                        }

                        BarPill {
                            id: power
                            visible: win.zone("power")
                            square: true
                            clickable: true
                            onClicked: Quickshell.execDetached(["bash", "-c", Config.powerCmd])
                            Glyph { optical: true; text: ""; font.pixelSize: 13; color: Theme.bad }
                        }
                    }
                }

                BarTip {
                    id: tip
                    barBottom: win.top + win.h
                }
            }

            SystemMonitor {
                screen: perScreen.modelData
                screenName: perScreen.modelData.name
                barWindow: win
                rightOffset: barArea.x + right.anchors.rightMargin
            }

            SystemPopup {
                screen: perScreen.modelData
                screenName: perScreen.modelData.name
                barWindow: win
                rightOffset: barArea.x + right.anchors.rightMargin
            }
        }
    }
}
