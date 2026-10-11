#!/usr/bin/env bash
# Toggle the Quickshell side panel (config/quickshell/panel).
#   PanelToggle.sh            toggle (opens on Overview)
#   PanelToggle.sh <Tab>      open on that tab, e.g. Notifications (closes it
#                             if the panel is already showing that tab)
# Starts the panel daemon first if it isn't running.

set -euo pipefail

call() {
  if [ -n "${1:-}" ]; then
    qs -c panel ipc call panel tabToggle "$1" >/dev/null 2>&1
  else
    qs -c panel ipc call panel toggle >/dev/null 2>&1
  fi
}

call "${1:-}" && exit 0

# The panel is a user service (config/systemd/user/quickshell-panel.service)
systemctl --user start quickshell-panel.service >/dev/null 2>&1 &
for _ in $(seq 1 20); do
  sleep 0.15
  if qs -c panel ipc call panel open >/dev/null 2>&1; then
    [ -n "${1:-}" ] && qs -c panel ipc call panel tab "$1" >/dev/null 2>&1
    exit 0
  fi
done

notify-send -u low "Panel" "Quickshell panel failed to start (journalctl --user -u quickshell-panel)" 2>/dev/null || true
exit 1
