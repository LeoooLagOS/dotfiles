import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "./common"
import "./services"

// One fullscreen transparent layer per monitor; only the one on the focused
// monitor is shown. The layer respects reserved space (waybar), so its size
// is the usable screen area and the card is sized as a fraction of it.
// Only the card takes input (mask): the rest of the screen stays usable, like
// the dropdown terminal. A separate click-through layer dims/blurs the screen
// while the pointer is over the card and fades away when it leaves.
// Closes on a click outside the card (services/PanelState.qml), Esc or the keybind.
Scope {
    // Dim + blur behind the panel (Hyprland layer rule "quickshell:panel-dim").
    // Top layer: above windows, below the panel (Overlay). Hyprland fades it
    // in/out when it is shown/hidden.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: PanelState.open && PanelState.dimmed && Hyprland.focusedMonitor?.name === modelData.name
            color: Theme.backdrop
            exclusionMode: ExclusionMode.Normal   // stay out of waybar's area
            mask: Region {}                       // click-through
            anchors { top: true; bottom: true; left: true; right: true }

            WlrLayershell.namespace: "quickshell:panel-dim"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData

            readonly property bool onFocusedMonitor: Hyprland.focusedMonitor?.name === modelData.name
            visible: PanelState.open && onFocusedMonitor
            color: "transparent"
            exclusionMode: ExclusionMode.Normal   // stay out of waybar's area

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            WlrLayershell.namespace: "quickshell:panel"
            WlrLayershell.layer: WlrLayer.Overlay
            // OnDemand: the panel gets the keyboard when opened or clicked, and
            // gives it back when another window is focused (follow_mouse)
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            // Input only over the card; clicks elsewhere reach the windows below
            mask: Region { item: card }

            // Everything lives in one focus scope: keys not used by a focused
            // control (button, field, list…) bubble up here.
            //   Ctrl+Tab / Ctrl+Shift+Tab   next / previous tab
            //   Ctrl+1 … Ctrl+9             jump to a tab
            //   Esc                         close the expanded notifications, else the panel
            //   Media tab: Space play/pause, ←/→ previous/next track
            FocusScope {
                id: keyRoot
                anchors.fill: parent
                focus: true

                function step(d) {
                    const n = Config.tabs.length;
                    PanelState.tab = (PanelState.tab + d + n) % n;
                }

                // Back to the scope when switching tabs or opening (the focused control may be hidden)
                Connections {
                    target: PanelState
                    function onTabChanged() { keyRoot.forceActiveFocus(); }
                    function onOpenChanged() { if (PanelState.open) keyRoot.forceActiveFocus(); }
                }

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    if (ctrl && event.key === Qt.Key_Tab) { step(1); event.accepted = true; }
                    else if (ctrl && event.key === Qt.Key_Backtab) { step(-1); event.accepted = true; }
                    else if (ctrl && event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                        const i = event.key - Qt.Key_1;
                        if (i < Config.tabs.length) PanelState.tab = i;
                        event.accepted = true;
                    }
                    else if (event.key === Qt.Key_Escape) {
                        const onControls = Config.tabs[PanelState.tab]?.name === "Controls";
                        if (PanelState.notifDropdown) PanelState.notifDropdown = false;
                        else if (onControls && PanelState.controlsView === "settings") PanelState.controlsView = "controls";
                        else if (onControls && PanelState.controlsDetail !== "system") PanelState.controlsDetail = "system";
                        else PanelState.open = false;
                        event.accepted = true;
                    }
                    else if (Config.tabs[PanelState.tab]?.name === "Media" && Media.player) {
                        if (event.key === Qt.Key_Space) { Media.player.togglePlaying(); event.accepted = true; }
                        else if (event.key === Qt.Key_Left) { Media.player.previous(); event.accepted = true; }
                        else if (event.key === Qt.Key_Right) { Media.player.next(); event.accepted = true; }
                    }
                }

                Rectangle {
                    id: card
                    width: Math.round(root.width * Config.widthFraction)
                    height: Math.round(root.height * Config.heightFraction)
                    x: Math.round((root.width - width) / 2)
                    y: Config.topMargin
                    radius: Theme.panelRadius
                    color: Theme.bg
                    Behavior on color { ColorAnimation { duration: Theme.anim } }
                    border.color: Theme.border
                    border.width: 1

                    // Pointer over the card: dims the screen, and clicks here don't close it
                    HoverHandler {
                        id: cardHover
                        onHoveredChanged: if (root.visible) PanelState.hovered = hovered
                    }

                    // --- Tab bar ---
                    RowLayout {
                        id: tabBar
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Config.spacing
                        height: 40
                        spacing: 4

                        Repeater {
                            model: Config.tabs

                            delegate: Rectangle {
                                id: tabButton
                                required property var modelData
                                required property int index
                                readonly property bool current: PanelState.tab === index

                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                radius: Theme.buttonRadius
                                color: current ? Theme.tabBg
                                       : (tabMouse.containsMouse ? Theme.bgHover : "transparent")

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Glyph {
                                        text: tabButton.modelData.icon
                                        font.pixelSize: 14
                                        color: tabButton.current ? Theme.tabIcon : Theme.fgDim
                                    }
                                    Label {
                                        text: tabButton.modelData.name
                                        font.pixelSize: 13
                                        font.weight: tabButton.current ? Font.DemiBold : Font.Normal
                                        color: tabButton.current ? Theme.tabFg : Theme.fgDim
                                    }
                                }

                                // Accent underline on the current tab
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 28
                                    height: 3
                                    radius: 1.5
                                    color: Theme.tabLine
                                    visible: tabButton.current
                                }

                                MouseArea {
                                    id: tabMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PanelState.tab = tabButton.index
                                }
                            }
                        }
                    }

                    // --- Tab pages (all kept loaded so zones keep their state) ---
                    Item {
                        anchors.top: tabBar.bottom
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Config.spacing

                        Repeater {
                            model: Config.tabs
                            delegate: TabPage {
                                required property var modelData
                                required property int index
                                anchors.fill: parent
                                visible: PanelState.tab === index
                                rows: modelData.rows
                            }
                        }
                    }
                }

                // Overview's notifications, expanded: one card that grows from the
                // Notifications zone down to the bottom of the panel, covering the
                // zones below it (System, Media) while the ⌄ button is active.
                // Drawn here so it sits above every zone. Click outside to close.
                Item {
                    anchors.fill: parent
                    visible: PanelState.notifDropdown && Notifs.count > 0
                    z: 5

                    MouseArea { anchors.fill: parent; onClicked: PanelState.notifDropdown = false }

                    Zone {
                        id: expanded
                        readonly property rect a: PanelState.notifAnchor
                        x: a.x
                        y: a.y
                        width: a.width
                        height: card.y + card.height - Config.spacing - y
                        title: "Notifications"
                        icon: "\uf0f3"
                        badge: Notifs.count > 0 ? String(Notifs.count) : ""

                        MouseArea { parent: expanded; anchors.fill: parent; z: -1 }   // keep clicks inside

                        actions: [
                            IconButton {
                                icon: Notifs.dnd ? "\uf1f6" : "\uf0f3"
                                iconSize: 12; implicitWidth: 30; implicitHeight: 26
                                active: Notifs.dnd
                                onClicked: Notifs.toggleDnd()
                            },
                            IconButton {
                                icon: "\uf1f8"
                                iconSize: 12; implicitWidth: 30; implicitHeight: 26
                                visible: Notifs.count > 0
                                onClicked: { Notifs.clearAll(); PanelState.notifDropdown = false; }
                            },
                            IconButton {
                                icon: "\uf077"
                                iconSize: 11; implicitWidth: 30; implicitHeight: 26
                                active: true
                                onClicked: PanelState.notifDropdown = false
                            }
                        ]

                        ListView {
                            width: parent.width
                            height: expanded.height - expanded.headerHeight - Theme.zonePadding
                            spacing: 6
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            model: Notifs.list
                            delegate: NotificationCard {
                                required property var modelData
                                width: ListView.view.width
                                notif: modelData
                                compact: true
                                showApp: true
                            }
                        }
                    }
                }

            }
        }
    }
}
