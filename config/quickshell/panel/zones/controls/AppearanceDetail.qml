import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: the theme, same settings as Settings → Appearance → Panel & launchers
// (that page also picks which launchers follow it). Only the panel and the
// Rofi menus: GTK/Qt apps and browsers keep the system theme (DarkLight.sh).
Zone {
    title: Tr.t("Appearance")
    icon: Theme.chosenLight ? "" : ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        Label { text: Tr.t("MODE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.modeSetting
            options: [{ value: "system", label: Tr.t("System") }, { value: "dark", label: Tr.t("Dark"), icon: "" },
                      { value: "light", label: Tr.t("Light"), icon: "" }]
            onSelected: v => Theme.setMode(v)
        }
        Label { text: Tr.t("PALETTE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.chosenInverted
            options: [{ value: false, label: Tr.t("Normal") }, { value: true, label: Tr.t("Inverted") }]
            onSelected: v => Theme.setInverted(v)
        }
        Label { text: Tr.t("APPLY TO"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.scope
            options: [{ value: "panel", label: Tr.t("Panel") }, { value: "both", label: Tr.t("Both") }, { value: "launchers", label: Tr.t("Launchers") }]
            onSelected: v => Settings.set("themeScope", v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("Launchers are the Rofi menus. Apps and browsers keep the system theme.")
        }
        Chip { text: Tr.t("Choose launchers"); icon: ""; onClicked: PanelState.openSettings("appearance") }
    }
}
