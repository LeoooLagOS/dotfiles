#!/usr/bin/env bash
# Close a communication app that may be hung (services/Comms.qml: restart / quit).
#   comms-stop.sh WINDOW_ADDRESS PID
# First its window, as a click on × would (most apps quit; Teams goes to the
# tray); if the process is still there after 5 s, SIGTERM; after 3 s more,
# SIGKILL. Returns once it's gone.
set -u
addr=$1
pid=$2
alive() { kill -0 "$pid" 2>/dev/null; }
gone_within() { for _ in $(seq 1 $(($1 * 4))); do alive || return 0; sleep 0.25; done; return 1; }

hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null
gone_within 5 && exit 0
kill -TERM "$pid" 2>/dev/null
gone_within 3 && exit 0
kill -KILL "$pid" 2>/dev/null
gone_within 2
exit 0
