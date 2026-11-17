#!/usr/bin/env bash
# Themes menu (SUPER ALT T): one rofi with a tab per thing that has themes,
# like the app launcher's tabs (SUPER D):
#   Kitty · Ghostty (terminals) · Prompt (Starship) · Menus (rofi)
# Enter applies the theme and the menu stays open, to try another; Esc closes
# (the last one applied stays). The desktop's colors are SUPER T (wallust).
#
# Each tab is this same script as a rofi "script mode": rofi runs
# `RofiThemes.sh <kind>` for the list and `RofiThemes.sh <kind> <picked>` when
# a row is picked. The work is done by each selector's own --list / --current /
# --apply (Kitty_themes.sh…), so the logic lives in one place (ADR-0014).
set -uo pipefail

S=$(dirname "$(readlink -f "$0")")
. "$S/lagos_i18n.sh"

script_for() {
  case $1 in
    kitty) echo "$S/Kitty_themes.sh" ;;
    ghostty) echo "$S/Ghostty_themes.sh" ;;
    prompt) echo "$S/ChangeStarshipPrompt.sh" ;;
    menus) echo "$S/RofiThemeSelector.sh" ;;
  esac
}

# ---------------- One tab (called by rofi) ----------------
if [[ -n ${1:-} && -n ${ROFI_RETV:-} ]]; then
  sel_script=$(script_for "$1")
  current_row() { [[ -n $1 ]] && t "Current: %1" "$1"; }
  current=$("$sel_script" --current 2>/dev/null | head -n1)
  # 1 = a row picked (not text typed in the search); the "Current" row applies nothing
  if [[ $ROFI_RETV == 1 && -n ${2:-} && $2 != "$(current_row "$current")" ]]; then
    "$sel_script" --apply "$2" >/dev/null 2>&1
    current=$("$sel_script" --current 2>/dev/null | head -n1)
  fi
  mapfile -t items < <("$sel_script" --list 2>/dev/null)
  printf '\0message\x1f%s\n' "$(t "Enter: apply (the menu stays open to try another) · Esc: close")"
  # First row: the one in use; then all of them, it too (marked). The menu
  # opens at the top; after applying, the cursor stays where it was
  top=0
  [[ -n $current ]] && top=1
  [[ $ROFI_RETV != 0 ]] && printf '\0keep-selection\x1ftrue\n'
  active=()
  ((top)) && active+=(0)
  for i in "${!items[@]}"; do
    [[ ${items[$i]} == "$current" ]] && active+=("$((i + top))")
  done
  ((${#active[@]})) && printf '\0active\x1f%s\n' "$(IFS=,; echo "${active[*]}")"
  current_row "$current" && echo
  printf '%s\n' "${items[@]}"
  exit 0
fi

# ---------------- The menu ----------------
if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi 2>/dev/null || true
  exit 0
fi

modes=()
command -v kitty >/dev/null && modes+=("Kitty:$0 kitty")
command -v ghostty >/dev/null && modes+=("Ghostty:$0 ghostty")
command -v starship >/dev/null && modes+=("$(t "Prompt"):$0 prompt")
modes+=("$(t "Menus"):$0 menus")

"$S/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true
config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-large.rasi"
exec rofi -show "${modes[0]%%:*}" -modi "$(IFS=,; echo "${modes[*]}")" -config "$config"
