import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "../common"
import "../services"

// ZONE: System — CPU, memory, temperature, disk and battery.
// Data: services/SystemStats.qml (scripts/sysstats.sh).
// Header: lock and power-menu buttons (commands in common/Config.qml).
// In Controls (`controls: true`) those live in the identity bar instead, and the
// power profile selector is shown below the stats.
// Rows are declared statically (not a Repeater over a rebuilt array) so they
// are updated in place instead of recreated on every poll.
Zone {
    id: root
    title: Tr.t("System")
    accentHeader: true
    icon: "\uf2db"

    property bool controls: false
    readonly property bool charging: SystemStats.batteryStatus === "Charging"

    function run(cmd) {
        PanelState.open = false;
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    actions: [
        IconButton {
            visible: !root.controls; icon: "\uf023"; iconSize: 11; implicitWidth: 30; implicitHeight: 26; onClicked: root.run(Config.lockCmd) },   // lock
        IconButton {
            visible: !root.controls; icon: "\uf011"; iconSize: 11; implicitWidth: 30; implicitHeight: 26; onClicked: root.run(Config.powerCmd) }   // power menu
    ]

    ColumnLayout {
        width: parent.width
        spacing: 8

        StatRow {
            Layout.fillWidth: true
            iconColor: Theme.accent
            icon: "\uf4bc"; label: "CPU"
            value: SystemStats.cpu + "%"
            ratio: SystemStats.cpu / 100
            barColor: Theme.level(ratio, 0.7, 0.9)
        }
        StatRow {
            Layout.fillWidth: true
            iconColor: Theme.accent
            icon: "\uf2db"; label: Tr.t("Memory")
            value: SystemStats.gb(SystemStats.memUsed) + " / " + SystemStats.gb(SystemStats.memTotal) + " GB"
            ratio: SystemStats.memUsed / SystemStats.memTotal
            barColor: Theme.level(ratio, 0.75, 0.9)
        }
        StatRow {
            Layout.fillWidth: true
            iconColor: Theme.accent
            icon: "\uf2c9"; label: Tr.t("Temp")
            value: SystemStats.temp + "°C"
            ratio: SystemStats.temp / 100
            barColor: Theme.level(ratio, 0.8, 0.9)          // 80 °C / 90 °C
        }
        StatRow {
            Layout.fillWidth: true
            iconColor: Theme.accent
            icon: "\uf0a0"; label: Tr.t("Disk")
            value: Math.round(SystemStats.diskUsed / 1e9) + " / " + Math.round(SystemStats.diskTotal / 1e9) + " GB"
            ratio: SystemStats.diskUsed / SystemStats.diskTotal
            barColor: Theme.level(ratio, 0.8, 0.9)
        }
        StatRow {
            Layout.fillWidth: true
            iconColor: Theme.accent
            icon: root.charging ? "\uf0e7" : "\uf240"; label: Tr.t("Battery")
            value: SystemStats.battery + "%" + (root.charging ? " · " + Tr.t("charging") : "")
            ratio: SystemStats.battery / 100
            barColor: root.charging ? Theme.good : Theme.lowLevel(ratio, 0.3, 0.15)
        }

        // Power profile (tuned-ppd / power-profiles-daemon)
        Label {
            visible: root.controls
            text: Tr.t("POWER PROFILE")
            dim: true
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 1
            Layout.topMargin: 4
        }
        Segmented {
            visible: root.controls
            Layout.fillWidth: true
            value: PowerProfiles.profile
            options: [
                { value: PowerProfile.PowerSaver, label: Tr.t("Saver"), icon: "\uf06c" },
                { value: PowerProfile.Balanced, label: Tr.t("Balanced"), icon: "\uf24e" }
            ].concat(PowerProfiles.hasPerformanceProfile ? [{ value: PowerProfile.Performance, label: Tr.t("Performance"), icon: "\uf0e7" }] : [])
            onSelected: v => PowerProfiles.profile = v
        }
        Label {
            visible: root.controls
            Layout.fillWidth: true
            dim: true
            font.pixelSize: 11
            text: PowerProfiles.profile === PowerProfile.PowerSaver ? Tr.t("Longest battery, slower")
                : PowerProfiles.profile === PowerProfile.Performance ? Tr.t("Fastest, more heat and fan noise")
                : Tr.t("Default for daily use")
        }
    }
}
