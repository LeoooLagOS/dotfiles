import QtQuick
import QtQuick.Layouts
import "../../common"
import "../../services"

// DETAIL: screen recording (services/Recorder.qml) — what, with which audio,
// start / stop, and the recordings folder
Zone {
    title: "Screen recording"
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
            text: "Needs gpu-screen-recorder: sudo dnf install gpu-screen-recorder (Terra repo)."
        }

        RowLayout {
            visible: Recorder.installed
            Layout.fillWidth: true
            spacing: 8
            Segmented {
                Layout.fillWidth: true
                enabled: !Recorder.recording
                value: Settings.v.recTarget
                options: [{ value: "screen", label: "Screen", icon: "\u{f0379}" }, { value: "region", label: "Region", icon: "\uf125" }]
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
            options: [{ value: "none", label: "No audio", icon: "\u{f0581}" }, { value: "system", label: "System", icon: "" },
                      { value: "both", label: "System + mic", icon: "" }]
            onSelected: v => Settings.set("recAudio", v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            visible: text !== ""
            text: Recorder.error ? "Last try failed: " + Recorder.error
                : Recorder.recording ? "Recording · " + Recorder.elapsed + ". SUPER ALT Print or the tile stops it."
                : Recorder.lastFile ? "Saved " + Recorder.lastFile.split("/").pop()
                : Recorder.installed ? "The panel closes when it starts. SUPER ALT Print starts / stops." : ""
        }
        RowLayout {
            spacing: 6
            Chip {
                visible: Recorder.installed
                text: Recorder.recording ? "Stop" : "Start recording"
                icon: Recorder.recording ? "" : ""
                filled: Recorder.recording
                tint: Theme.bad
                onClicked: Recorder.toggle()
            }
            Chip { text: "Recordings"; icon: ""; onClicked: Recorder.openFolder() }
        }
    }
}
