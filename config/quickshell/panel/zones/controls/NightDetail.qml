import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: night light (hyprsunset) — color temperature
Zone {
    title: Tr.t("Night light")
    icon: ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8
        RowLayout {
            Layout.fillWidth: true
            Label { text: Tr.t("Night light"); font.pixelSize: 13; Layout.fillWidth: true }
            Switch { checked: Toggles.night; onToggled: Toggles.toggleNight() }
        }
        Label { text: Tr.t("COLOR TEMPERATURE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            ValueSlider {
                id: temp
                Layout.fillWidth: true
                from: 2500; to: 6000; step: 100
                value: Settings.v.nightTemp
                onMoved: v => Toggles.previewTemp(v)
                onCommitted: v => Toggles.setTemp(v)
            }
            Label { text: temp.shown + " K"; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.preferredWidth: 52; horizontalAlignment: Text.AlignRight }
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("Lower is warmer. Also toggled with SUPER N.")
        }
    }
}
