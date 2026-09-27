#!/usr/bin/env bash
# /* ---- 💫 KoolDots 💫 ---- */
# /* Calculator (using rofi-calc and qalculate) */

# Kill Rofi if already running before execution
if pgrep -x "rofi" >/dev/null; then
  pkill rofi
  sleep 0.1
fi

# Launch the native rofi-calc plugin with the current Hyprland theme
# Pressing Enter will copy the result to the clipboard
rofi -show calc \
  -modi calc \
  -no-show-match \
  -no-sort \
  -calc-command "echo -n '{result}' | wl-copy" \
  -config "$HOME/.config/hypr/rofi/config.rasi"
