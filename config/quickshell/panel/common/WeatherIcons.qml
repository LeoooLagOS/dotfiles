pragma Singleton

import QtQuick
import Quickshell

// WMO weather code → Nerd Font icon / description.
// Same icon set as scripts/lib/Weather.py (waybar), except "severe": Weather.py
// uses \ue36e, which in the Nerd Font is wi-alien; \ue31d is wi-thunderstorm.
Singleton {
    readonly property var icons: ({
        sunnyDay: "\u{f0599}", clearNight: "\u{f0594}",
        cloudyDay: "\ue303", cloudyNight: "\ue346",
        rainyDay: "\ue306", rainyNight: "\ue331",
        snowyDay: "\ue30a", snowyNight: "\ue327",
        severe: "\ue31d", other: "\ue302"
    })

    readonly property var status: ({
        0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
        45: "Fog", 48: "Rime fog",
        51: "Light drizzle", 53: "Drizzle", 55: "Dense drizzle",
        56: "Freezing drizzle", 57: "Freezing drizzle",
        61: "Light rain", 63: "Rain", 65: "Heavy rain",
        66: "Freezing rain", 67: "Freezing rain",
        71: "Light snow", 73: "Snow", 75: "Heavy snow", 77: "Snow grains",
        80: "Showers", 81: "Showers", 82: "Violent showers",
        85: "Snow showers", 86: "Snow showers",
        95: "Thunderstorm", 96: "Storm & hail", 99: "Storm & hail"
    })

    function icon(code, isDay) {
        const day = isDay !== false;
        if (code === 0) return day ? icons.sunnyDay : icons.clearNight;
        if ([1, 2, 3, 45, 48].includes(code)) return day ? icons.cloudyDay : icons.cloudyNight;
        if ([51, 53, 55, 61, 63, 65, 80, 81, 82].includes(code)) return day ? icons.rainyDay : icons.rainyNight;
        if ([56, 57, 66, 67, 71, 73, 75, 77, 85, 86].includes(code)) return day ? icons.snowyDay : icons.snowyNight;
        if ([95, 96, 99].includes(code)) return icons.severe;
        return icons.other;
    }

    function describe(code) { return Tr.t(status[code] ?? "Unknown"); }
}
