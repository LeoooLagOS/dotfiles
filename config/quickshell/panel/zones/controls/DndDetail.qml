import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: Do Not Disturb — for how long, and a link to the schedule
Zone {
    title: Tr.t("Do Not Disturb")
    icon: Notifs.dnd ? "" : ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        Label { text: Tr.t("SILENCE NOTIFICATIONS"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: !Notifs.dnd ? "" : Notifs.dndScheduled ? "" : Notifs.dndUntil ? (Notifs.dndUntil - new Date() > 3700000 ? "tomorrow" : "1h") : "off"
            options: [{ value: "1h", label: Tr.t("1 hour") }, { value: "tomorrow", label: Tr.t("Until 7:00") }, { value: "off", label: Tr.t("Until off") }]
            onSelected: v => Notifs.dndFor(v === "off" ? "" : v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: (Notifs.dnd ? Tr.t("On · %1. ", Notifs.dndStatus) : "")
                + (Settings.v.critical ? Tr.t("Critical notifications still show. ") : "")
                + Tr.t("Silenced ones wait in the Notifications tab.")
        }
        Chip { text: Tr.t("Quiet hours and rules"); icon: ""; onClicked: PanelState.openSettings("notifications") }
    }
}
