#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Switch Hyprland layouts per active monitor/workspace.
# This avoids global layout mutations and keeps workspace-specific rules intact.

. "$(dirname "$(readlink -f "$0")")/lagos_i18n.sh"
persist_layout_script="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/PersistWorkspaceLayout.sh"
layouts=(master dwindle scrolling monocle)
quiet_mode=0

normalize_layout() {
  case "$1" in
  master | dwindle | scrolling | monocle)
    printf '%s\n' "$1"
    ;;
  *)
    printf '\n'
    ;;
  esac
}

wait_for_layout() {
  local target="$1"
  local actual=""
  local attempt

  for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    actual="$(get_layout)"
    if [[ "$actual" == "$target" ]]; then
      printf '%s\n' "$actual"
      return 0
    fi
    sleep 0.03
  done

  printf '%s\n' "$actual"
  return 1
}

persist_current_workspace_layout() {
  local target_layout="$1"

  if [[ ! -x "$persist_layout_script" ]]; then
    return 0
  fi

  "$persist_layout_script" --quiet --layout "$target_layout" >/dev/null 2>&1 || true
}

get_active_workspace_json() {
  hyprctl -j activeworkspace 2>/dev/null || printf '{}'
}

get_layout() {
  local ws_json layout

  ws_json="$(get_active_workspace_json)"
  layout="$(jq -r '.tiledLayout // .tiled_layout // .layout // empty' <<<"$ws_json" 2>/dev/null || true)"
  layout="$(normalize_layout "$layout")"

  if [[ -z "$layout" ]]; then
    layout="$(hyprctl -j getoption general:layout 2>/dev/null | jq -r '.str // empty' 2>/dev/null || true)"
    layout="$(normalize_layout "$layout")"
  fi

  if [[ -z "$layout" ]]; then
    layout="dwindle"
  fi

  printf '%s\n' "$layout"
}

get_workspace_selector() {
  local ws_json="$1"
  local ws_id ws_name

  ws_id="$(jq -r '.id // empty' <<<"$ws_json" 2>/dev/null || true)"
  ws_name="$(jq -r '.name // empty' <<<"$ws_json" 2>/dev/null || true)"

  if [[ "$ws_id" =~ ^[0-9]+$ ]] && ((ws_id > 0)); then
    printf '%s\n' "$ws_id"
    return 0
  fi

  if [[ -n "$ws_name" && "$ws_name" != "null" ]]; then
    if [[ "$ws_name" == name:* || "$ws_name" == special:* ]]; then
      printf '%s\n' "$ws_name"
    else
      printf 'name:%s\n' "$ws_name"
    fi
    return 0
  fi

  return 1
}

get_workspace_label() {
  local ws_json="$1"
  local ws_name ws_id

  ws_name="$(jq -r '.name // empty' <<<"$ws_json" 2>/dev/null || true)"
  ws_id="$(jq -r '.id // empty' <<<"$ws_json" 2>/dev/null || true)"

  if [[ -n "$ws_name" && "$ws_name" != "null" ]]; then
    printf '%s\n' "$ws_name"
    return
  fi

  if [[ -n "$ws_id" && "$ws_id" != "null" ]]; then
    printf '%s\n' "$ws_id"
    return
  fi

  printf 'current\n'
}

get_monitor_name() {
  local ws_json="$1"
  jq -r '.monitor // empty' <<<"$ws_json" 2>/dev/null || true
}

escape_lua_string() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

is_ok_output() {
  local output="$1"
  local normalized

  normalized="$(printf '%s\n' "$output" | tr -d '\r' | sed '/^[[:space:]]*$/d')"
  [[ -z "$normalized" || "$normalized" == "ok" ]]
}

set_workspace_layout_rule() {
  local target="$1"
  local ws_json workspace_selector monitor_name output
  local ws_escaped monitor_escaped target_escaped

  ws_json="$(get_active_workspace_json)"
  workspace_selector="$(get_workspace_selector "$ws_json" || true)"
  monitor_name="$(get_monitor_name "$ws_json")"

  if [[ -z "$workspace_selector" || -z "$monitor_name" ]]; then
    echo "Unable to resolve active workspace context" >&2
    return 1
  fi

  output="$(hyprctl keyword workspace "${workspace_selector}, monitor:${monitor_name}, layout:${target}" 2>&1 || true)"
  # Lua config: `hyprctl keyword` fails ("keyword can't work with non-legacy
  # parsers" before, "unknown request" since Hyprland dropped it), so any
  # failure tries the Lua rule
  if ! is_ok_output "$output"; then
    ws_escaped="$(escape_lua_string "$workspace_selector")"
    monitor_escaped="$(escape_lua_string "$monitor_name")"
    target_escaped="$(escape_lua_string "$target")"
    output="$(hyprctl eval "hl.workspace_rule({ workspace = \"${ws_escaped}\", monitor = \"${monitor_escaped}\", layout = \"${target_escaped}\" })" 2>&1 || true)"
  fi

  if ! is_ok_output "$output"; then
    echo "$output" >&2
    return 1
  fi
}

next_layout() {
  local current="$1"
  local i
  for i in "${!layouts[@]}"; do
    if [[ "${layouts[i]}" == "$current" ]]; then
      echo "${layouts[((i + 1) % ${#layouts[@]})]}"
      return
    fi
  done
  echo "${layouts[0]}"
}

# What each layout does, in plain words, for the notice
describe_layout() {
  case "$1" in
  master) t "One big window, the rest stacked beside it" ;;
  dwindle) t "Each new window splits the focused one in half" ;;
  scrolling) t "Windows in columns, side by side" ;;
  monocle) t "One window at a time, full size" ;;
  esac
}

# One notice at a time: a new one replaces the last (the panel's
# synchronous tag), so pressing keys in a row doesn't stack them
notice() {
  notify-send -e -u "$1" -a Hyprland -i view-grid-symbolic \
    -h string:x-canonical-private-synchronous:lagos-layout "$2" "$3" 2>/dev/null || true
}

# A layout message (hl.dsp.layout), only where it exists. Elsewhere Hyprland
# answered with its red Lua error; now a short notice says where it works.
#   layout_msg "swapwithmaster auto" master
layout_msg() {
  local msg=$1 out
  shift
  if [[ " $* " != *" $current "* ]]; then
    notice low "$(t "Only in %1" "${*^}")" "$(t "Now: %1 · SUPER ALT L changes it" "${current^}")"
    return 1
  fi
  out=$(hyprctl dispatch "hl.dsp.layout(\"$msg\")" 2>&1)
  # "window is floating", "no window"… : nothing to arrange, nothing to say
  [[ $out == error:* ]] && return 1
  return 0
}

# SUPER ALT S: scrolling's strip sideways <-> up and down (scrolling:direction;
# `hyprctl keyword` doesn't exist with a Lua config, so it goes through hl.config)
scroll_direction() {
  local now new
  now=$(hyprctl getoption scrolling:direction -j 2>/dev/null | jq -r '.str // "right"')
  [[ $now == right ]] && new=down || new=right
  hyprctl eval "hl.config({ scrolling = { direction = \"$new\" } })" >/dev/null 2>&1 || return 1
  if [[ $new == down ]]; then
    notice low "$(t "Scrolling: up and down")" "$(t "New windows go below")"
  else
    notice low "$(t "Scrolling: sideways")" "$(t "New windows go to the right")"
  fi
}

# SUPER CTRL L: the current layout's own move, one key for all of them
layout_action() {
  case "$current" in
  dwindle) layout_msg togglesplit dwindle ;;           # side by side <-> one over the other
  master) layout_msg "swapwithmaster auto" master ;;   # the window to the big side
  scrolling) bash "$(dirname "$(readlink -f "$0")")/ScrollCycleColumnWidth.sh" ;;  # next column width
  monocle) layout_msg cyclenext monocle ;;             # the next window
  esac
}

set_layout() {
  local target="$1"
  local actual err

  if ! err="$(set_workspace_layout_rule "$target" 2>&1)"; then
    if [[ "$quiet_mode" -eq 0 ]]; then
      notice critical "$(t "Couldn't change the window layout")" "${target^}: ${err:-?}"
    fi
    return 1
  fi

  actual="$(wait_for_layout "$target")"
  if [[ "$actual" == "$target" ]]; then
    persist_current_workspace_layout "$target"
    if [[ "$quiet_mode" -eq 0 ]]; then
      notice low "$(t "Windows: %1" "${actual^}")" "$(describe_layout "$actual")"
    fi
  else
    if [[ "$quiet_mode" -eq 0 ]]; then
      notice critical "$(t "Couldn't change the window layout")" "$(t "It's still %1" "${actual^}")"
    fi
    return 1
  fi
}

if [[ "${1:-}" == "--quiet" || "${1:-}" == "--no-notify" ]]; then
  quiet_mode=1
  shift
fi

current="$(get_layout)"
arg="${1:-toggle}"

case "$arg" in
init)
  # No startup keybind rebinding required anymore.
  exit 0
  ;;
current | status | get)
  printf '%s\n' "$current"
  ;;
toggle | next)
  set_layout "$(next_layout "$current")"
  ;;
action)
  layout_action
  ;;
direction)
  scroll_direction
  ;;
msg)
  # msg "<layout message>" <layouts where it exists…>
  layout_msg "${2:?message}" "${@:3}"
  ;;
master | dwindle | scrolling | monocle)
  set_layout "$arg"
  ;;
*)
  echo "Usage: $(basename "$0") [--quiet|--no-notify] [toggle|next|action|direction|msg MSG LAYOUT…|init|current|master|dwindle|scrolling|monocle]" >&2
  exit 1
  ;;
esac
