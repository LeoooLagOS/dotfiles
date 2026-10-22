import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: game mode (scripts/wm/GameMode.sh)
Zone {
    title: Tr.t("Game mode")
    icon: ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Label { text: Tr.t("Game mode"); font.pixelSize: 13; Layout.fillWidth: true }
            Switch { checked: Toggles.game; enabled: !Toggles.gameBusy; onToggled: Toggles.toggleGame() }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("Turns off animations, blur, shadows, gaps and rounded corners in Hyprland for the best frame rate. Turning it off reloads Hyprland and your wallpaper colors.")
        }
    }
}
