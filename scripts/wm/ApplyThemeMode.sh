#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Re-apply saved Dark/Light mode on startup without toggling. lagOS: SystemMode.sh (only light /
# dark; DarkLight.sh picked a random GTK and icon theme at every login and reran wallust)

SCRIPTSDIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
"$SCRIPTSDIR/SystemMode.sh" apply
