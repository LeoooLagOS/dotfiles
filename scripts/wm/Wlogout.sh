#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Power menu (Lock, Logout, Shutdown, Reboot, Suspend). Kept under the wlogout
# name because Waybar, swaync and the keybinds call this script; the menu itself
# is PowerMenu.py, which adds hold-to-confirm for the destructive actions.

menu="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/PowerMenu.py"

# Toggle: close the menu if it is already open
if pkill -f "$menu"; then
    exit 0
fi

exec "$menu"
