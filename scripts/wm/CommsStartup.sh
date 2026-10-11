#!/usr/bin/env bash
# Communication apps at login, running (so their notifications arrive) but out
# of the way:
#   Teams         minimized to the tray (teams-for-linux --minimized)
#   WhatsApp      (Brave web app) and Thunderbird have no tray on Linux, so they
#                 open in the hidden special workspace "comms"; SUPER Y shows /
#                 hides it (UserConfigs/user_keybinds.lua)
# Apps that aren't installed, or are already open, are skipped.
# Run once per session from UserConfigs/user_startup.lua; safe to run by hand.

set -u

TEAMS=com.github.IsmaelMartinez.teams_for_linux
BRAVE=com.brave.Browser

has_window() { hyprctl clients -j | jq -e --arg re "$1" 'any(.[]; .class | test($re))' >/dev/null; }

# Start "$@", wait for a window whose class matches $1, move it to special:comms
# without following it (window.move with follow = false)
open_hidden() {
  local re=$1; shift
  has_window "$re" && return
  setsid -f "$@" >/dev/null 2>&1      # detached: `wait` below only waits for the moves
  for _ in $(seq 1 120); do
    if has_window "$re"; then
      sleep 0.5   # let it map before moving
      hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:comms\", follow = false, window = \"class:$re\" })" >/dev/null
      return
    fi
    sleep 0.5
  done
}

# Teams: to the tray
if flatpak info "$TEAMS" >/dev/null 2>&1 && ! has_window '^com\.github\.IsmaelMartinez\.teams_for_linux$'; then
  setsid -f flatpak run "$TEAMS" --minimized >/dev/null 2>&1
fi

# WhatsApp web app: Brave gives each installed site an app id; read it from the
# launcher it created ("WhatsApp Web")
wa=$(grep -l '^Name=WhatsApp Web$' "$HOME"/.local/share/applications/com.brave.Browser.flextop.*.desktop 2>/dev/null | head -1)
if [ -n "$wa" ]; then
  id=$(grep -o -- '--app-id=[a-z]*' "$wa" | head -1 | cut -d= -f2)
  [ -n "$id" ] && open_hidden "^crx_${id}\$" \
    flatpak run --command=brave "$BRAVE" --profile-directory=Default --app-id="$id" &
fi

# Thunderbird
if command -v thunderbird >/dev/null; then
  open_hidden '^(net\.thunderbird\.Thunderbird|thunderbird)$' thunderbird &
fi

wait
