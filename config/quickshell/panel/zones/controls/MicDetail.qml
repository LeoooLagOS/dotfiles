import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: microphone — mute and input device
Zone {
    title: Tr.t("Microphone")
    icon: ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Label { text: Tr.t("Mute"); font.pixelSize: 13; Layout.fillWidth: true }
            Switch {
                checked: Audio.source?.audio?.muted ?? false
                onToggled: if (Audio.source?.audio) Audio.source.audio.muted = !Audio.source.audio.muted
            }
        }
        Label { text: Tr.t("INPUT DEVICE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        DeviceList {
            Layout.fillWidth: true
            nodes: Audio.sources
            current: Audio.source
            onPicked: node => Audio.useSource(node)
        }
    }
}
