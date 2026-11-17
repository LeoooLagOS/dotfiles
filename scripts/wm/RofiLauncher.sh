#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Rofi application launcher toggle script (SUPER D): apps, files,
# run, windows and the calculator

if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi 2>/dev/null || pkill rofi 2>/dev/null || true
  exit 0
fi

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
if [ -x "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" ]; then
  "$SCRIPTSDIR/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true
fi

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-large.rasi"
calc_opts=(-terse -automatic-save-to-history -hint-result "= "
  -calc-command "$SCRIPTSDIR/RofiCalcAction.sh '{expression}' '{result}'")

# Apps tab: only the apps. Math goes in the Calc tab (history, plots); the
# quickcalc plugin (scripts/rofi-quickcalc) used to put its rows above the apps
exec rofi -show drun -modi drun,filebrowser,run,window,calc "${calc_opts[@]}" -config "$config"
