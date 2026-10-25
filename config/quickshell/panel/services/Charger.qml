pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../common"

// "Charger connected / unplugged" when the laptop's power changes, from
// UPower's onBattery (an event, at once; scripts/wm/BatteryNotify.sh only
// warns about low levels, every 30 s). The battery's level and the time to
// full or empty when UPower already knows it (it often needs a while on the
// new power, so it's left out rather than delaying the notice). Laptops only
// (a battery that powers the system). Not at start: UPower's first value
// isn't a change.
Singleton {
    id: root
    readonly property var bat: UPower.displayDevice
    readonly property bool laptop: !!bat && bat.isLaptopBattery
    property bool ready: false
    Timer { interval: 5000; running: true; onTriggered: root.ready = true }

    function dur(s) { const h = Math.floor(s / 3600), m = Math.round(s % 3600 / 60); return h ? Tr.t("%1 h %2 min", h, m) : Tr.t("%1 min", m); }

    function notify() {
        const plugged = !UPower.onBattery;
        const pct = Math.round(bat.percentage > 1 ? bat.percentage : bat.percentage * 100);
        const secs = plugged ? bat.timeToFull : bat.timeToEmpty;
        const body = pct + "%" + (secs > 0 ? "  ·  " + (plugged ? Tr.t("full in %1", dur(secs)) : Tr.t("%1 left", dur(secs))) : "");
        Quickshell.execDetached(["notify-send", "-e", "-u", "low", "-a", "Battery",
                                 // Our own icons (icons/): a theme's battery icons barely tell plugged from not
                                 "-i", Quickshell.shellDir + "/icons/" + (plugged ? "charger-connected.svg" : "charger-unplugged.svg"),
                                 "-h", "string:x-canonical-private-synchronous:charger",
                                 plugged ? Tr.t("Charger connected") : Tr.t("Charger unplugged"), body]);
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() { if (root.ready && root.laptop) root.notify(); }
    }
}
