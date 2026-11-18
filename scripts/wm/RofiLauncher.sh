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

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-apps.rasi"
calc_opts=(-terse -automatic-save-to-history -hint-result "= "
  -calc-command "$SCRIPTSDIR/RofiCalcAction.sh '{expression}' '{result}'")

# Apps tab: only the apps. Math goes in the Calc tab (history, plots); the
# quickcalc plugin (scripts/rofi-quickcalc) used to put its rows above the apps
# CTRL 1 … CTRL 0: open the app in that place of the grid (rofi's
# kb-select-N; its default SUPER+N is Hyprland's, it never reaches rofi)
select_keys=()
for n in 1 2 3 4 5 6 7 8 9 10; do select_keys+=(-kb-select-$n "Control+$((n % 10))"); done
exec rofi -show drun -modi drun,filebrowser,run,window,calc "${calc_opts[@]}" "${select_keys[@]}" -config "$config"
