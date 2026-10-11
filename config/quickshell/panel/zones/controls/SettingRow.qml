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
    visible: !row.visibleIf || row.visibleIf(Settings.v)

    // chips: options as {value, label} (QML lists aren't JS arrays, hence typeof); `all` (if set) is exclusive and stands
    // for every option, so picking it clears the rest and emptying the list
    // brings it back
    readonly property var chipOpts: type === "chips"
        ? row.opts.map(o => typeof o === "object" ? { value: o[0], label: o[1] } : { value: o, label: o + (row.unit ?? "") }) : []
    function toggleChip(v) {
        const all = row.all, cur = [].concat(value).filter(x => x !== all);
        let next = v === all ? [all]
                 : cur.includes(v) ? cur.filter(x => x !== v)
                 : cur.concat([v]);
        if (all !== undefined && next.length === 0) next = [all];
        // keep the order of the options
        Settings.set(row.key, chipOpts.map(o => o.value).filter(x => next.includes(x)));
    }

    // apprules: label on top, the list of apps below (full width)
    readonly property bool stacked: type === "apprules"
    implicitHeight: stacked ? labels.implicitHeight + rules.implicitHeight + 28
                            : Math.max(46, Math.max(labels.implicitHeight, ctl.implicitHeight) + 18)

    Rectangle { visible: !root.first; width: parent.width; height: 1; color: Theme.border }

    // Label + help on the left, up to the control; the control on the right edge
    ColumnLayout {
        id: labels
        anchors.left: parent.left
        anchors.right: root.stacked ? parent.right : ctl.left
        anchors.verticalCenter: root.stacked ? undefined : parent.verticalCenter
        anchors.top: root.stacked ? parent.top : undefined
        anchors.topMargin: 10
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
        // Wraps onto more lines when the options don't fit
        Flow {
            visible: root.type === "chips"
            Layout.preferredWidth: Math.min(implicitChips.width, root.width * 0.55)
            spacing: 5
            Repeater {
                model: root.chipOpts
                delegate: Chip {
                    required property var modelData
                    text: modelData.label
                    active: [].concat(root.value).includes(modelData.value)
                    implicitHeight: 26
                    onClicked: root.toggleChip(modelData.value)
                }
            }
            // One-line width of the chips, to size the Flow
            Row {
                id: implicitChips
                visible: false
                spacing: 5
                Repeater {
                    model: root.chipOpts
                    delegate: Chip { required property var modelData; text: modelData.label; implicitHeight: 26 }
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
            text: root.type === "info" ? (root.row.infoKey ? (SystemSettings.info[root.row.infoKey] ?? "…") : String(root.row.value ?? "")) : ""
            dim: true
            font.pixelSize: root.row.mono ? 11 : 12
            font.family: root.row.mono ? "JetBrains Mono" : Theme.font
            horizontalAlignment: Text.AlignRight
            Layout.maximumWidth: 380
        }
    }

    // ---------------- apprules: one line per app ----------------
    // Apps with a rule plus the ones in the history; a rule back to Default is removed
    readonly property var ruleOpts: [["default", "Default"]].concat(Settings.notifPlaces, [["mute", "Mute (not even history)"]])
                                    .map(o => ({ value: o[0], label: o[1] }))
    readonly property var ruleApps: stacked
        ? [...new Set(Object.keys(Settings.v.appRules ?? {}).concat(Notifs.apps))].sort((a, b) => a.localeCompare(b)) : []
    function setRule(app, v) {
        const r = Object.assign({}, Settings.v.appRules ?? {});
        if (v === "default") delete r[app]; else r[app] = v;
        Settings.set(row.key, r);
    }
    Column {
        id: rules
        visible: root.stacked
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: labels.bottom
        anchors.topMargin: 8
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 4
        Label {
            visible: root.ruleApps.length === 0
            text: "No apps yet."
            dim: true
            font.pixelSize: 12
        }
        Repeater {
            model: root.ruleApps
            delegate: Item {
                required property string modelData
                required property int index
                readonly property string rule: (Settings.v.appRules ?? {})[modelData] ?? "default"
                // Earlier lines above later ones, so an open list covers what follows
                z: root.ruleApps.length - index
                width: rules.width
                height: 34
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: parent.modelData
                    font.pixelSize: 13
                    font.weight: parent.rule !== "default" ? Font.DemiBold : Font.Normal
                    color: parent.rule === "mute" ? Theme.fgDim : Theme.fg
                    width: parent.width - appDrop.width - 12
                    elide: Text.ElideRight
                }
                Dropdown {
                    id: appDrop
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    options: root.ruleOpts
                    value: parent.rule
                    listWidth: 210
                    onSelected: v => root.setRule(parent.modelData, v)
                }
            }
        }
    }
}
