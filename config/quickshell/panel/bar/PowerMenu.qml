import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../common"
import "../services"

// The power menu: a card that drops from the bar's power button
// (BarState.powerOn; IPC `power`, CTRL ALT Del through scripts/wm/Wlogout.sh).
// The actions stacked: Lock goes on a click (or L); the others have to be held
// (mouse or their key) for HOLD ms so a stray click or key can't end the
// session: the row fills with the accent, and letting go early drains it.
// Closes on a click outside, Esc, or the button again. It replaces
// scripts/wm/PowerMenu.py, still the fallback when the panel isn't running.
// Centered (CTRL ALT P, IPC `power`): the same, big in the middle of the
// screen over a dim, `span` wide (TopBar.qml: the center islands and half the
// gap to the side ones) and 2:3 (width:height), centered in the room below the
// bar; the user's name on top, the rows sharing the rest.
PanelWindow {
    id: root
    property var barWindow: null
    property real rightOffset: 8          // from the screen's right edge to the power button's right edge
    property string screenName: ""
    property bool centered: false         // set once: the window's anchors depend on it
    property real span: 400               // centered: the card's width
    readonly property bool open: screenName !== "" && BarState.powerOn === screenName && BarState.powerCentered === centered
    readonly property int hold: 500       // ms to hold a destructive action
    onOpenChanged: if (open) Theme.readRounding()

    readonly property string scripts: "$HOME/.config/hypr/scripts"
    readonly property var actions: [
        { key: "L", icon: "\u{f033e}", label: Tr.t("Lock"), cmd: scripts + "/LockScreen.sh", hold: false, tone: "color14" },
        { key: "O", icon: "\u{f0343}", label: Tr.t("Log out"), cmd: scripts + "/Logout.sh", hold: true, tone: "color10" },
        { key: "R", icon: "\u{f0709}", label: Tr.t("Restart"), cmd: "systemctl reboot", hold: true, tone: "color11" },
        { key: "S", icon: "\u{f0904}", label: Tr.t("Suspend"), cmd: scripts + "/LockScreen.sh; sleep 1; systemctl suspend", hold: true, tone: "color13" },
        { key: "P", icon: "\u{f0425}", label: Tr.t("Shut down"), cmd: "systemctl poweroff", hold: true, bad: true }
    ]

    // Close first, then run once the card has faded: the lock screen would
    // otherwise capture the menu still on screen
    property string pending: ""
    function run(cmd) { pending = cmd; BarState.powerOn = ""; later.restart(); }
    Timer { id: later; interval: 180; onTriggered: { Quickshell.execDetached(["bash", "-c", root.pending]); root.pending = ""; } }

    visible: open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal   // below the bar
    anchors { top: true; right: true; left: centered; bottom: centered }
    margins { top: centered ? 0 : 6; right: centered ? 0 : Math.max(8, rightOffset) }
    implicitWidth: 260
    implicitHeight: card.implicitHeight + 2

    // Centered: the screen dims behind the card; a click on it closes
    Rectangle {
        visible: root.centered
        anchors.fill: parent
        color: Theme.backdrop
        opacity: card.opacity
        MouseArea { anchors.fill: parent; onClicked: BarState.powerOn = "" }
    }
    WlrLayershell.namespace: "quickshell:bar-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    // Exclusive: opened from a key (CTRL ALT Del) its letters must work at once
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    PopupGrab {
        open: root.open
        windows: [root, root.barWindow]
        onClose: BarState.powerOn = ""
    }

    Rectangle {
        id: card
        readonly property int pad: root.centered ? 16 : 8
        width: root.centered ? Math.min(root.span, parent.width - 32) : parent.width
        height: root.centered ? Math.min(Math.round(width * 3 / 2), parent.height - 32) : implicitHeight
        x: root.centered ? Math.round((parent.width - width) / 2) : 0
        y: root.centered ? Math.round((parent.height - height) / 2) : 0
        implicitHeight: col.implicitHeight + 2 * pad
        radius: Theme.windowRadius
        color: Theme.bg
        border.color: Theme.border
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.97
        transformOrigin: root.centered ? Item.Center : Item.TopRight
        Behavior on opacity { NumberAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        // The keys: a letter pressed holds its row, released lets go
        focus: root.open
        function rowFor(e) {
            const i = root.actions.findIndex(a => a.key === e.text.toUpperCase());
            return i < 0 ? null : rows.itemAt(i);
        }
        Keys.onEscapePressed: BarState.powerOn = ""
        Keys.onPressed: e => {
            const r = rowFor(e);
            if (r && !e.isAutoRepeat) r.press();
            e.accepted = !!r;
        }
        Keys.onReleased: e => {
            const r = rowFor(e);
            if (r && !e.isAutoRepeat) r.release();
            e.accepted = !!r;
        }
        // Closing mid-hold drops it
        Connections {
            target: root
            function onOpenChanged() { for (let i = 0; i < rows.count; i++) rows.itemAt(i)?.reset(); }
        }

        ColumnLayout {
            id: col
            x: card.pad
            y: card.pad
            width: parent.width - 2 * card.pad
            height: root.centered ? parent.height - 2 * card.pad : implicitHeight
            spacing: root.centered ? 8 : 2

            // Centered: who's leaving, on top
            RowLayout {
                visible: root.centered
                Layout.fillWidth: true
                Layout.bottomMargin: 10
                spacing: 12
                ClippingRectangle {
                    implicitWidth: 48
                    implicitHeight: 48
                    radius: 24
                    color: Theme.accent2
                    Label { anchors.centerIn: parent; visible: avatar.status !== Image.Ready; text: Profile.initials; color: Theme.accent2Text; font.pixelSize: 16; font.weight: Font.DemiBold }
                    Image { id: avatar; anchors.fill: parent; source: Profile.avatar; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(96, 96); visible: status === Image.Ready }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: Profile.fullName; font.pixelSize: 16; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    Label { text: SystemStats.uptime ? Tr.t("up %1", SystemStats.uptime) : ""; dim: true; font.pixelSize: 12; Layout.fillWidth: true }
                }
            }

            Repeater {
                id: rows
                model: root.actions
                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    property real progress: 0
                    property bool holding: false
                    readonly property bool hot: mouse.containsMouse || holding
                    // Centered, each row is a pill in its own wallust color (its `tone`,
                    // color0…15 of the wallpaper; the accent if the palette isn't loaded),
                    // and everything inside grows with it (about 100 px tall on a 1080p
                    // screen): the icon in a disc two thirds of the row's height
                    // Shut down is always red (Theme.bad), whatever the wallpaper
                    readonly property color tone: modelData.bad ? Theme.bad : Theme.palette[modelData.tone] ?? BarState.accent
                    readonly property int disc: root.centered ? Math.round(height * 0.64) : 0
                    readonly property int iconPx: root.centered ? Math.round(disc * 0.5) : 16
                    readonly property int labelPx: root.centered ? Math.round(Math.max(15, Math.min(20, height * 0.18))) : 13
                    readonly property int keyPx: root.centered ? 13 : 11

                    function press() {
                        if (!modelData.hold) { root.run(modelData.cmd); return; }
                        holding = true;
                        drain.stop();
                        fill.duration = root.hold * (1 - progress);
                        fill.restart();
                    }
                    function release() {
                        if (!holding) return;
                        holding = false;
                        fill.stop();
                        drain.duration = root.hold * progress / 3;   // drains 3x faster
                        drain.restart();
                    }
                    function reset() { holding = false; fill.stop(); drain.stop(); progress = 0; }

                    NumberAnimation {
                        id: fill
                        target: row; property: "progress"; to: 1
                        onFinished: if (row.progress >= 1) { row.holding = false; root.run(row.modelData.cmd); }
                    }
                    NumberAnimation { id: drain; target: row; property: "progress"; to: 0 }

                    Layout.fillWidth: true
                    Layout.fillHeight: root.centered      // centered: the rows share the card
                    implicitHeight: 40
                    radius: root.centered ? Theme.windowRadius + 4 : Theme.innerRadius
                    clip: true
                    color: root.centered ? Theme.withAlpha(tone, hot ? 0.20 : 0.10)
                         : hot ? Theme.bgHover : "transparent"
                    border.width: root.centered ? 1 : 0
                    border.color: Theme.withAlpha(tone, hot ? 0.55 : 0.30)
                    Behavior on color { ColorAnimation { duration: Theme.anim } }
                    Behavior on border.color { ColorAnimation { duration: Theme.anim } }

                    // The hold, filling from the left
                    Rectangle {
                        width: parent.width * row.progress
                        height: parent.height
                        radius: parent.radius
                        color: Theme.withAlpha(root.centered ? row.tone : row.modelData.bad ? Theme.bad : BarState.accent, 0.35)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.centered ? Math.round((row.height - row.disc) / 2) : 12
                        anchors.rightMargin: root.centered ? Math.round(row.height * 0.2) : 10
                        spacing: root.centered ? Math.round(row.height * 0.18) : 12
                        Rectangle {
                            implicitWidth: root.centered ? row.disc : 18
                            implicitHeight: root.centered ? row.disc : 18
                            radius: Math.round(width * 0.28)      // a rounded square
                            color: root.centered ? row.tone : "transparent"
                            border.width: 0
                            Behavior on color { ColorAnimation { duration: Theme.anim } }
                            Glyph {
                                anchors.centerIn: parent
                                text: row.modelData.icon
                                font.pixelSize: row.iconPx
                                color: root.centered ? Theme.onColor(row.tone)
                                     : row.modelData.bad ? Theme.bad : row.hot ? Theme.fg : Theme.fgDim
                            }
                        }
                        Label {
                            text: row.modelData.label
                            font.pixelSize: row.labelPx
                            font.weight: root.centered ? Font.Medium : Font.Normal
                            Layout.fillWidth: true
                        }
                        Label {
                            text: row.modelData.hold ? Tr.t("hold") : Tr.t("press")
                            dim: true
                            font.pixelSize: row.keyPx - 1
                        }
                        // Its key, as a keycap
                        Rectangle {
                            implicitWidth: root.centered ? 28 : 22
                            implicitHeight: root.centered ? 26 : 20
                            radius: root.centered ? 6 : 5
                            color: Theme.bgAlt
                            border.color: Theme.border
                            Label {
                                anchors.centerIn: parent
                                text: row.modelData.key
                                dim: true
                                font.pixelSize: row.keyPx
                                font.weight: Font.DemiBold
                            }
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: row.press()
                        onReleased: row.release()
                        onCanceled: row.release()
                    }
                }
            }
        }
    }
}
