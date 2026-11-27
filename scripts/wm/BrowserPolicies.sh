#!/usr/bin/env bash
# Once per computer, with sudo: lets the wallpaper colors reach every Chromium browser (Brave,
# Chrome, Chromium, Edge), native or Flatpak, installed now or later. Creates each browser's
# managed policy file /etc/<browser>/policies/managed/lagos-theme.json owned by you, so
# scripts/AppColors.sh can rewrite it without sudo (panel: Settings → Wallpaper → Browsers).
#   sudo scripts/wm/BrowserPolicies.sh            set up
#   sudo scripts/wm/BrowserPolicies.sh --remove   take the files away (browsers back to their own theme)
# Firefox needs nothing here: it follows through Pywalfox (`pywalfox install` once).
set -eu
[ "$(id -u)" = 0 ] || { echo "run it with sudo" >&2; exit 1; }
user=${SUDO_USER:?run it with sudo from your user, not as root}
# A first try (2026-11) left a "recommended" one in Brave's folder: unused
rm -f /etc/brave/policies/recommended/lagos-theme.json
dirs=(/etc/brave/policies/managed /etc/opt/chrome/policies/managed /etc/chromium/policies/managed /etc/opt/edge/policies/managed)
for d in "${dirs[@]}"; do
  if [ "${1:-}" = --remove ]; then
    rm -f "$d/lagos-theme.json" && echo "removed $d/lagos-theme.json"
  else
    install -d -m 755 "$d"
    [ -f "$d/lagos-theme.json" ] || echo '{}' > "$d/lagos-theme.json"
    chown "$user:" "$d/lagos-theme.json" && chmod 644 "$d/lagos-theme.json"
    echo "ready: $d/lagos-theme.json"
  fi
done
[ "${1:-}" = --remove ] || sudo -u "$user" XDG_CONFIG_HOME="$(getent passwd "$user" | cut -d: -f6)/.config" \
  "$(dirname "$(readlink -f "$0")")/AppColors.sh" sync >/dev/null 2>&1 || true
