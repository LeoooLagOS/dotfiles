#!/usr/bin/env bash
# Flavors (SUPER ALT F): switch the desktop to one of the installed flavors
# (flavors/README.md). Picking one applies its audio profile right away and
# then lists its apps to open (Esc: just the audio). Flavors not installed yet
# are listed last; picking one installs it in a terminal.
# The keyboard path; the start menu on the bar's logo is the mouse path. Both
# go through FlavorMode.sh, which holds the logic (ADR-0014).

if pidof rofi >/dev/null; then
  pkill -x rofi
  sleep 0.1
fi

here="$(dirname "$(readlink -f "$0")")"
. "$here/lagos_i18n.sh"
theme="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config.rasi"

rofi_menu() { # prompt message → the chosen line's index
  rofi -dmenu -i -format i -p "$1" -mesg "$2" -config "$theme" \
    -theme-str 'window { width: 640px; } listview { columns: 1; lines: 8; } element-icon { size: 0; }
                inputbar { children: [ "prompt", "entry" ]; }'
}

flavors=$("$here/FlavorMode.sh" list) || exit 1

# --- Which flavor: installed first, then the ones to install ---
mapfile -t ids < <(jq -r 'sort_by(.installed | not) | .[].id' <<<"$flavors")
i=$(jq -r --arg install "$(t "Install %1" "§")" 'sort_by(.installed | not) | .[] |
      if .installed then "\(if .active then "●" else " " end)  \(.icon)  \(.name)  ·  \(.audio)"
      else "   \(.icon)  \($install | sub("§"; .name))" end' <<<"$flavors" |
  rofi_menu "$(t "Flavors")" "$(t "Switch the audio mode and open its apps")") || exit 0
pick=${ids[$i]}

if [[ $(jq -r --arg id "$pick" '.[] | select(.id == $id) | .installed' <<<"$flavors") != true ]]; then
  exec "$here/FlavorMode.sh" install "$pick"
fi

"$here/FlavorMode.sh" set "$pick"

# --- Its apps ---
mapfile -t apps < <(jq -r --arg id "$pick" '.[] | select(.id == $id) | .apps[] | "\(.id)\t\(.name)"' <<<"$flavors")
[[ ${#apps[@]} -gt 0 ]] || exit 0
name=$(jq -r --arg id "$pick" '.[] | select(.id == $id) | .name' <<<"$flavors")
i=$(printf '%s\n' "${apps[@]}" | cut -f2 | rofi_menu "$name" "$(t "Open an app (Esc: none)")") || exit 0
setsid -f gtk-launch "${apps[$i]%%$'\t'*}" >/dev/null 2>&1
