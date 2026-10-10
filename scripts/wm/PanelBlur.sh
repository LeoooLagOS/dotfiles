#!/usr/bin/env bash
# Blur behind the Quickshell panel (config/quickshell/panel): the frosted card
# and the soft blur of the whole screen while the panel is hovered.
#   PanelBlur.sh on | off | toggle | status
# The choice is saved in ~/.config/lagos/panel-blur ("on"/"off"), which
# config/hypr/UserConfigs/user_layer_rules.lua reads when Hyprland loads, and it
# is applied right away with `hyprctl eval` (rules with the same name replace
# the old ones). Also used by the panel's Settings → Appearance → Blur.

set -euo pipefail

STATE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/panel-blur"

current() { [[ "$(cat "$STATE_FILE" 2>/dev/null || echo on)" == off ]] && echo off || echo on; }

apply() {
  local blur=$1   # true | false
  hyprctl eval "hl.layer_rule({ name = 'user-quickshell-panel-blur', match = { namespace = 'quickshell:panel' }, blur = $blur, ignore_alpha = 0.05 })" >/dev/null
  hyprctl eval "hl.layer_rule({ name = 'user-quickshell-panel-dim-blur', match = { namespace = 'quickshell:panel-dim' }, blur = $blur, ignore_alpha = 0 })" >/dev/null
}

set_state() {
  local state=$1
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$state" >"$STATE_FILE"
  apply "$([[ $state == on ]] && echo true || echo false)"
  # Keep the panel's switch in sync (no-op if it already has this value)
  qs -c panel ipc call panel setting blur "$([[ $state == on ]] && echo true || echo false)" >/dev/null 2>&1 || true
}

case "${1:-status}" in
  on | off) set_state "$1" ;;
  toggle) set_state "$([[ $(current) == on ]] && echo off || echo on)" ;;
  status) current ;;
  *) echo "usage: $0 on|off|toggle|status" >&2; exit 2 ;;
esac
