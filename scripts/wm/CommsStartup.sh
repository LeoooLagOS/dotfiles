#!/usr/bin/env bash
# Communication apps at login: the panel opens each app of its Comms dock
# (Settings → Comms dock: WhatsApp, Thunderbird, Teams… by default), hidden in
# its own special workspace special:comms-<app>, so their notifications arrive.
# SUPER Y shows them above the dock (the panel's services/Comms.qml, CommsDock.qml).
# Run once per session from UserConfigs/user_startup.lua; safe to run by hand.
# The panel may still be starting: try for up to a minute.

for _ in $(seq 1 60); do
  qs -c panel ipc call panel commsStart >/dev/null 2>&1 && exit 0
  sleep 1
done
echo "CommsStartup: the panel didn't answer" >&2
exit 1
