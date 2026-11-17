#!/usr/bin/env bash
# Where the Rofi menus open (Lagos theme, config/hypr/rofi/themes/Lagos.rasi):
#   bottom  anchored to the bottom edge; Hyprland slides it up from there
#   center  a floating card centered across, just below the panel's card
#   RofiPosition.sh bottom | center | toggle | status
# Writes config/hypr/rofi/position.rasi (imported at the end of Lagos.rasi) and
# keeps the Quickshell panel's Settings → Appearance → Menus in sync.

set -euo pipefail

POSITION_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/position.rasi"

current() { grep -q "location: *south" "$POSITION_FILE" 2>/dev/null && echo bottom || echo center; }

write() {
  case "$1" in
    bottom) cat >"$POSITION_FILE" <<'RASI'
/* Where the menus open — written by scripts/wm/RofiPosition.sh (bottom | center) */
window {
  location: south;
  anchor:   south;
  y-offset: -10px;
}
RASI
      ;;
    center) cat >"$POSITION_FILE" <<'RASI'
/* Where the menus open — written by scripts/wm/RofiPosition.sh (bottom | center) */
window {
  /* centered across, hanging just below the panel's card so it never
     touches it (lagos-room-top, written by the panel: services/LauncherTheme.qml).
     Not location: center: a centered layer ignores its offsets */
  location: north;
  anchor:   north;
  y-offset: @lagos-room-top;
}
RASI
      ;;
  esac
  qs -c panel ipc call panel setting rofiPosition "\"$1\"" >/dev/null 2>&1 || true
}

case "${1:-status}" in
  bottom | center) write "$1" ;;
  toggle) write "$([[ $(current) == bottom ]] && echo center || echo bottom)" ;;
  status) current ;;
  *) echo "usage: $0 bottom|center|toggle|status" >&2; exit 2 ;;
esac
