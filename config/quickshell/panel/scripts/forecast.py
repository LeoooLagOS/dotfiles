#!/usr/bin/env python3
"""Hourly + 7-day forecast for the panel's Weather tab (Open-Meteo, no key).

Location: latitude/longitude from the waybar weather cache
(~/.cache/open_meteo_cache.json, written by scripts/lib/Weather.py), so it
follows the same Network/Fixed location mode. Cached for 30 minutes.

Prints JSON: {"hourly": [{time, temp, code, rain, isDay}], "daily": [{date,
code, max, min, rain, sunrise, sunset}], "place": str, "usAqi": int | null}

usAqi is the US EPA Air Quality Index from Open-Meteo's air-quality API.
"""

import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

WAYBAR_CACHE = Path.home() / ".cache/open_meteo_cache.json"
CACHE = Path.home() / ".cache/quickshell-panel/forecast.json"
TTL = 30 * 60


def main():
    src = json.loads(WAYBAR_CACHE.read_text())
    lat, lon = src["forecast"]["latitude"], src["forecast"]["longitude"]
    place = src.get("place", "")

    if CACHE.exists() and time.time() - CACHE.stat().st_mtime < TTL:
        cached = json.loads(CACHE.read_text())
        if cached.get("lat") == lat and cached.get("lon") == lon:
            print(json.dumps(cached["out"]))
            return

    params = urllib.parse.urlencode({
        "latitude": lat, "longitude": lon, "timezone": "auto", "forecast_days": 7,
        "hourly": "temperature_2m,weather_code,precipitation_probability,is_day",
        "daily": "weather_code,temperature_2m_max,temperature_2m_min,"
                 "precipitation_probability_max,sunrise,sunset",
    })
    with urllib.request.urlopen(f"https://api.open-meteo.com/v1/forecast?{params}", timeout=15) as r:
        d = json.load(r)

    h, dd = d["hourly"], d["daily"]
    now = time.strftime("%Y-%m-%dT%H")
    start = next((i for i, t in enumerate(h["time"]) if t[:13] >= now), 0)
    hourly = [{
        "time": h["time"][i][11:16],
        "temp": h["temperature_2m"][i],
        "code": h["weather_code"][i],
        "rain": h["precipitation_probability"][i] or 0,
        "isDay": bool(h["is_day"][i]),
    } for i in range(start, min(start + 24, len(h["time"])))]
    daily = [{
        "date": dd["time"][i],
        "code": dd["weather_code"][i],
        "max": dd["temperature_2m_max"][i],
        "min": dd["temperature_2m_min"][i],
        "rain": dd["precipitation_probability_max"][i] or 0,
        "sunrise": dd["sunrise"][i][11:16],
        "sunset": dd["sunset"][i][11:16],
    } for i in range(len(dd["time"]))]

    # US AQI (EPA scale) — separate endpoint; a failure here doesn't drop the forecast
    us_aqi = None
    try:
        aq = urllib.parse.urlencode({"latitude": lat, "longitude": lon, "current": "us_aqi", "timezone": "auto"})
        with urllib.request.urlopen(f"https://air-quality-api.open-meteo.com/v1/air-quality?{aq}", timeout=15) as r:
            us_aqi = json.load(r).get("current", {}).get("us_aqi")
    except Exception:
        pass

    out = {"hourly": hourly, "daily": daily, "place": place, "usAqi": us_aqi}
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    CACHE.write_text(json.dumps({"lat": lat, "lon": lon, "out": out}))
    print(json.dumps(out))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(json.dumps({"error": f"{type(e).__name__}: {e}"}))
        sys.exit(0)
