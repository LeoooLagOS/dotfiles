#!/usr/bin/env bash
# Quick reply for messaging apps that can't take one from the notification
# itself (WhatsApp Web, most Electron apps). services/Comms.qml ran the
# notification's action when you opened the reply box, so the app already has
# that chat open. This pastes TEXT there and presses Enter without you seeing
# it. Pasting needs the window focused (Wayland only lets the focused window
# read the clipboard), so for a moment it gets the focus, but:
#   - it's fully transparent, and animations are off (no fade, no slide)
#   - nothing is blurred behind its special workspace
#   - the window you were in keeps its look (not dimmed, same opacity)
# Then everything goes back as it was, even if something fails half way: the
# app hidden again (if it was), opacities, animations, your focus, your clipboard.
#   reply.sh WINDOW_ADDRESS TEXT [WAIT]   WAIT: seconds for the chat to open (0.25)

set -u
addr=$1
text=$2
wait=${3:-0.25}

d() { hyprctl dispatch "$1" >/dev/null; }
send() { d "hl.dsp.send_shortcut({ mods = \"$1\", key = \"$2\", window = \"address:$addr\" })"; }
prop() { d "hl.dsp.window.set_prop({ prop = \"$2\", value = \"$3\", window = \"address:$1\" })"; }
getprop() { hyprctl getprop "address:$1" "$2" 2>/dev/null | head -1; }
option() { hyprctl getoption "$1" | grep -o 'true\|false'; }
config() { hyprctl eval "hl.config({ $1 })" >/dev/null; }
num() { [[ $1 =~ ^[0-9.]+$ ]]; }

prev=$(hyprctl activewindow -j | jq -r '.address // empty')
[ "$prev" = "$addr" ] && prev=""
shown=$(hyprctl monitors -j | jq -r 'first(.[] | select(.focused)) | .specialWorkspace.name')
ws=$(hyprctl clients -j | jq -r --arg a "$addr" 'first(.[] | select(.address == $a)) | .workspace.name')
[ -z "$ws" ] && { echo "reply.sh: no window $addr" >&2; exit 1; }

# As things were
opacity=$(getprop "$addr" opacity); num "$opacity" || opacity=1
blur=$(option decoration:blur:special)
anim=$(option animations:enabled)
[ -n "$prev" ] && prev_inactive=$(getprop "$prev" opacity_inactive) && prev_active=$(getprop "$prev" opacity)
saved=$(mktemp)
type=$(wl-paste --list-types 2>/dev/null | head -1)          # text, an image…
[ -n "$type" ] && wl-paste -n -t "$type" >"$saved" 2>/dev/null

restore() {
  if [[ $ws == special:* ]] && [ "$shown" != "$ws" ]; then
    [ "$(hyprctl monitors -j | jq -r 'first(.[] | select(.focused)) | .specialWorkspace.name')" = "$ws" ] \
      && d "hl.dsp.workspace.toggle_special(\"${ws#special:}\")"
  fi
  if [ -n "$prev" ]; then
    d "hl.dsp.focus({ window = \"address:$prev\" })"
    prop "$prev" no_dim 0
    prop "$prev" opacity_inactive_override 0
    num "${prev_inactive:-}" && prop "$prev" opacity_inactive "$prev_inactive"
  fi
  sleep 0.15                  # hidden before it can show again
  prop "$addr" opacity "$opacity"
  [ "$blur" = true ] && config 'decoration = { blur = { special = true } }'
  [ "$anim" = true ] && config 'animations = { enabled = true }'
  if [ -n "$type" ]; then wl-copy -t "$type" <"$saved"; else wl-copy --clear; fi
  rm -f "$saved"
}
trap restore EXIT

printf '%s' "$text" | wl-copy
[ "$anim" = true ] && config 'animations = { enabled = false }'
[ "$blur" = true ] && config 'decoration = { blur = { special = false } }'
prop "$addr" opacity 0
if [ -n "$prev" ]; then
  prop "$prev" no_dim 1
  num "${prev_active:-}" && prop "$prev" opacity_inactive "$prev_active" && prop "$prev" opacity_inactive_override 1
fi

sleep 0.12                    # the config changes settle (else the paste can be lost)
d "hl.dsp.focus({ window = \"address:$addr\" })"
sleep "$wait"                 # focused: the clipboard reaches it (and the chat is open)
send CTRL V
sleep 0.15
send "" Return
sleep 0.15
exit 0
