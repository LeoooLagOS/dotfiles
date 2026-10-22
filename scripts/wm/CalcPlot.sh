#!/usr/bin/env bash
# Plot y = f(x) in a window with the Lagos look (wallust colors, Inter).
#   CalcPlot.sh "x^2 - 3x" [xmin xmax]      (default -10 … 10)
# Used by the quickcalc row of the app launcher (SUPER D) and by the Calc tab
# (RofiCalcAction.sh). Expressions use qalculate syntax ("2x", "sqrt", "pi",
# "sin(x)"…): qalc computes the points, gnuplot only draws them, so anything
# qalc understands can be plotted. Undefined or complex points leave gaps.

set -euo pipefail

expr="${1:?usage: CalcPlot.sh EXPRESSION [XMIN XMAX]}"
xmin="${2:--10}"
xmax="${3:-10}"
steps=600
. "$(dirname "$(readlink -f "$0")")/lagos_i18n.sh"

colors="${XDG_CONFIG_HOME:-$HOME/.config}/waybar/wallust/colors-waybar.css"
color() { sed -n "s/^ *@define-color $1 \(#[0-9A-Fa-f]\{6\}\).*/\1/p" "$colors" 2>/dev/null | head -1; }
bg="$(color background)";  bg="${bg:-#141618}"
grid="$(color color0)";    grid="${grid:-#3a3a3a}"
accent="$(color color12)"; accent="${accent:-#8a8a8a}"
fg="#eceef2"

data="$(mktemp --suffix=.dat)"
trap 'rm -f "$data"' EXIT

# qalc returns "[y1  y2  …]"; one x per value, complex/undefined → NaN (a gap)
values="$(qalc -t "genvector($expr, $xmin, $xmax, $steps, x)" 2>/dev/null | tr -d '[]')"
if [[ -z "${values// /}" ]]; then
  notify-send -a Calculator "$(t "Can't plot")" "y = $expr"
  exit 1
fi
awk -v a="$xmin" -v b="$xmax" -v n="$steps" '{
  for (i = 1; i <= NF; i++) {
    x = a + (b - a) * (i - 1) / (n - 1)
    y = ($i ~ /^-?[0-9.]+(E[-+]?[0-9]+)?$/) ? $i : "NaN"
    print x, y
  }
}' <<<"$values" >"$data"

# Keep the plot window until it is closed; gnuplot exits when it is
gnuplot -persist <<GP &
set terminal qt size 900,600 font "Inter,11" title "y = ${expr//\"/}" enhanced
set object 1 rectangle from screen 0,0 to screen 1,1 behind fillcolor rgb "$bg" fillstyle solid noborder
set border 3 linecolor rgb "$grid"
set tics nomirror textcolor rgb "$fg"
set grid linecolor rgb "$grid" dashtype 2
set xzeroaxis linecolor rgb "$fg" linewidth 0.6
set yzeroaxis linecolor rgb "$fg" linewidth 0.6
set key off
set title "y = ${expr//\"/}" textcolor rgb "$fg" font "Inter Display SemiBold,14"
set xlabel "x" textcolor rgb "$fg"
set datafile missing "NaN"
set xrange [$xmin:$xmax]
plot "$data" using 1:2 with lines linewidth 2.5 linecolor rgb "$accent"
pause mouse close
GP
sleep 1   # let gnuplot read the data file before it is removed
