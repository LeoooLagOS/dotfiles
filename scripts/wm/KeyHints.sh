#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================

# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland

# Check if rofi or yad is running and kill them if they are
if pidof rofi >/dev/null; then
  pkill rofi
fi

if pidof yad >/dev/null; then
  pkill yad
fi

# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad \
  --center \
  --title="KooL Quick Cheat Sheet" \
  --no-buttons \
  --list \
  --column=Key: \
  --column=Description: \
  --column=Comment: \
  --timeout-indicator=bottom \
  "ESC" "close this app" "" " = " "SUPER KEY (Windows Key Button)" "(SUPER KEY)" \
  " SHIFT K" "Searchable Keybinds" "(Search all Keybinds via rofi)" \
  " SHIFT E" "KooL Hyprland Settings Menu" "WindowRules,themes,defaults, etc" \
  " enter" "Terminal" "(Default:kitty)" \
  " SHIFT enter" "DropDown Terminal" " Q to close" \
  " B" "Launch Browser" "(Default browser)" \
  " A" "Quick settings" "the panel's Controls (Win+A)" \
  " CTRL A" "Desktop Overview" "Shows open apps in workspaces" \
  " D" "Application Launcher" "(rofi-wayland)" \
  " R" "Run a command" "mini terminal under the logo (Win+R)" \
  " X" "System menu" "(Win+X)" \
  " L" "Lock screen" "(Win+L)" \
  " I" "Settings" "the panel's (Win+I)" \
  " P" "Monitors" "profiles (Win+P)" \
  "CTRL SHIFT Esc" "System monitor" "(Task Manager)" \
  "ALT F4" "Close active window" "" \
  " E" "Open File Manager" "(Thunar)" \
  " S" "Google Search using rofi" "(rofi)" \
  " T" "Global theme switcher" "(rofi)" \
  " Q" "close active window" "(not kill)" \
  " Shift Q " "kills an active window" "(kill)" \
  " ALT mouse scroll up/down   " "Desktop Zoom" "Desktop Magnifier" \
  " V" "Clipboard history" "(Win+V; ALT V too)" \
  " W" "Choose wallpaper" "(Wallpaper Menu)" \
  " Shift W" "Choose wallpaper effects" "(imagemagick + awww)" \
  "CTRL ALT W" "Random wallpaper" "(via awww)" \
  " CTRL ALT B" "Hide/UnHide Waybar" "waybar" \
  " SHIFT R" "Reload Hyprland, bar and menus" "" \
  " ALT R" "Screen recording start / stop" "(Win+Alt+R; ALT Print too)" \
  " SHIFT N" "Notifications" "Quickshell panel (Notifications tab)" \
  " N" "Notifications" "the panel (Win+N)" \
  " CTRL SHIFT N" "Do Not Disturb on / off" "" \
  " ALT N" "Night light on / off" "(hyprsunset)" \
  " Print" "screenshot" "(grim)" \
  " Shift Print" "screenshot region" "(grim + slurp)" \
  " Shift S" "screenshot region" "(swappy)" \
  " CTRL Print" "screenshot timer 5 secs " "(grim)" \
  " CTRL SHIFT Print" "screenshot timer 10 secs " "(grim)" \
  "ALT Print" "Screenshot active window" "active window only" \
  "CTRL ALT P" "power-menu" "(wlogout)" \
  "CTRL ALT D" "Toggle dock" "(nwg-dock-hyprland)" \
  "CTRL ALT L" "screen lock" "(hyprlock)" \
  "CTRL ALT Del" "Power menu" "lock, log out, restart, shut down" \
  "CTRL ALT + / -" "Brightness Up / Down" "Increase/Decrease brightness" \
  " SHIFT F" "Fullscreen" "Toggles to full screen" \
  " F" "Fake Fullscreen" "Toggles to fake full screen" \
  " ALT L" "Toggle Dwindle|Scrolling|Monocle|Master layouts" "Active workspace layout" \
  " SPACEBAR" "Toggle float" "single window" \
  " ALT SPACEBAR" "Toggle all windows to float" "all windows" \
  " ALT O" "Toggle Blur" "normal or less blur" \
  " CTRL O" "Toggle Opaque ON or OFF" "on active window only" \
  " Shift A" "Animations Menu" "Choose Animations via rofi" \
  " ALT T" "Themes" "terminals (Kitty, Ghostty), prompt, menus: a tab each" \
  " SHIFT G" "Gamemode! All animations OFF or ON" "toggle" \
  " ALT E" "Rofi Emoticons" "Emoticon" \
  " H" "Launch this Quick Cheat Sheet" "" \
  "" "" "" \
  "More tips:" "https://github.com/LinuxBeginnings/Hyprland-Dots/wiki" ""
