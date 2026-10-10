#!/usr/bin/env bash
# Waybar status for the notification module (custom/swaync in ModulesCustom).
# Same JSON shape as `swaync-client -swb`, read from the state the Quickshell
# panel writes on every change (it then sends SIGRTMIN+11 to waybar).
state="$HOME/.cache/quickshell-panel/notifs"
read -r count dnd 2>/dev/null <"$state" || { count=0; dnd=0; }
count=${count:-0}; dnd=${dnd:-0}

alt="none"
[ "$count" -gt 0 ] && alt="notification"
[ "$dnd" = 1 ] && alt="dnd-$alt"

tooltip="$count notification$([ "$count" = 1 ] || echo s)"
[ "$dnd" = 1 ] && tooltip="$tooltip (Do not disturb)"

printf '{"text":"%s","alt":"%s","tooltip":"%s","class":"%s"}\n' "$count" "$alt" "$tooltip" "$alt"
