#!/usr/bin/env bash
# Colors from the wallpaper (wallust) on or off.
#   WallustToggle.sh on | off | toggle | status
# Off: changing the wallpaper keeps the current palette (WallustSwww.sh stops
# before running wallust). On: the palette is taken from the current wallpaper
# again right away. Saved in ~/.config/lagos/wallust; also used by the Quickshell
# panel's Settings → Wallpaper.

set -euo pipefail

STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/wallust"
SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"

current() { [[ "$(cat "$STATE_FILE" 2>/dev/null || echo on)" == off ]] && echo off || echo on; }

set_state() {
  local state=$1 before
  before=$(current)
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$state" >"$STATE_FILE"
  qs -c panel ipc call panel setting wallust "$([[ $state == on ]] && echo true || echo false)" >/dev/null 2>&1 || true
  # Back on: recolor from the current wallpaper and refresh the bars
  if [[ $state == on && $before == off ]]; then
    "$SCRIPTSDIR/WallustSwww.sh" && "$SCRIPTSDIR/Refresh.sh" >/dev/null 2>&1 || true
  fi
}

case "${1:-status}" in
  on | off) set_state "$1" ;;
  toggle) set_state "$([[ $(current) == on ]] && echo off || echo on)" ;;
  status) current ;;
  *) echo "usage: $0 on|off|toggle|status" >&2; exit 2 ;;
esac
