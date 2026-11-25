#!/usr/bin/env bash
# New wallust colors → restart Thunderbird so it loads them (userChrome.css is only read at
# startup). Run by thunderbird-colors.path when ~/.config/lagos/thunderbird-colors.css changes.
#
# Also used by config/thunderbird/mail-tiers/build.sh --install to load a new add-on version.
#
# Never interrupts you: while Thunderbird is shown, focused, or has a second window open
# (a message being written, a dialog), it waits and checks again every 10 s, for up to 2 h.
# Then the panel's Comms dock restarts it where it was: hidden in special:comms-thunderbird,
# so it never shows (services/Comms.qml restart, IPC commsRestart).
#   ThunderbirdColors.sh          wait if busy, then restart
#   ThunderbirdColors.sh --check  only say whether it would restart now
set -u
class=net.thunderbird.Thunderbird
special=special:comms-thunderbird

pgrep -x thunderbird >/dev/null || { echo "not running: it loads the colors when it starts"; exit 0; }

# Why not now (empty when it's free to restart)
busy() {
  local clients; clients=$(hyprctl clients -j)
  hyprctl activewindow -j | jq -e --arg c "$class" '.class == $c' >/dev/null && { echo "focused"; return; }
  hyprctl monitors -j | jq -e --arg s "$special" 'any(.[]; .specialWorkspace.name == $s)' >/dev/null && { echo "shown"; return; }
  jq -e --arg c "$class" '[.[] | select(.class == $c)] | length > 1' <<<"$clients" >/dev/null && { echo "a second window is open"; return; }
  jq -e --arg c "$class" --arg s "$special" 'any(.[]; .class == $c and .workspace.name != $s)' <<<"$clients" >/dev/null && { echo "open outside the dock"; return; }
}

if [ "${1:-}" = "--check" ]; then
  why=$(busy); echo "${why:-free: it would restart now}"; exit 0
fi

sleep 3   # wallust writes several files: let them all land
for _ in $(seq 1 720); do
  why=$(busy)
  [ -z "$why" ] && break
  sleep 10
done
[ -n "$(busy)" ] && { echo "still busy after 2 h ($why): the colors load at its next start"; exit 0; }
qs -c panel ipc call panel commsRestart thunderbird && echo "restarted with the new colors"
