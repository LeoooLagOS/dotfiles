pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Reuses the waybar weather script (Open-Meteo, cached 5 min) and its cache file.
Singleton {
    id: root
    property bool ready: false
    property string icon: ""         // Nerd Font glyph from Weather.py
    property string descKey: ""                 // English (Weather.py, WeatherIcons.status)
    readonly property string description: Tr.t(descKey)
    property string place: ""
    property real temp: 0
    property real feelsLike: 0
    property real high: 0
    property real low: 0
    property int humidity: 0
    property real wind: 0
    property var rainNext: []        // precipitation probability, next 6 hours
    property int windDir: 0          // degrees, where the wind comes from
    property real visibility: 0      // km
    property real pressure: 0        // hPa
    property real precipitation: 0   // mm (current)
    // US EPA AQI, from scripts/forecast.py (waybar's Weather.py only has the European index)
    readonly property int aqi: Forecast.usAqi

    readonly property string windCompass: Tr.t(["N", "NE", "E", "SE", "S", "SW", "W", "NW"][Math.round(windDir / 45) % 8])
    readonly property string aqiLabel: aqi < 0 ? "" : Tr.t(aqi <= 50 ? "Good" : aqi <= 100 ? "Moderate"
                                     : aqi <= 150 ? "Unhealthy for sensitive groups" : aqi <= 200 ? "Unhealthy"
                                     : aqi <= 300 ? "Very unhealthy" : "Hazardous")

    Process {
        id: proc
        command: ["bash", "-c", "python3 " + Config.weatherScript]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.icon = d.text.trim().split(/\s+/)[0];
                    root.descKey = d.alt;
                } catch (e) { console.warn("weather:", e); }
                cache.reload();
            }
        }
    }

    FileView {
        id: cache
        path: Quickshell.env("HOME") + "/.cache/open_meteo_cache.json"
        watchChanges: true                 // waybar's weather module also refreshes it
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text());
                const f = d.forecast, c = f.current;
                root.place = d.place || "";
                root.temp = c.temperature_2m;
                root.feelsLike = c.apparent_temperature;
                root.humidity = c.relative_humidity_2m;
                root.wind = c.wind_speed_10m;
                root.windDir = c.wind_direction_10m ?? 0;
                root.visibility = (c.visibility ?? 0) / 1000;
                root.pressure = c.pressure_msl ?? 0;
                root.precipitation = c.precipitation ?? 0;
                // Icon/description straight from the cache, so they show before Weather.py returns
                root.icon = WeatherIcons.icon(c.weather_code, c.is_day !== 0);
                root.descKey = WeatherIcons.status[c.weather_code] ?? "Unknown";
                root.high = f.daily.temperature_2m_max[0];
                root.low = f.daily.temperature_2m_min[0];
                // Next 6 hours of rain probability, starting at the current hour
                const now = c.time.slice(0, 13);
                let i = f.hourly.time.findIndex(t => t.slice(0, 13) === now);
                if (i < 0) i = 0;
                root.rainNext = f.hourly.precipitation_probability.slice(i, i + 6);
                root.ready = true;
            } catch (e) {
                // Caught mid-write (older Weather.py wrote in place): try again once
                if (!retryRead.tried) { retryRead.tried = true; retryRead.restart(); }
                else console.warn("weather cache:", e);
                return;
            }
            retryRead.tried = false;
        }
    }
    Timer { id: retryRead; property bool tried: false; interval: 400; onTriggered: cache.reload() }

    Timer {
        interval: Config.weatherIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }
}
