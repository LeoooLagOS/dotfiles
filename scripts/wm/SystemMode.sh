#!/usr/bin/env bash
# The desktop's light / dark (lagOS), for GTK and Qt apps and every app that follows the system
# (libadwaita, Electron, Chromium on "device", Firefox on "auto", Obsidian on "system"):
#   SystemMode.sh Dark | Light   switch to it
#   SystemMode.sh toggle         the other one (SUPER ALT D)
#   SystemMode.sh apply          the saved one again (at login: ApplyThemeMode.sh)
# Only what light / dark needs, each step only if it changes:
#   org.gnome.desktop.interface color-scheme (apps hear it live through the portal),
#   the GTK theme and icon theme: the counterpart of the current ones (…-Dark ↔ …-Light,
#   Breeze-Dark ↔ Breeze), not a random pick; gtk-3.0/4.0 settings.ini; Flatpak's GTK_THEME;
#   qt5ct / qt6ct colors and Kvantum (Catppuccin Mocha / Latte);
#   the state file the panel reads (Theme.systemLight) and DarkLight.sh shares.
# Unlike KoolDots' DarkLight.sh it doesn't rerun wallust (which recolors everything and restarts
# Thunderbird), kill rofi / swaync, run Refresh.sh, rewrite kitty's colors or touch waybar.
set -u
state=${XDG_STATE_HOME:-$HOME/.local/state}/hypr/theme_mode
legacy=$HOME/.cache/.theme_mode
cfg=${XDG_CONFIG_HOME:-$HOME/.config}
iface=org.gnome.desktop.interface

saved=$(cat "$state" 2>/dev/null || echo Dark)
case "${1:-toggle}" in
  Dark|dark) mode=Dark ;;
  Light|light) mode=Light ;;
  toggle) [ "$saved" = Light ] && mode=Dark || mode=Light ;;
  apply) mode=$saved ;;
  *) echo "usage: $0 Dark | Light | toggle | apply" >&2; exit 2 ;;
esac
[ "$mode" = Light ] && { other=Dark; dark=0; } || { other=Light; dark=1; }

# A theme's counterpart in this mode, if it's installed: swap Dark/Light in its name,
# or add / drop "-Dark" (Breeze ↔ Breeze-Dark); else the theme as it is
counterpart() {   # NAME KIND(themes|icons)
  local name=$1 kind=$2 c d
  for c in "${name//$other/$mode}" "${name//${other,,}/${mode,,}}" \
           "$([ "$mode" = Dark ] && echo "$name-Dark" || echo "${name%-Dark}")"; do
    [ "$c" = "$name" ] && continue
    for d in "$HOME/.$kind" "$HOME/.local/share/$kind" "/usr/share/$kind"; do
      [ -d "$d/$c" ] && { echo "$c"; return; }
    done
  done
  echo "$name"
}
setting() {   # KEY VALUE: gsettings only when it differs
  [ "$(gsettings get $iface "$1" 2>/dev/null)" = "'$2'" ] || gsettings set $iface "$1" "$2"
}

gtk=$(counterpart "$(gsettings get $iface gtk-theme | tr -d "'")" themes)
icons=$(counterpart "$(gsettings get $iface icon-theme | tr -d "'")" icons)
setting color-scheme "$([ $dark = 1 ] && echo prefer-dark || echo default)"
setting gtk-theme "$gtk"
setting icon-theme "$icons"

for dir in "$cfg/gtk-3.0" "$cfg/gtk-4.0"; do
  ini=$dir/settings.ini
  [ -f "$ini" ] || continue
  sed -i -e "s|^gtk-theme-name=.*|gtk-theme-name=$gtk|" -e "s|^gtk-icon-theme-name=.*|gtk-icon-theme-name=$icons|" \
         -e "s|^gtk-application-prefer-dark-theme=.*|gtk-application-prefer-dark-theme=$dark|" "$ini"
done

# Flatpak apps get the GTK theme by environment (only when it changed)
if command -v flatpak >/dev/null; then
  ov=$(flatpak override --user --show 2>/dev/null)
  grep -qx "GTK_THEME=$gtk" <<<"$ov" || flatpak override --user --env=GTK_THEME="$gtk"
  grep -qx "ICON_THEME=$icons" <<<"$ov" || flatpak override --user --env=ICON_THEME="$icons"
fi

# Qt: qt5ct / qt6ct colors, Kvantum
[ "$mode" = Dark ] && { scheme=Catppuccin-Mocha; kv=catppuccin-mocha-blue; } || { scheme=Catppuccin-Latte; kv=catppuccin-latte-blue; }
for q in qt5ct qt6ct; do
  conf=$cfg/$q/$q.conf
  [ -f "$conf" ] && [ -f "$cfg/$q/colors/$scheme.conf" ] &&
    sed -i "s|^color_scheme_path=.*|color_scheme_path=$cfg/$q/colors/$scheme.conf|" "$conf"
done
if command -v kvantummanager >/dev/null && ! grep -qx "theme=$kv" "$cfg/Kvantum/kvantum.kvconfig" 2>/dev/null; then
  kvantummanager --set "$kv" >/dev/null 2>&1
fi

mkdir -p "$(dirname "$state")" "$(dirname "$legacy")"
[ "$saved" = "$mode" ] || { echo "$mode" > "$state"; echo "$mode" > "$legacy"; }
echo "$mode: GTK $gtk · icons $icons · Qt $scheme"
