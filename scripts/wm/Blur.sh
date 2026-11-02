#!/usr/bin/env bash
# How strong Hyprland's blur is, and which apps go without it. Hyprland has a
# single strength for everything see-through (windows, the bar, the panel and
# the screen behind it); per app it can only be on or off.
#   Blur.sh level off|soft|medium|strong   set it (saved, applied right away)
#   Blur.sh level cycle                    the next one (SUPER ALT O)
#   Blur.sh level                          print the current one
#   Blur.sh apps                           apply ~/.config/lagos/blur-off-apps
# State in ~/.config/lagos: blur-level (one word) and blur-off-apps (a window
# class per line, written by the panel's Settings → Appearance → Blur). Both
# are read when Hyprland loads (UserConfigs/user_decorations.lua and
# user_window_rules.lua); the levels below must match the ones there.

set -euo pipefail

DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lagos"
LEVEL_FILE="$DIR/blur-level"
APPS_FILE="$DIR/blur-off-apps"
LEVELS=(off soft medium strong)

current() {
  local l
  l=$(cat "$LEVEL_FILE" 2>/dev/null || true)
  [[ " ${LEVELS[*]} " == *" $l "* ]] && echo "$l" || echo soft
}

apply_level() {
  local enabled=true size passes
  case $1 in
    off) enabled=false; size=4; passes=1 ;;
    soft) size=4; passes=1 ;;
    medium) size=6; passes=2 ;;
    strong) size=8; passes=3 ;;
  esac
  hyprctl eval "hl.config({ decoration = { blur = { enabled = $enabled, size = $size, passes = $passes } } })" >/dev/null
}

set_level() {
  mkdir -p "$DIR"
  echo "$1" >"$LEVEL_FILE"
  apply_level "$1"
}

# One rule for all of them, replaced live (same name); none left: disabled
apply_apps() {
  local classes
  classes=$(grep -v '^\s*\(#\|$\)' "$APPS_FILE" 2>/dev/null | sed 's/[][\.^$*+?(){}|]/\\\\&/g' | paste -sd '|' || true)
  if [[ -n $classes ]]; then
    hyprctl eval "hl.window_rule({ name = 'user-blur-off-apps', match = { class = '(?i)^($classes)\$' }, no_blur = true })" >/dev/null
  else
    hyprctl eval "hl.window_rule({ name = 'user-blur-off-apps', match = { class = '^\$' }, no_blur = true, enabled = false })" >/dev/null
  fi
}

case "${1:-}" in
  level)
    case "${2:-}" in
      "") current ;;
      cycle)
        cur=$(current)
        for i in "${!LEVELS[@]}"; do [[ ${LEVELS[$i]} == "$cur" ]] && break; done
        set_level "${LEVELS[$(((i + 1) % ${#LEVELS[@]}))]}" ;;
      off | soft | medium | strong) set_level "$2" ;;
      *) echo "usage: $0 level [off|soft|medium|strong|cycle]" >&2; exit 2 ;;
    esac ;;
  apps) apply_apps ;;
  *) echo "usage: $0 level [off|soft|medium|strong|cycle] | apps" >&2; exit 2 ;;
esac
