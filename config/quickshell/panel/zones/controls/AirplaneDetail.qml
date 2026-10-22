import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: airplane mode
Zone {
    title: Tr.t("Airplane mode")
    icon: ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Label { text: Tr.t("Airplane mode"); font.pixelSize: 13; Layout.fillWidth: true }
            Switch { checked: Toggles.airplane; onToggled: Toggles.toggleAirplane() }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("Turns off Wi-Fi and Bluetooth together. Turning it off brings back the ones that were on before.")
        }
    }
}
