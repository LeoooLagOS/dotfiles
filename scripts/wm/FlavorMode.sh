#!/usr/bin/env bash
# The flavor's mode: one command for every front end (ADR-0014: the rofi menu,
# SUPER ALT F → FlavorMenu.sh, and the panel's start menu, bar/StartMenu.qml).
#   FlavorMode.sh list          JSON: every flavor, installed or not, with its
#                               name in the desktop's language, audio profile,
#                               whether it's the mode in use, and its apps
#   FlavorMode.sh set <id>      switch to it: its audio profile, right away
#   FlavorMode.sh install <id>  install it (with the ones already chosen) in a
#                               terminal: install.sh asks before each permission
# Audio profiles (flavors/<id>/manifest.json, flavors/README.md):
#   follow-music-rate          the output follows each song's rate (bit-perfect)
#   fixed-rate[-low-latency]   pinned to 48 kHz: Mixxx and the DAWs don't want
#                              the rate changing mid-session (clicks)
#   none (engineering)         the audio is left as it is
# The rate is set with pw-metadata: it lasts until another flavor is picked or
# PipeWire restarts (then it follows the music again, the Audiophile config).

here="$(dirname "$(readlink -f "$0")")"
. "$here/lagos_i18n.sh"

dots="$(dirname "$(dirname "$here")")"
flavors_dir="$dots/flavors"
chosen_file="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/flavors"
state_file="${XDG_STATE_HOME:-$HOME/.local/state}/lagos/flavor"

manifest() { jq -r "$2" "$flavors_dir/$1/manifest.json" 2>/dev/null; }
name_of() { manifest "$1" ".name.$LAGOS_LANG // .name.en"; }
profile_of() { manifest "$1" '.audioProfile // ""'; }
list_lines() { [[ -f $1 ]] && sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$1"; }

icon_of() {
  case $1 in
  audiophile) printf '' ;;            # headphones
  dj) printf '' ;;                    # a record
  producer) printf '' ;;              # faders
  *engineering) printf '' ;;          # chip
  *) printf '' ;;
  esac
}

audio_of() {
  case $1 in
  follow-music-rate) t "Audio follows the music (bit-perfect)" ;;
  fixed-rate*) t "Audio fixed at 48 kHz" ;;
  *) t "Audio unchanged" ;;
  esac
}

force_rate() { pw-metadata -n settings 0 clock.force-rate 2>/dev/null | sed -n "s/.*value:'\([0-9]*\)'.*/\1/p"; }

# The flavor in use: the last one picked, while PipeWire still matches it
active() {
  local id rate
  id=$(cat "$state_file" 2>/dev/null) || return
  [[ -d $flavors_dir/$id ]] || return
  rate=$(force_rate)
  case $(profile_of "$id") in
  follow-music-rate) [[ ${rate:-0} == 0 ]] || return ;;
  fixed-rate*) [[ ${rate:-0} != 0 ]] || return ;;
  esac
  echo "$id"
}

# A flavor's apps: its Flatpaks and the packages of its pkglist that ship a
# launcher, as "desktop-id<TAB>Name"
apps_of() {
  local id f pkg
  while read -r id; do
    for f in "$HOME/.local/share/flatpak/exports/share/applications/$id.desktop" \
      "/var/lib/flatpak/exports/share/applications/$id.desktop"; do
      [[ -f $f ]] && { desktop_line "$f"; break; }
    done
  done < <(list_lines "$flavors_dir/$1/flatpaks.txt")
  while read -r pkg; do
    rpm -ql "$pkg" 2>/dev/null | grep '^/usr/share/applications/.*\.desktop$' | while read -r f; do desktop_line "$f"; done
  done < <(list_lines "$flavors_dir/$1/pkglist.txt")
}

desktop_line() {
  grep -q '^NoDisplay=true' "$1" && return
  local name
  name=$(grep -m1 "^Name\[$LAGOS_LANG\]=" "$1" | cut -d= -f2-)
  [[ -n $name ]] || name=$(grep -m1 '^Name=' "$1" | cut -d= -f2-)
  printf '%s\t%s\n' "$(basename "$1" .desktop)" "$name"
}

cmd_list() {
  local current id
  current=$(active)
  mapfile -t chosen < <(list_lines "$chosen_file")
  for id in $(find "$flavors_dir" -mindepth 2 -maxdepth 2 -name manifest.json -printf '%h\n' | xargs -n1 basename | sort); do
    local installed=false profile
    [[ " ${chosen[*]} " == *" $id "* ]] && installed=true
    profile=$(profile_of "$id")
    apps_of "$id" | jq -Rn '[inputs | split("\t") | { id: .[0], name: .[1] }]' |
      jq -c --arg id "$id" --arg name "$(name_of "$id")" \
        --arg description "$(manifest "$id" ".description.$LAGOS_LANG // .description.en")" \
        --arg icon "$(icon_of "$id")" --arg profile "$profile" --arg audio "$(audio_of "$profile")" \
        --argjson installed "$installed" --argjson active "$([[ $id == "$current" ]] && echo true || echo false)" \
        '{ id: $id, name: $name, description: $description, icon: $icon, profile: $profile, audio: $audio,
           installed: $installed, active: $active, apps: . }'
  done | jq -s '.'
}

cmd_set() {
  local id=$1 profile
  [[ -f $flavors_dir/$id/manifest.json ]] || { echo "unknown flavor: $id" >&2; return 1; }
  profile=$(profile_of "$id")
  case $profile in
  follow-music-rate) pw-metadata -n settings 0 clock.force-rate 0 >/dev/null ;;
  fixed-rate*) pw-metadata -n settings 0 clock.force-rate 48000 >/dev/null ;;
  esac
  mkdir -p "$(dirname "$state_file")"
  echo "$id" >"$state_file"
  notify-send -a "lagOS" -i audio-card "$(t "Flavor: %1" "$(name_of "$id")")" "$(audio_of "$profile")"
}

cmd_install() {
  local id=$1 list
  [[ -f $flavors_dir/$id/manifest.json ]] || { echo "unknown flavor: $id" >&2; return 1; }
  mapfile -t chosen < <(list_lines "$chosen_file")
  list=$(IFS=,; echo "${chosen[*]:+${chosen[*]},}$id")
  setsid -f kitty --title "lagOS flavors" bash -c \
    "'$dots/install.sh' --flavors '$list' --only packages,flatpaks,links,flavors; echo; read -rp '$(t "Press Enter to close")'" >/dev/null 2>&1
}

case $1 in
list) cmd_list ;;
set) cmd_set "$2" ;;
install) cmd_install "$2" ;;
*) echo "usage: $(basename "$0") list | set <id> | install <id>" >&2; exit 2 ;;
esac
