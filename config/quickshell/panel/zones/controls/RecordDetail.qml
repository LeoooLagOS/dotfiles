import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: screen recording (services/Recorder.qml) — what, with which audio,
// start / stop, and the recordings folder
Zone {
    title: Tr.t("Screen recording")
    icon: "\u{f044a}"
    closable: true
    Component.onCompleted: Recorder.checkInstalled()

    ColumnLayout {
        width: parent.width
        spacing: 8

        // Not installed: how to get it
        Label {
            visible: !Recorder.installed
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.pixelSize: 12
            text: Tr.t("Needs gpu-screen-recorder: sudo dnf install gpu-screen-recorder (Terra repo).")
        }

        RowLayout {
            visible: Recorder.installed
            Layout.fillWidth: true
            spacing: 8
            Segmented {
                Layout.fillWidth: true
                enabled: !Recorder.recording
                value: Settings.v.recTarget
                options: [{ value: "screen", label: Tr.t("Screen"), icon: "\u{f0379}" }, { value: "region", label: Tr.t("Region"), icon: "\uf125" }]
                onSelected: v => Settings.set("recTarget", v)
            }
            Segmented {
                enabled: !Recorder.recording
                value: Settings.v.recFps
                options: [{ value: 30, label: "30" }, { value: 60, label: "60 fps" }]
                onSelected: v => Settings.set("recFps", v)
            }
        }
        Segmented {
            visible: Recorder.installed
            Layout.fillWidth: true
            enabled: !Recorder.recording
            value: Settings.v.recAudio
            options: [{ value: "none", label: Tr.t("No audio"), icon: "\u{f0581}" }, { value: "system", label: Tr.t("System"), icon: "" },
                      { value: "both", label: Tr.t("System + mic"), icon: "" }]
            onSelected: v => Settings.set("recAudio", v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            visible: text !== ""
            text: Recorder.error ? Tr.t("Last try failed: %1", Recorder.error)
                : Recorder.recording ? Tr.t("Recording · %1. SUPER ALT Print or the tile stops it.", Recorder.elapsed)
                : Recorder.lastFile ? Tr.t("Saved %1", Recorder.lastFile.split("/").pop())
                : Recorder.installed ? Tr.t("The panel closes when it starts. SUPER ALT Print starts / stops.") : ""
        }
        RowLayout {
            spacing: 6
            Chip {
                visible: Recorder.installed
                text: Recorder.recording ? Tr.t("Stop") : Tr.t("Start recording")
                icon: Recorder.recording ? "" : ""
                filled: Recorder.recording
                tint: Theme.bad
                onClicked: Recorder.toggle()
            }
            Chip { text: Tr.t("Recordings"); icon: ""; onClicked: Recorder.openFolder() }
        }
    }
}
