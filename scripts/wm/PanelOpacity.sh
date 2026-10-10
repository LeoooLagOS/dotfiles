#!/usr/bin/env bash
# Opacity of the Quickshell panel card (config/quickshell/panel), 50–100%.
#   PanelOpacity.sh 80     set it
#   PanelOpacity.sh +5     more opaque (or -5 for more see-through)
#   PanelOpacity.sh status
# The value is the panel's Settings → Appearance → Opacity (saved in
# ~/.config/lagos/panel-settings.json). Light and inverted modes add a little on
# top, so the blur doesn't look grey over a dark desktop.

set -euo pipefail

get() { qs -c panel ipc call panel getSetting opacity 2>/dev/null | tr -cd '0-9'; }

arg="${1:-status}"
case "$arg" in
  status) echo "$(get)%"; exit 0 ;;
  +[0-9]* | -[0-9]*) cur=$(get); [[ -n $cur ]] || { echo "panel not running" >&2; exit 1; }; value=$(( cur + arg )) ;;
  [0-9]*) value=$arg ;;
  *) echo "usage: $0 <50-100> | +N | -N | status" >&2; exit 2 ;;
esac

(( value < 50 )) && value=50
(( value > 100 )) && value=100
qs -c panel ipc call panel setting opacity "$value" >/dev/null && echo "${value}%"
