import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// One row of the Settings view: label + help on the left, its control on the
// right. The control depends on row.type (see the schema in common/Settings.qml).
Item {
    id: root
    property var row: ({})
    property bool first: false
    property var formatter: (r, v) => String(v)

    readonly property var value: row.key ? Settings.v[row.key] : row.value
    readonly property string type: row.type ?? "info"

    implicitHeight: Math.max(46, Math.max(labels.implicitHeight, ctl.implicitHeight) + 18)

    Rectangle { visible: !root.first; width: parent.width; height: 1; color: Theme.border }

    // Label + help on the left, up to the control; the control on the right edge
    ColumnLayout {
        id: labels
        anchors.left: parent.left
        anchors.right: ctl.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        anchors.rightMargin: 14
        spacing: 1
        RowLayout {
            spacing: 7
            Label { text: root.row.label ?? ""; font.pixelSize: 13; font.weight: Font.Medium }
            Rectangle {
                visible: !!root.row.system
                implicitHeight: 15
                implicitWidth: sysLabel.implicitWidth + 10
                radius: 8
                color: "transparent"
                border.color: Theme.warn
                Label { id: sysLabel; anchors.centerIn: parent; text: "SYSTEM"; color: Theme.warn; font.pixelSize: 9; font.weight: Font.DemiBold }
            }
            }
        Label { visible: !!root.row.help; text: root.row.help ?? ""; dim: true; font.pixelSize: 11; Layout.fillWidth: true; wrapMode: Text.Wrap }
    }

    RowLayout {
        id: ctl
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Switch {
            visible: root.type === "switch"
            checked: !!root.value
            onToggled: Settings.set(root.row.key, !root.value)
        }
        Segmented {
            visible: root.type === "seg"
            Layout.preferredWidth: Math.max(230, implicitWidth)
            options: root.type === "seg" ? root.row.opts.map(o => ({ value: o[0], label: o[1] })) : []
            value: root.value
            onSelected: v => Settings.set(root.row.key, v)
        }
        Dropdown {
            visible: root.type === "select"
            options: root.type === "select" ? root.row.opts.map(o => ({ value: o[0], label: o[1] })) : []
            value: root.value
            listWidth: 190
            onSelected: v => Settings.set(root.row.key, v)
        }
        RowLayout {
            visible: root.type === "range"
            spacing: 10
            ValueSlider {
                id: slider
                Layout.preferredWidth: 190
                from: root.row.min ?? 0
                to: root.row.max ?? 100
                step: root.row.step ?? 1
                value: root.type === "range" ? root.value : 0
                onCommitted: v => Settings.set(root.row.key, v)
            }
            Label {
                text: root.type === "range" ? root.formatter(root.row, slider.shown) : ""
                font.pixelSize: 12
                font.weight: Font.DemiBold
                Layout.preferredWidth: 54
                horizontalAlignment: Text.AlignRight
            }
        }
        Row {
            visible: root.type === "chips"
            spacing: 5
            Repeater {
                model: root.type === "chips" ? root.row.opts : []
                delegate: Chip {
                    required property var modelData
                    text: modelData + (root.row.unit ?? "")
                    active: root.value.includes(modelData)
                    implicitHeight: 26
                    onClicked: Settings.set(root.row.key, active ? root.value.filter(x => x !== modelData)
                                                                 : root.value.concat([modelData]).sort((a, b) => b - a))
                }
            }
        }
        Row {
            visible: root.type === "keys"
            spacing: 4
            Repeater {
                model: root.type === "keys" ? root.value : []
                delegate: Rectangle {
                    required property var modelData
                    implicitHeight: 22
                    implicitWidth: keyLabel.implicitWidth + 12
                    radius: 6
                    color: Theme.withAlpha(Theme.fg, 0.05)
                    border.color: Theme.border
                    Label { id: keyLabel; anchors.centerIn: parent; text: parent.modelData; font.family: "JetBrains Mono"; font.pixelSize: 11 }
                }
            }
        }
        Label {
            visible: root.type === "info"
            text: root.type === "info" ? (SystemSettings.info[root.row.infoKey] ?? "…") : ""
            dim: true
            font.pixelSize: root.row.mono ? 11 : 12
            font.family: root.row.mono ? "JetBrains Mono" : Theme.font
            horizontalAlignment: Text.AlignRight
            Layout.maximumWidth: 380
        }
    }
}
