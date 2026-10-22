import QtQuick
import Quickshell
import Quickshell.Wayland
import "./common"
import "./services"

// Dock under the communication apps (services/Comms.qml), like macOS's: shown
// on a monitor while one of them is up (SUPER Y). It rests half hidden below
// the screen edge (the app gets that room) and rises while the mouse is on it. An icon per app — a dot
// under the running ones, the unread count, the shown one highlighted;
// hovering grows it and names it. Click: switch to it (it starts if it isn't
// running); the shown one hides them (as does SUPER Y).
// Keyboard (SUPER SHIFT Y, Comms.dockFocus): the dock rises and takes it;
// ←/→ or Tab choose, Enter / Space open, 1–9 by position, R reload (a web
// app), Shift+R restart, Esc back to the app. From inside an app, SUPER TAB /
// SUPER SHIFT TAB go to the next / previous one (Comms.cycle).
// Right click on an icon: Reload (web apps) · Restart · Quit, for an app that
// hangs (Comms.reload / restart / quit; restarting shows on its icon).
// The app above fills the screen down to the dock: its special workspace has
// a bottom gap (UserConfigs/user_window_rules.lua) of `peek` + 6 px.
Scope {
    readonly property int iconSize: 48
    readonly property int pad: 12
    readonly property int peek: 40            // what shows of the dock at rest

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            readonly property bool up: (Comms.shownOn[modelData.name] ?? "") !== "" && !Comms.quiet
            // The dock has the keyboard (on the focused monitor)
            readonly property bool keys: up && Comms.dockFocus && Comms.focusedMonitor === modelData.name
            property int selected: 0
            onKeysChanged: if (keys) {
                selected = Math.max(0, Comms.apps.findIndex(a => a.key === Comms.shown));
                keyScope.forceActiveFocus();
            }
            function open(i) {
                const a = Comms.apps[i];
                if (!a) return;
                Comms.dockFocus = false;
                if (a.key !== Comms.shown) Comms.show(a.key);
            }

            visible: up || hideAnim.running
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors.bottom: true
            // Room above the raised dock for the grown icon and its name
            implicitWidth: Math.max(dock.width + 80, 460)
            implicitHeight: dock.height + 10 + 56

            // Raised while hovered; lowered a moment after the mouse leaves
            property bool raised: false
            readonly property bool hovering: dockHover.hovered || menuHover.hovered
            onHoveringChanged: if (hovering) { lowerTimer.stop(); raised = true; } else lowerTimer.restart()
            onUpChanged: if (!up) { raised = false; menuKey = ""; }
            readonly property bool lifted: raised || keys || menuKey !== ""
            // Right-click menu: whose, and where (its icon's center, in the window)
            property string menuKey: ""
            property real menuX: 0
            readonly property var menuApp: Comms.apps.find(a => a.key === menuKey) ?? null
            Timer { id: lowerTimer; interval: 450; onTriggered: { win.raised = false; win.menuKey = ""; } }

            WlrLayershell.namespace: "quickshell:dock"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: keys ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            FocusScope {
                id: keyScope
                anchors.fill: parent
                focus: win.keys
                Keys.onPressed: event => {
                    const n = Comms.apps.length;
                    if (!n) return;
                    const k = event.key;
                    if (k === Qt.Key_Right || k === Qt.Key_Tab || k === Qt.Key_L) win.selected = (win.selected + 1) % n;
                    else if (k === Qt.Key_Left || k === Qt.Key_Backtab || k === Qt.Key_H) win.selected = (win.selected - 1 + n) % n;
                    else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) win.open(win.selected);
                    else if (k >= Qt.Key_1 && k <= Qt.Key_9) win.open(k - Qt.Key_1);
                    else if (k === Qt.Key_R && (event.modifiers & Qt.ShiftModifier)) Comms.restart(Comms.apps[win.selected].key);
                    else if (k === Qt.Key_R) Comms.reload(Comms.apps[win.selected].key);
                    else if (k === Qt.Key_Escape) Comms.dockFocus = false;
                    else return;
                    event.accepted = true;
                }
            }
            // Only the dock takes clicks; the rest passes through to the app
            mask: Region { item: dock; Region { item: menu } }

            // Right-click menu, above the icon
            Rectangle {
                id: menu
                visible: win.menuKey !== "" && !!win.menuApp
                width: visible ? 170 : 0
                height: visible ? menuCol.implicitHeight + 12 : 0
                x: Math.max(4, Math.min(win.width - width - 4, win.menuX - width / 2))
                y: dock.y - height - 8
                radius: 12
                color: Theme.withAlpha(Theme.bgAlt, 0.96)
                border.color: Theme.border
                HoverHandler { id: menuHover }
                Column {
                    id: menuCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 6
                    spacing: 2
                    Repeater {
                        model: !win.menuApp ? []
                             : !win.menuApp.running ? [{ id: "open", label: Tr.t("Open"), icon: "\uf04b" }]
                             : (win.menuApp.web ? [{ id: "reload", label: Tr.t("Reload"), icon: "\uf021" }] : []).concat([
                                   { id: "restart", label: Tr.t("Restart"), icon: "\uf2f9" },
                                   { id: "quit", label: Tr.t("Quit"), icon: "\uf011" }])
                        delegate: Rectangle {
                            required property var modelData
                            width: menuCol.width
                            height: 30
                            radius: 8
                            color: itemMouse.containsMouse ? Theme.bgHover : "transparent"
                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10
                                Glyph { text: modelData.icon; font.pixelSize: 12; color: modelData.id === "quit" ? Theme.critical : Theme.fg; anchors.verticalCenter: parent.verticalCenter }
                                Label { text: modelData.label; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                            }
                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const k = win.menuKey;
                                    win.menuKey = "";
                                    if (modelData.id === "reload") Comms.reload(k);
                                    else if (modelData.id === "restart") Comms.restart(k);
                                    else if (modelData.id === "quit") Comms.quit(k);
                                    else Comms.show(k);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: dock
                anchors.horizontalCenter: parent.horizontalCenter
                // From the window's fixed height (its actual height changes while it maps / unmaps)
                y: !win.up ? win.implicitHeight + 8 : win.lifted ? win.implicitHeight - height - 10 : win.implicitHeight - peek
                Behavior on y { NumberAnimation { id: hideAnim; duration: 200; easing.type: Easing.OutCubic } }
                HoverHandler { id: dockHover }
                width: row.width + 2 * 10
                height: 72
                radius: 22
                color: Theme.withAlpha(Theme.bg, 0.78)
                border.color: Theme.border

                Row {
                    id: row
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: Comms.apps
                        delegate: Item {
                            id: cell
                            required property var modelData
                            required property int index
                            readonly property bool shown: Comms.shownOn[win.modelData.name] === modelData.key
                            readonly property bool chosen: win.keys && win.selected === index
                            width: 56
                            height: 56

                            // The shown app: a soft tile behind it
                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: cell.shown ? Theme.withAlpha(Theme.accent, 0.22) : "transparent"
                                border.color: cell.chosen ? Theme.accent : cell.shown ? Theme.withAlpha(Theme.accent, 0.5) : "transparent"
                                border.width: cell.chosen ? 2 : 1
                            }

                            Item {
                                id: iconBox
                                width: 44; height: 44
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -2
                                scale: mouse.containsMouse || cell.chosen ? 1.28 : 1
                                transformOrigin: Item.Bottom
                                Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
                                opacity: cell.modelData.restarting ? 0.3 : cell.modelData.running ? 1 : 0.55

                                Image {
                                    id: img
                                    anchors.fill: parent
                                    source: cell.modelData.icon
                                    sourceSize: Qt.size(96, 96)
                                    smooth: true
                                    asynchronous: true
                                }
                                // No icon: the app's initial
                                Rectangle {
                                    visible: img.status !== Image.Ready
                                    anchors.fill: parent
                                    radius: 12
                                    color: Theme.accent
                                    Label { anchors.centerIn: parent; text: cell.modelData.name[0]; color: Theme.accentText; font.pixelSize: 22; font.weight: Font.DemiBold }
                                }
                                // Unread
                                Rectangle {
                                    visible: cell.modelData.badge > 0
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: -5
                                    width: Math.max(18, badgeText.implicitWidth + 10)
                                    height: 18
                                    radius: 9
                                    color: "#ff3b30"
                                    border.color: Theme.withAlpha(Theme.bg, 0.9)
                                    border.width: 1.5
                                    Label { id: badgeText; anchors.centerIn: parent; text: cell.modelData.badge > 99 ? "99+" : cell.modelData.badge; color: "white"; font.pixelSize: 10; font.weight: Font.Bold }
                                }
                            }

                            // Running
                            Rectangle {
                                visible: cell.modelData.running
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: -5
                                width: 5; height: 5; radius: 2.5
                                color: cell.shown ? Theme.accent : Theme.fgDim
                            }

                            // Name, above the dock while hovered
                            Rectangle {
                                visible: (mouse.containsMouse || cell.chosen) && win.menuKey !== cell.modelData.key
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: -height - 26
                                width: tip.implicitWidth + 20
                                height: 26
                                radius: 8
                                color: Theme.withAlpha(Theme.bgAlt, 0.95)
                                border.color: Theme.border
                                Label {
                                    id: tip
                                    anchors.centerIn: parent
                                    font.pixelSize: 12
                                    // With the keyboard: its number, and what Enter does
                                    text: cell.modelData.restarting ? Tr.t("Restarting %1…", cell.modelData.name)
                                        : win.keys ? (cell.index + 1) + "  ·  " + cell.modelData.name
                                                     + (cell.modelData.web ? "  ·  " + Tr.t("R reload") : "") + "  ·  " + Tr.t("⇧R restart")
                                        : cell.shown ? Tr.t("Hide %1", cell.modelData.name) + "  ·  Super Y"
                                        : cell.modelData.running ? cell.modelData.name : Tr.t("Open %1", cell.modelData.name)
                                }
                            }

                            // Restarting: the icon faded, a turning arrow over it
                            Glyph {
                                visible: cell.modelData.restarting
                                anchors.centerIn: iconBox
                                text: "\uf2f9"
                                font.pixelSize: 20
                                color: Theme.accent
                                RotationAnimation on rotation { running: cell.modelData.restarting; from: 0; to: 360; duration: 900; loops: Animation.Infinite }
                            }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton) {
                                        win.menuKey = win.menuKey === cell.modelData.key ? "" : cell.modelData.key;
                                        win.menuX = cell.mapToItem(null, cell.width / 2, 0).x;
                                    } else {
                                        win.menuKey = "";
                                        Comms.pick(cell.modelData.key);
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
