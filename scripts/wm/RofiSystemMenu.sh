#!/usr/bin/env bash
# System menu of the bar's distro logo (config/quickshell/panel/TopBar.qml),
# like Windows' Win+X: apps, files, settings, system tools, lock and power.
# Opens under the logo (top left) with the launchers' theme; run again to close.
# Power… opens the power menu, where shutting down has to be held (PowerMenu.py).

if pidof rofi >/dev/null 2>&1; then
  pkill -x rofi 2>/dev/null || true
  exit 0
fi

S="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
config="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config.rasi"
qs_panel() { qs -c panel ipc call panel "$@" >/dev/null 2>&1; }

# label | icon (theme name) | action
entries=(
  "Apps|view-app-grid-symbolic|$S/RofiLauncher.sh"
  "Files|system-file-manager|thunar"
  "Terminal|utilities-terminal|kitty"
  "Settings|preferences-system|panel:settings"
  "System monitor|utilities-system-monitor|kitty --class btop -T btop -e btop"
  "Network|preferences-system-network|nm-connection-editor"
  "Bluetooth|preferences-system-bluetooth|blueman-manager"
  "Sound|audio-volume-high|pavucontrol"
  "Screenshot|applets-screenshooter|$S/ScreenShot.sh --area"
  "Wallpapers|preferences-desktop-wallpaper|panel:wallpapers"
  "Keybinds|preferences-desktop-keyboard-shortcuts|$S/KeyBinds.sh"
  "Update the system|system-software-update|$S/Distro_update.sh"
  "Lock|system-lock-screen|$S/LockScreen.sh"
  "Power…|system-shutdown|$S/Wlogout.sh"
)

# Under the logo: rofi already starts below the space the bar reserves, so the
# offset is only the air between them (the same 6 px gaps_out as tiled windows)
y=6

choice=$(
  for e in "${entries[@]}"; do
    IFS='|' read -r label icon _ <<<"$e"
    printf '%s\0icon\x1f%s\n' "$label" "$icon"
  done | rofi -dmenu -i -show-icons -config "$config" -p "System" -format i \
    -theme-str "window { location: north west; anchor: north west; x-offset: 8px; y-offset: ${y}px; width: 400px; }
                listview { columns: 1; lines: ${#entries[@]}; }
                mode-switcher { enabled: false; }"
)
[ -n "$choice" ] || exit 0

IFS='|' read -r _ _ action <<<"${entries[$choice]}"
case "$action" in
  panel:settings) qs_panel settings bar ;;
  panel:wallpapers) qs_panel tab Wallpapers ;;
  *) setsid -f bash -c "$action" >/dev/null 2>&1 ;;
esac
