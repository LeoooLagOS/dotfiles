#!/usr/bin/env bash
# Communication apps, running (so their notifications arrive) but out of the way:
#   Teams         minimized to the tray (teams-for-linux --minimized)
#   WhatsApp      (Brave web app) and Thunderbird have no tray on Linux: each
#                 opens in its own hidden special workspace, special:comms-<key>
#                 (whatsapp, mail). SUPER Y shows them with a dock below to
#                 switch between them (the panel's services/Comms.qml, CommsDock.qml)
#
#   CommsStartup.sh                    all of them (at login, UserConfigs/user_startup.lua)
#   CommsStartup.sh whatsapp|mail      just that one (the dock, for an app not running)
#       --show                         and show it once it's open
# Apps that aren't installed, or are already open, are skipped.

set -u

TEAMS=com.github.IsmaelMartinez.teams_for_linux
BRAVE=com.brave.Browser

show=0
want=()
for a in "$@"; do
  case $a in
    --show) show=1 ;;
    *) want+=("$a") ;;
  esac
done
wanted() { [ ${#want[@]} -eq 0 ] || [[ " ${want[*]} " == *" $1 "* ]]; }

# Address of the first window whose class matches $1 (and title $2, if given)
window_of() {
  hyprctl clients -j | jq -r --arg c "$1" --arg t "${2:-.}" \
    'first(.[] | select((.class | test($c)) and ((.initialTitle + " " + .title) | test($t)))) | .address' 2>/dev/null
}

# Start "$@" unless a window matches, wait for it, move it to special:comms-$key
# without following it; with --show, focus it (which shows the special workspace)
open_hidden() {
  local key=$1 cls=$2 title=$3; shift 3
  local addr
  addr=$(window_of "$cls" "$title")
  if [ -z "$addr" ]; then
    setsid -f "$@" >/dev/null 2>&1      # detached: `wait` below only waits for the moves
    for _ in $(seq 1 120); do
      addr=$(window_of "$cls" "$title")
      [ -n "$addr" ] && break
      sleep 0.5
    done
    [ -z "$addr" ] && return
    sleep 0.5   # let it map before moving
  fi
  hyprctl dispatch "hl.dsp.window.move({ workspace = \"special:comms-$key\", follow = false, window = \"address:$addr\" })" >/dev/null
  [ "$show" = 1 ] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
}

# Teams: to the tray
if wanted teams && flatpak info "$TEAMS" >/dev/null 2>&1 \
   && [ -z "$(window_of '^com\.github\.IsmaelMartinez\.teams_for_linux$')" ]; then
  setsid -f flatpak run "$TEAMS" --minimized >/dev/null 2>&1
fi

# WhatsApp web app: Brave gives each installed site an app id; read it from the
# launcher it created ("WhatsApp Web"). Window class: brave-<id>-Default on
# Wayland, crx_<id> on X11 (the .desktop's StartupWMClass)
wa=$(grep -l '^Name=WhatsApp Web$' "$HOME"/.local/share/applications/com.brave.Browser.flextop.*.desktop 2>/dev/null | head -1)
if wanted whatsapp && [ -n "$wa" ]; then
  id=$(grep -o -- '--app-id=[a-z]*' "$wa" | head -1 | cut -d= -f2)
  [ -n "$id" ] && open_hidden whatsapp "^(brave-${id}-Default|crx_${id})\$" "WhatsApp" \
    flatpak run --command=brave "$BRAVE" --profile-directory=Default --app-id="$id" &
fi

# Thunderbird (its main window; reminders and the composer stay where they open)
if wanted mail && command -v thunderbird >/dev/null; then
  open_hidden mail '^(net\.thunderbird\.Thunderbird|thunderbird)$' 'Thunderbird$' thunderbird &
fi

wait
