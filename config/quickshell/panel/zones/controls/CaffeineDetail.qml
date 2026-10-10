import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: caffeine — keep the screen awake, optionally for a while
Zone {
    title: "Caffeine"
    icon: ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        Label { text: "KEEP THE SCREEN AWAKE"; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: !Toggles.caffeine ? "" : Toggles.caffeineMinutes ? String(Toggles.caffeineMinutes) : "off"
            options: [{ value: "30", label: "30 min" }, { value: "60", label: "1 hour" }, { value: "off", label: "Until off" }]
            onSelected: v => Toggles.setCaffeine(true, v === "off" ? 0 : +v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: (Toggles.caffeine ? "On · " + Toggles.caffeineStatus + ". " : "")
                + "No dimming, lock or suspend while it is on (hypridle)."
        }
        Chip { text: "Idle timeouts"; icon: ""; onClicked: PanelState.openSettings("power") }
    }
}
