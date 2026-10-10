#!/usr/bin/env bash
# Calculator (SUPER ALT C, or the Calculator key): rofi-calc (qalculate) with
# the Lagos look — the result large, history below.
#   2+2*3 · 15% * 80 · sqrt(2)·pi · 10 km to mi · 100 USD to MXN · 3 h to min
#   x^2 - 3x (Enter plots it) · plot sin(x) -6 6
# Enter copies the result (or plots, RofiCalcAction.sh); history is kept.
# The app launcher (SUPER D) also answers simple math inline (quickcalc plugin).

if pidof rofi >/dev/null; then
  pkill -x rofi
  sleep 0.1
fi

scripts="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
exec rofi -show calc -modi calc \
  -no-show-match -no-sort \
  -terse -automatic-save-to-history \
  -hint-result "= " \
  -hint-welcome "2+2 · 15% * 80 · 10 km to mi · 100 USD to MXN · x^2 → plot" \
  -calc-command "$scripts/RofiCalcAction.sh '{expression}' '{result}'" \
  -config "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-calc.rasi"
