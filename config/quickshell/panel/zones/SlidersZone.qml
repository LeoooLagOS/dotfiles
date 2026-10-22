import QtQuick
import QtQuick.Layouts
import Quickshell
import "../common"
import "../services"

// ZONE: Output, microphone and brightness, one row each with its device.
// Click an icon to mute; click the output device to choose another one.
Zone {
    id: root
    title: Tr.t("Sound & display")
    icon: ""

    // Asks the Controls tab to show a detail ("output", "mic")
    signal detailRequested(string id)

    ColumnLayout {
        width: parent.width
        spacing: 8

        Repeater {
            model: [
                { label: Tr.t("Output"), node: "sink" },
                { label: Tr.t("Microphone"), node: "source" },
                { label: Tr.t("Brightness"), node: "" }
            ]
            delegate: ColumnLayout {
                id: row
                required property var modelData
                readonly property var node: modelData.node === "sink" ? Audio.sink
                                          : modelData.node === "source" ? Audio.source : null
                readonly property bool muted: node?.audio?.muted ?? false
                readonly property real level: node ? (node.audio?.volume ?? 0) : Brightness.value

                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 44
                    spacing: 6
                    Label { text: row.modelData.label; dim: true; font.pixelSize: 11 }
                    // Device: a button for audio (opens the device list), plain text for the screen
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.maximumWidth: devRow.implicitWidth + 12
                        implicitHeight: 20
                        radius: 6
                        color: devMouse.containsMouse ? Theme.bgHover : "transparent"
                        Row {
                            id: devRow
                            anchors.verticalCenter: parent.verticalCenter
                            x: 6
                            spacing: 4
                            Label {
                                text: row.node ? Audio.name(row.node) : Tr.t("Built-in display")
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                width: Math.min(implicitWidth, 200)
                            }
                            Glyph { visible: !!row.node; text: ""; font.pixelSize: 8; color: Theme.fgDim; anchors.verticalCenter: parent.verticalCenter }
                        }
                        MouseArea {
                            id: devMouse
                            anchors.fill: parent
                            enabled: !!row.node
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.detailRequested(row.modelData.node === "sink" ? "output" : "mic")
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: row.muted ? Tr.t("Muted") : Math.round(row.level * 100) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold }
                }
                SliderRow {
                    Layout.fillWidth: true
                    icon: row.modelData.node === "sink" ? (row.muted ? "" : "")
                        : row.modelData.node === "source" ? (row.muted ? "" : "")
                        : ""
                    value: row.level
                    onMoved: v => {
                        if (row.node?.audio) row.node.audio.volume = v;
                        else if (!row.node) Brightness.set(v);
                    }
                    onIconClicked: if (row.node?.audio) row.node.audio.muted = !row.node.audio.muted
                }
            }
        }
    }
}
