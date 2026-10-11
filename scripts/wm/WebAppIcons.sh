#!/usr/bin/env bash
# Fixes the icons of web apps installed from Brave (Flatpak) or Chromium.
# Their launchers (~/.local/share/applications/*flextop*.desktop, chrome-*.desktop)
# point Icon= at a path inside the browser's sandbox that doesn't exist on the
# host, so Rofi and other launchers show no icon. The icon itself is exported
# to ~/.local/share/icons/hicolor under the same name, so Icon= becomes that
# name. Brave may rewrite a launcher (e.g. when the site's icon changes): this
# runs at every login from UserConfigs/user_startup.lua, and can be run by hand.

set -u
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
changed=0

for f in "$apps"/*flextop*.desktop "$apps"/chrome-*.desktop; do
  [ -f "$f" ] || continue
  icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2-)
  case $icon in
    /*) [ -f "$icon" ] && continue ;;   # a real file: nothing to fix
    *) continue ;;                      # already a name
  esac
  name=$(basename "${icon%.*}")
  # Only when the theme really has it
  compgen -G "$icons/*/apps/$name.*" >/dev/null || continue
  sed -i "s|^Icon=.*|Icon=$name|" "$f"
  changed=1
done

if [ "$changed" = 1 ]; then
  command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q -f -t "$icons" 2>/dev/null
  command -v update-desktop-database >/dev/null && update-desktop-database -q "$apps" 2>/dev/null
fi
exit 0
