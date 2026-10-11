import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: the theme, same settings as Settings → Appearance → Panel & launchers
// (that page also picks which launchers follow it). Only the panel and the
// Rofi menus: GTK/Qt apps and browsers keep the system theme (DarkLight.sh).
Zone {
    title: "Appearance"
    icon: Theme.chosenLight ? "" : ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        Label { text: "MODE"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.modeSetting
            options: [{ value: "system", label: "System" }, { value: "dark", label: "Dark", icon: "" },
                      { value: "light", label: "Light", icon: "" }]
            onSelected: v => Theme.setMode(v)
        }
        Label { text: "PALETTE"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.chosenInverted
            options: [{ value: false, label: "Normal" }, { value: true, label: "Inverted" }]
            onSelected: v => Theme.setInverted(v)
        }
        Label { text: "APPLY TO"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.scope
            options: [{ value: "panel", label: "Panel" }, { value: "both", label: "Both" }, { value: "launchers", label: "Launchers" }]
            onSelected: v => Settings.set("themeScope", v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: "Launchers are the Rofi menus. Apps and browsers keep the system theme."
        }
        Chip { text: "Choose launchers"; icon: ""; onClicked: PanelState.openSettings("appearance") }
    }
}
