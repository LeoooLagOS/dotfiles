import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: dark / light right now (the default lives in Settings → Appearance)
Zone {
    title: "Appearance"
    icon: Theme.light ? "" : ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        Label { text: "RIGHT NOW"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.light ? "light" : "dark"
            options: [{ value: "dark", label: "Dark", icon: "" }, { value: "light", label: "Light", icon: "" }]
            onSelected: v => { if ((v === "light") !== Theme.light) Theme.toggleLight(); }
        }
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Inverted palette"; font.pixelSize: 13; Layout.fillWidth: true }
            Switch { checked: Theme.inverted; onToggled: Theme.setInverted(!Theme.inverted) }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: "Dark / light here lasts until the panel restarts. The default (follow the system, or always dark or light) is in Settings."
        }
        Chip { text: "Appearance settings"; icon: ""; onClicked: PanelState.openSettings("appearance") }
    }
}
