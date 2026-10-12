#!/usr/bin/env bash
# Which top bar runs: the Quickshell panel's (config/quickshell/panel/TopBar.qml)
# or waybar.
#   BarSwitch.sh quickshell | waybar | status
# The choice is saved in ~/.config/lagos/bar, which the panel follows live and
# WaybarStartup.sh / Refresh.sh read so they don't bring waybar back over the
# panel's bar. Also run by the panel's Settings → Bar → Use this bar.

set -u
STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/bar"
S="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"

current() { [[ "$(cat "$STATE_FILE" 2>/dev/null)" == waybar ]] && echo waybar || echo quickshell; }

case "${1:-status}" in
  quickshell)
    mkdir -p "$(dirname "$STATE_FILE")"; echo quickshell >"$STATE_FILE"
    systemctl --user stop waybar.service >/dev/null 2>&1 || true
    pkill -x waybar 2>/dev/null; pkill -x .waybar-wrapped 2>/dev/null; true ;;
  waybar)
    mkdir -p "$(dirname "$STATE_FILE")"; echo waybar >"$STATE_FILE"
    setsid -f "$S/WaybarStartup.sh" >/dev/null 2>&1 ;;
  status) current ;;
  *) echo "usage: $0 quickshell|waybar|status" >&2; exit 2 ;;
esac
