#!/usr/bin/env bash
# What closing the laptop lid does, as chosen in the Quickshell panel
# (Settings → Power & idle → Closing the lid), saved in ~/.config/lagos/lid:
#   battery=suspend|lock|screenoff   no external monitor, on battery
#   ac=suspend|lock|screenoff        no external monitor, charger plugged in
#   docked=nothing|lock|suspend      an external monitor is connected
#
#   LaptopLid.sh close   the lid was closed, or the monitor unplugged with the
#                        lid closed (both from UserConfigs/user_laptops.lua)
#   LaptopLid.sh watch   run by lagos-lid.service under a handle-lid-switch
#                        inhibitor: while it runs logind leaves the lid to the
#                        session, and unplugging the charger with the lid closed
#                        applies the battery action
#
# Without lagos-lid.service, logind handles the lid (System/etc/systemd/
# logind.conf.d/10-lid.conf) and `close` only turns the panel off.

set -uo pipefail

SETTINGS="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/lid"
SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
PANEL=eDP-1

setting() { # key default
  local v
  v="$(sed -n "s/^$1=//p" "$SETTINGS" 2>/dev/null | tail -n1)"
  echo "${v:-$2}"
}

lid_closed() { grep -qs closed /proc/acpi/button/lid/*/state; }

on_ac() {
  local s
  for s in /sys/class/power_supply/*; do
    [[ "$(cat "$s/type" 2>/dev/null)" == Mains && "$(cat "$s/online" 2>/dev/null)" == 1 ]] && return 0
  done
  return 1
}

# Same test as user_laptops.lua: a non-internal connector is plugged in
docked() {
  local f name
  for f in /sys/class/drm/card*-*/status; do
    name="$(basename "${f%/status}")"
    name="${name#card*-}"
    case "$name" in eDP* | LVDS* | DSI*) continue ;; esac
    [[ "$(cat "$f" 2>/dev/null)" == connected ]] && return 0
  done
  return 1
}

managed() { systemctl --user is-active --quiet lagos-lid.service; }

# Blank the panel. After an unplug user_laptops.lua is still turning it back
# on (config reload), so wait for it to be listed first.
panel_off() {
  local _
  for _ in $(seq 1 30); do
    if hyprctl monitors -j 2>/dev/null | jq -e --arg m "$PANEL" 'any(.[]; .name == $m)' >/dev/null; then
      hyprctl dispatch hl.dsp.dpms "{ action = \"off\", monitor = \"$PANEL\" }" >/dev/null 2>&1
      return
    fi
    sleep 0.1
  done
}

close() {
  local action
  if docked; then
    action="$(setting docked nothing)"
  elif on_ac; then
    action="$(setting ac lock)"
  else
    action="$(setting battery suspend)"
  fi

  if ! managed; then
    docked || panel_off
    return
  fi

  case "$action" in
    suspend) systemctl suspend ;; # hypridle's before_sleep_cmd locks first
    lock)
      "$SCRIPTSDIR/LockScreen.sh"
      docked || panel_off
      ;;
    screenoff) docked || panel_off ;;
    nothing) ;;
  esac
}

watch() {
  local was_ac now_ac
  was_ac="$(on_ac && echo 1 || echo 0)"
  while sleep 5; do
    now_ac="$(on_ac && echo 1 || echo 0)"
    if [[ $was_ac == 1 && $now_ac == 0 ]] && lid_closed && ! docked; then
      close
    fi
    was_ac=$now_ac
  done
}

case "${1:-}" in
  close) close ;;
  watch) watch ;;
  *) echo "usage: $0 close|watch" >&2; exit 2 ;;
esac
