#!/usr/bin/env bash

scriptsDir="$HOME/dotfiles/scripts/wm"
PY_SCRIPT="$scriptsDir/../lib/Weather.py"
. "$(dirname "$(readlink -f "$0")")/lagos_i18n.sh"
# Home location lives outside the repo; format: City, State, Country
HOME_PLACE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/weather-home"
# Active manual location read by Weather.py; absent means Network mode
PLACE_STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/lagos/weather-place"

if [ -s "$PLACE_STATE_FILE" ]; then
  # Switch to Network mode
  rm -f "$PLACE_STATE_FILE"
  MODE="$(t "Network (Dynamic)")"
else
  CITY="$(head -n1 "$HOME_PLACE_FILE" 2>/dev/null)"
  if [ -z "$CITY" ]; then
    notify-send "🌤️ $(t "Weather")" "$(t "No home location set.")\n$(t "Write it to %1" "<b>$HOME_PLACE_FILE</b>")" -t 5000
    exit 1
  fi
  # Switch to Manual mode
  mkdir -p "$(dirname "$PLACE_STATE_FILE")"
  printf '%s\n' "$CITY" >"$PLACE_STATE_FILE"
  MODE="$(t "Fixed (%1)" "$CITY")"
fi

# Clear cache and force silent regeneration
rm -rf ~/.cache/open_meteo_cache.json ~/.cache/.weather_cache
python3 "$PY_SCRIPT" >/dev/null 2>&1

# Send system notification
notify-send "🌤️ $(t "Weather")" "$(t "Location switched to:")\n<b>$MODE</b>" -t 3000
