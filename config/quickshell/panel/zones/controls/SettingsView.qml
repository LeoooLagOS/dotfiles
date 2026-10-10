import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// Controls → ⚙: Settings, generated from Settings.sections (common/Settings.qml).
// Sections on the left, the chosen one on the right. Changes apply right away;
// a toast offers Undo. ← Settings or Esc goes back to Controls.
RowLayout {
    id: root
    spacing: Config.spacing

    readonly property var section: Settings.sections.find(s => s.id === PanelState.settingsSection) ?? Settings.sections[0]
    readonly property bool resettable: section.groups.some(g => g.rows.some(r => r.key))

    function fmt(row, v) {
        if (row.unit === "time") {
            if (v < 60) return v + " s";
            const m = v / 60;
            return m >= 60 ? (m / 60).toFixed(m % 60 ? 1 : 0) + " h" : (Number.isInteger(m) ? m : m.toFixed(1)) + " min";
        }
        return v + (row.unit ?? "");
    }

    // ---------------- Sections ----------------
    Zone {
        Layout.preferredWidth: 196
        Layout.fillHeight: true

        ColumnLayout {
            width: parent.width
            spacing: 2

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 34
                radius: 9
                color: backMouse.containsMouse || activeFocus ? Theme.bgHover : "transparent"
                activeFocusOnTab: true
                Keys.onReturnPressed: PanelState.controlsView = "controls"
                Keys.onSpacePressed: PanelState.controlsView = "controls"
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 8
                    spacing: 8
                    Glyph { text: ""; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    Label { text: "Settings"; font.pixelSize: 14; font.weight: Font.Bold }
                }
                MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: PanelState.controlsView = "controls" }
                FocusRing {}
            }
            Item { implicitHeight: 4 }

            Repeater {
                model: Settings.sections
                delegate: Rectangle {
                    id: navItem
                    required property var modelData
                    readonly property bool current: modelData.id === root.section.id
                    Layout.fillWidth: true
                    implicitHeight: 31
                    radius: 8
                    color: current ? Theme.tabBg : (navMouse.containsMouse || activeFocus ? Theme.bgHover : "transparent")
                    activeFocusOnTab: true
                    Keys.onReturnPressed: PanelState.settingsSection = modelData.id
                    Keys.onSpacePressed: PanelState.settingsSection = modelData.id
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        x: 10
                        spacing: 9
                        Glyph { text: navItem.modelData.icon; font.pixelSize: 12; width: 16; color: navItem.current ? Theme.tabIcon : Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: navItem.modelData.label; font.pixelSize: 12; font.weight: navItem.current ? Font.DemiBold : Font.Normal
                                color: navItem.current ? Theme.tabFg : Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { id: navMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: PanelState.settingsSection = navItem.modelData.id }
                    FocusRing {}
                }
            }
        }
    }

    // ---------------- Section content ----------------
    Zone {
        id: contentZone
        Layout.fillWidth: true
        Layout.fillHeight: true

        Flickable {
            id: flick
            width: parent.width
            height: contentZone.height - 2 * Theme.zonePadding
            contentHeight: col.implicitHeight + 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            Connections { target: PanelState; function onSettingsSectionChanged() { flick.contentY = 0; } }

            ColumnLayout {
                id: col
                width: flick.width - 6
                spacing: 12

                RowLayout {
                    spacing: 10
                    Label { text: root.section.label; font.pixelSize: 17; font.weight: Font.Bold }
                    Rectangle {
                        visible: !!root.section.system
                        implicitHeight: 18
                        implicitWidth: sysBadge.implicitWidth + 14
                        radius: 9
                        color: "transparent"
                        border.color: Theme.border
                        Label { id: sysBadge; anchors.centerIn: parent; text: "APPLIES TO THE SYSTEM"; dim: true; font.pixelSize: 9; font.weight: Font.DemiBold; font.letterSpacing: 0.6 }
                    }
                }
                Label { text: root.section.lead; dim: true; font.pixelSize: 12; Layout.fillWidth: true; wrapMode: Text.Wrap; Layout.topMargin: -6 }

                Repeater {
                    model: root.section.groups
                    delegate: Rectangle {
                        id: group
                        required property var modelData
                        required property int index
                        // Earlier groups/rows above later ones, so an open dropdown covers what follows
                        z: root.section.groups.length - index
                        Layout.fillWidth: true
                        implicitHeight: groupCol.implicitHeight
                        radius: 12
                        color: "transparent"
                        border.color: Theme.border

                        ColumnLayout {
                            id: groupCol
                            width: parent.width
                            spacing: 0
                            Label {
                                text: group.modelData.title.toUpperCase()
                                dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1
                                Layout.leftMargin: 12; Layout.topMargin: 9; Layout.bottomMargin: 2
                            }
                            Repeater {
                                model: group.modelData.rows
                                delegate: SettingRow {
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    z: group.modelData.rows.length - index
                                    row: modelData
                                    first: index === 0
                                    formatter: root.fmt
                                }
                            }
                        }
                    }
                }

                Chip {
                    visible: root.resettable
                    text: "Reset " + root.section.label + " to defaults"
                    icon: ""
                    onClicked: Settings.reset(root.section.id)
                }
            }
        }
    }

    // ---------------- Undo toast ----------------
    property bool undoing: false
    Connections {
        target: Settings
        function onChanged(key) {
            if (root.undoing || PanelState.controlsView !== "settings") return;
            toast.shown = true;
            toastTimer.restart();
        }
    }
    Timer { id: toastTimer; interval: 3500; onTriggered: toast.shown = false }
    Rectangle {
        id: toast
        property bool shown: false
        parent: contentZone
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: shown ? 14 : -height
        opacity: shown ? 1 : 0
        Behavior on anchors.bottomMargin { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }
        z: 20
        implicitHeight: 34
        implicitWidth: toastRow.implicitWidth + 22
        radius: 17
        color: Theme.fg
        RowLayout {
            id: toastRow
            anchors.centerIn: parent
            spacing: 12
            Label { text: "Saved"; color: Theme.bgAlt; font.pixelSize: 12 }
            Rectangle {
                implicitHeight: 24
                implicitWidth: undoLabel.implicitWidth + 20
                radius: 12
                color: Theme.bgAlt
                Label { id: undoLabel; anchors.centerIn: parent; text: "Undo"; font.pixelSize: 12; font.weight: Font.Bold }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.undoing = true; Settings.undo(); root.undoing = false; toast.shown = false; }
                }
            }
        }
    }
}
