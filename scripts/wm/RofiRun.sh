#!/usr/bin/env bash
# Run (SUPER R, as Windows' Win+R): a small "mini terminal" under the distro
# logo, where the start menu opens. rofi's run mode: type a command (the ones
# on PATH are suggested as you type) and Enter runs it; Shift+Enter runs it
# inside a terminal, to see what it prints. Pressed again: closes.
set -uo pipefail

S=$(dirname "$(readlink -f "$0")")
. "$S/lagos_i18n.sh"

if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi 2>/dev/null || true
  exit 0
fi

# Under the logo: rofi already starts below the space the bar reserves, so the
# offset is only the air between them (6 px, as the start menu and SUPER X)
y=6

config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config.rasi"
mono='"JetBrainsMono Nerd Font 11"'
# The Lagos theme (config/hypr/rofi/themes/Lagos.rasi), made a terminal line:
# a ❯ prompt in the accent, monospace, one column, the hint as the
# placeholder (-mesg only shows in dmenu mode).
# (One quoted value per line in -theme-str: rofi 2.0 reads a second quoted
# value on the same line into the first, and the property is lost)
exec rofi -show run -config "$config" \
  -display-run "❯" -no-show-icons \
  -theme-str "
    window   { location: north west; anchor: north west; x-offset: 8px; y-offset: ${y}px;
               width: @lagos-side-width; }
    mainbox  { padding: 10px; spacing: 8px; children: [ inputbar, listview ]; }
    inputbar { padding: 9px 12px; children: [ prompt, entry ]; }
    prompt   { text-color: @lagos-accent; font: ${mono}; vertical-align: 0.5; }
    entry    { font: ${mono}; }
    entry    { placeholder: \"$(t "Type a command - Shift+Enter: in a terminal")\"; }
    listview { columns: 1; lines: 5; spacing: 2px; }
    element  { padding: 6px 12px; }
    element-text { font: ${mono}; }
"
