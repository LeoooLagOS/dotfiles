#!/usr/bin/env bash
# Quick reply for messaging apps that can't take one from the notification
# itself (WhatsApp Web, most Electron apps): services/Comms.qml has just run
# the notification's action, so the app is opening that chat. This pastes TEXT
# there and presses Enter, then puts things back as they were: the app hidden
# again (if it was), the window you were in focused, your clipboard restored.
#   reply.sh WINDOW_ADDRESS TEXT
# Pasting needs the window focused (Wayland only lets the focused window read
# the clipboard), so the app shows for about a second.

set -u
addr=$1
text=$2

send() { hyprctl dispatch "hl.dsp.send_shortcut({ mods = \"$1\", key = \"$2\", window = \"address:$addr\" })" >/dev/null; }

prev=$(hyprctl activewindow -j | jq -r '.address // empty')
shown=$(hyprctl monitors -j | jq -r 'first(.[] | select(.focused)) | .specialWorkspace.name')
ws=$(hyprctl clients -j | jq -r --arg a "$addr" 'first(.[] | select(.address == $a)) | .workspace.name')
[ -z "$ws" ] && { echo "reply.sh: no window $addr" >&2; exit 1; }

# Keep the clipboard (its first type: text, an image…) to put it back
saved=$(mktemp)
type=$(wl-paste --list-types 2>/dev/null | head -1)
[ -n "$type" ] && wl-paste -n -t "$type" >"$saved" 2>/dev/null

printf '%s' "$text" | wl-copy
hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null
sleep 0.9                     # the chat opens and its message box gets the focus
send CTRL V
sleep 0.25
send "" Return
sleep 0.4

if [ -n "$type" ]; then wl-copy -t "$type" <"$saved"; else wl-copy --clear; fi
rm -f "$saved"

# Hide the app again if it was hidden, back to where you were
if [[ $ws == special:* ]] && [ "$shown" != "$ws" ]; then
  hyprctl dispatch "hl.dsp.workspace.toggle_special(\"${ws#special:}\")" >/dev/null
fi
[ -n "$prev" ] && [ "$prev" != "$addr" ] && hyprctl dispatch "hl.dsp.focus({ window = \"address:$prev\" })" >/dev/null
exit 0
