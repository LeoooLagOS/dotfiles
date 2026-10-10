#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Rofi application launcher toggle script (SUPER D): apps + inline math, files,
# run, windows and the calculator

if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi 2>/dev/null || pkill rofi 2>/dev/null || true
  exit 0
fi

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
if [ -x "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" ]; then
  "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true
fi

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config.rasi"
calc_opts=(-terse -automatic-save-to-history -hint-result "= "
  -calc-command "$SCRIPTSDIR/RofiCalcAction.sh '{expression}' '{result}'")

# Apps tab = apps + live math (quickcalc plugin, scripts/rofi-quickcalc): type
# "2+2", "10 km to mi" or "x^2" in the search and the answer is the first row.
# The Calc tab keeps the full calculator (history, plots).
plugins="$HOME/.local/lib/rofi"
if [[ -e "$plugins/quickcalc.so" ]]; then
  export ROFI_PLUGIN_PATH="$plugins"
  exec rofi -show combi -combi-modes quickcalc,drun -display-combi Apps -combi-display-format "{text}" \
    -modi combi,filebrowser,run,window,calc "${calc_opts[@]}" -config "$config"
fi
exec rofi -show drun -modi drun,filebrowser,run,window,calc "${calc_opts[@]}" -config "$config"
