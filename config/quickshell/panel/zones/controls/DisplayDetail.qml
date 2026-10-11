import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: displays (services/Displays.qml) — per monitor: on/off, resolution
// and refresh rate, scale. Applied right away until Hyprland reloads its
// config; nwg-displays or a monitor profile keeps a layout.
Zone {
    id: root
    title: "Displays"
    icon: "\u{f0379}"
    closable: true
    Component.onCompleted: Displays.refresh()

    ColumnLayout {
        width: parent.width
        spacing: 10

        Repeater {
            model: Displays.monitors
            delegate: Rectangle {
                id: card
                required property var modelData
                required property int index
                readonly property var m: modelData
                readonly property string current: m.width + "x" + m.height + "@" + m.refresh
                // Earlier cards above later ones, so an open dropdown covers what follows
                z: Displays.monitors.length - index
                Layout.fillWidth: true
                implicitHeight: col.implicitHeight + 20
                radius: 12
                color: "transparent"
                border.color: m.focused && !m.disabled ? Theme.withAlpha(Theme.accent, 0.55) : Theme.border

                ColumnLayout {
                    id: col
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Glyph { text: card.m.name.startsWith("eDP") ? "\u{f0322}" : "\u{f0379}"; font.pixelSize: 16; color: card.m.disabled ? Theme.fgDim : Theme.accent }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { text: card.m.name + (card.m.focused && !card.m.disabled ? "  ·  focused" : ""); font.pixelSize: 13; font.weight: Font.DemiBold }
                            Label { text: card.m.description; dim: true; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                        Switch {
                            checked: !card.m.disabled
                            // The last screen on stays on
                            enabled: card.m.disabled || Displays.enabled.length > 1
                            onToggled: Displays.setEnabled(card.m, card.m.disabled)
                        }
                    }
                    RowLayout {
                        visible: !card.m.disabled
                        Layout.fillWidth: true
                        spacing: 8
                        Dropdown {
                            z: 2
                            icon: "\u{f0a0}"
                            options: (card.m.modes.includes(card.current) ? card.m.modes : [card.current].concat(card.m.modes))
                                .map(v => ({ value: v, label: v.replace("x", "×").replace("@", " · ") + " Hz" }))
                            value: card.current
                            listWidth: 210
                            onSelected: v => Displays.setMode(card.m, v)
                        }
                        Segmented {
                            Layout.fillWidth: true
                            value: card.m.scale
                            options: [1, 1.25, 1.5, 2].map(s => ({ value: s, label: s + "×" }))
                            onSelected: v => Displays.setScale(card.m, v)
                        }
                    }
                }
            }
        }

        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Displays.error ? "Hyprland: " + Displays.error
                : "Changes apply now and last until Hyprland reloads. To keep a layout, use nwg-displays or a monitor profile."
        }
        RowLayout {
            spacing: 6
            Chip { text: "nwg-displays"; icon: ""; onClicked: Displays.openNwgDisplays() }
            Chip { text: "Monitor profiles"; icon: "\u{f0379}"; onClicked: Displays.openProfiles() }
        }
    }
}
