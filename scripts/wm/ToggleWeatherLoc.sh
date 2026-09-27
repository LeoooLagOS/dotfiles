#!/usr/bin/env bash

scriptsDir="$HOME/dotfiles/scripts/wm"
PY_SCRIPT="$scriptsDir/../lib/Weather.py"
# Write your manual Location; format: City, State, Country
CITY="Puebla, Puebla, Mexico"

# Check if the variable is empty (Network mode)
if grep -q 'MANUAL_PLACE: Optional\[str\] = ""' "$PY_SCRIPT"; then
  # Switch to Manual mode
  sed -i 's/MANUAL_PLACE: Optional\[str\] = ""/MANUAL_PLACE: Optional\[str\] = "'"$CITY"'"/' "$PY_SCRIPT"
  MODE="Fixed ($CITY)"
else
  # Switch to Network mode
  sed -i 's/MANUAL_PLACE: Optional\[str\] = ".*"/MANUAL_PLACE: Optional\[str\] = ""/' "$PY_SCRIPT"
  MODE="Network (Dynamic)"
fi

# Clear cache and force silent regeneration
rm -rf ~/.cache/open_meteo_cache.json ~/.cache/.weather_cache
python3 "$PY_SCRIPT" >/dev/null 2>&1

# Send system notification
notify-send "🌤️ Weather Module" "Location switched to:\n<b>$MODE</b>" -t 3000
