#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Power menu (Lock, Logout, Shutdown, Reboot, Suspend). Kept under the wlogout
# name because Waybar, swaync and the keybinds call this script; the menu itself
# is the panel's (hold-to-confirm for the destructive actions), else PowerMenu.py.

menu="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/PowerMenu.py"

# Toggle: close the old menu if it is already open
if pkill -f "$menu"; then
    exit 0
fi

# The panel's power menu (config/quickshell/panel/bar/PowerMenu.qml), under
# the bar's power button; PowerMenu.py only when the panel isn't running
qs -c panel ipc call panel power >/dev/null 2>&1 && exit 0

exec "$menu"
