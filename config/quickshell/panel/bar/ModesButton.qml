import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"

// The modes button, next to the island (vault ADR-0016; it was caffeine's):
// the active mode's icon, with a dot while caffeine is on. Click (or SUPER ALT
// M): the list of modes and for how long; its footer, caffeine and "Edit
// modes…". Right click: Settings → Modes. `dropdown` is the list, for the
// bar's input mask (TopBar.qml).
BarPill {
    id: root
    property bool open: false
    property alias dropdown: drop
    property string duration: ""                // "" until turned off · "1h" · "tomorrow"
    signal editModes()
    signal toggleRequested()                    // open is the bar's (BarState.modesOn: one monitor at a time)
    signal closeRequested()
    square: true
    clickable: true
    active: open || !Modes.isPersonal
    onClicked: b => {
        if (b === Qt.RightButton) { closeRequested(); editModes(); }
        else toggleRequested();
    }
    onOpenChanged: if (open) duration = ""

    Item {
        implicitWidth: 16
        implicitHeight: 16
        anchors.verticalCenter: parent.verticalCenter
        Glyph {
            anchors.centerIn: parent
            optical: true
            text: Modes.icon
            font.pixelSize: 13
            color: Modes.isPersonal ? Theme.fgDim : BarState.accent
        }
        // Caffeine on: a dot at the corner
        Rectangle {
            visible: Toggles.caffeine
            width: 5; height: 5; radius: 2.5
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: -3
            anchors.topMargin: -2
            color: BarState.accent
        }
    }

    // ---------------- The list ----------------
    Rectangle {
        id: drop
        parent: root
        visible: root.open
        anchors.top: parent.bottom
        anchors.topMargin: 8
        x: Math.round((parent.width - width) / 2)
        width: root.open ? 320 : 0
        height: root.open ? col.implicitHeight + 24 : 0
        radius: 16
        color: Theme.bg
        border.color: Theme.border

        ColumnLayout {
            id: col
            x: 12
            y: 12
            width: parent.width - 24
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Label { text: Tr.t("Modes"); font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true }
                // The active one: how long it has, and the way out
                Label {
                    visible: !Modes.isPersonal
                    text: Modes.pomo ? (Modes.pomo.phase === "work" ? Tr.t("Focus %1", Modes.timerText) : Tr.t("Break %1", Modes.timerText))
                        : Modes.untilText || Tr.t("Until turned off")
                    dim: true
                    font.pixelSize: 11
                }
                Chip { visible: !Modes.isPersonal; text: Tr.t("End"); onClicked: { Modes.end(); root.closeRequested(); } }
            }

            Segmented {
                Layout.fillWidth: true
                Layout.bottomMargin: 4
                options: [{ value: "", label: Tr.t("Until turned off") }, { value: "1h", label: Tr.t("1 h") }, { value: "tomorrow", label: Tr.t("Until tomorrow") }]
                value: root.duration
                onSelected: v => root.duration = v
            }

            Repeater {
                model: Modes.modes
                delegate: Rectangle {
                    id: mrow
                    required property var modelData
                    readonly property bool on: modelData.id === Modes.currentId
                    Layout.fillWidth: true
                    implicitHeight: 40
                    radius: 10
                    color: on ? Theme.withAlpha(BarState.accent, 0.16) : rowMouse.containsMouse ? Theme.bgHover : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Glyph { text: mrow.modelData.icon || ""; font.pixelSize: 14; color: mrow.on ? BarState.accent : Theme.fg; Layout.preferredWidth: 18; horizontalAlignment: Text.AlignHCenter }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { text: Modes.nameOf(mrow.modelData); font.pixelSize: 13; font.weight: mrow.on ? Font.DemiBold : Font.Normal; Layout.fillWidth: true }
                            Label {
                                visible: text !== ""
                                text: root.summary(mrow.modelData)
                                dim: true
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }
                        Glyph { visible: mrow.on; text: ""; font.pixelSize: 11; color: BarState.accent }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Modes.set(mrow.modelData.id, root.duration); root.closeRequested(); }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.topMargin: 4; height: 1; color: Theme.border }
            // Caffeine lives on (SUPER ALT I, Controls); a mode can set it too
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Glyph { text: Toggles.caffeine ? "" : "\u{f06ca}"; font.pixelSize: 13; color: Toggles.caffeine ? BarState.accent : Theme.fgDim; Layout.preferredWidth: 18; horizontalAlignment: Text.AlignHCenter }
                Label { text: Tr.t("Caffeine"); font.pixelSize: 12; Layout.fillWidth: true }
                Label { text: "SUPER ALT I"; dim: true; font.pixelSize: 10; font.family: "JetBrains Mono" }
                Switch { checked: Toggles.caffeine; onToggled: BarState.toggleCaffeine() }
            }
            Chip {
                Layout.alignment: Qt.AlignRight
                Layout.topMargin: 2
                text: Tr.t("Edit modes…")
                onClicked: { root.closeRequested(); root.editModes(); }
            }
        }
    }

    // One line under a mode's name: what it does
    function summary(m) {
        const parts = [];
        const n = m.notifications?.allow;
        if (n === "none") parts.push(Tr.t("Silence"));
        else if (n === "list") parts.push(Tr.t("Only %1", Modes.words(m.notifications.apps).concat(Modes.words(m.notifications.people)).join(", ") || "—"));
        if (m.timer?.pomodoro) parts.push(m.timer.pomodoro.work + "/" + m.timer.pomodoro.break + " min");
        else if (m.timer?.minutes) parts.push(Tr.t("%1 min", m.timer.minutes));
        if (m.caffeine === true) parts.push(Tr.t("Caffeine"));
        if (m.night === true) parts.push(Tr.t("Night light"));
        if (m.game === true) parts.push(Tr.t("Game mode"));
        if (m.dark === true) parts.push(Tr.t("Dark"));
        else if (m.dark === false) parts.push(Tr.t("Light"));
        return parts.join(" · ");
    }
}
