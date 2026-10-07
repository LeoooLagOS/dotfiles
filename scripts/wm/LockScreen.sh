#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================

# For Hyprlock
#pidof hyprlock || hyprlock -q

# Ensure weather cache is up-to-date before locking (Waybar/lockscreen readers)
bash "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/UserScripts/WeatherWrap.sh" >/dev/null 2>&1 &

# hypridle's lock_cmd starts hyprlock on lock-session; if hypridle was toggled off
# (Waybar idle inhibitor), nothing listens for that signal, so launch hyprlock directly.
if pgrep -x hypridle >/dev/null; then
    loginctl lock-session
else
    pidof hyprlock >/dev/null || setsid -f hyprlock >/dev/null 2>&1
fi

