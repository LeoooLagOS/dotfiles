#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Playerctl
#
# Plain `playerctl` controls whichever player D-Bus lists first, so the key
# could pause Firefox while you were looking at Spotify. Every action goes to
# the player that belongs to the focused window, then to one on the current
# workspace, then to whatever is playing, then to the last player paused here.

music_icon="${XDG_CONFIG_HOME:-$HOME/.config}/swaync/icons/music.png"
last_file="${XDG_STATE_HOME:-$HOME/.local/state}/mediactrl-last-player"

# A player belongs to a window when its name ("firefox" from
# firefox.instance_1_1296, "brave", "spotify") or desktop entry is in the
# window class (org.mozilla.firefox, brave-browser, Spotify).
player_for_class() {
  local class="${1,,}" player base entry
  [[ -z "$class" ]] && return 1
  for player in $(playerctl -l 2>/dev/null); do
    base="${player%%.*}"
    entry=$(busctl --user get-property "org.mpris.MediaPlayer2.$player" /org/mpris/MediaPlayer2 \
      org.mpris.MediaPlayer2 DesktopEntry 2>/dev/null | sed -E 's/^s "(.*)"$/\1/')
    entry="${entry,,}"
    if [[ "$class" == *"${base,,}"* || (-n "$entry" && "$class" == "$entry") ]]; then
      echo "$player"
      return 0
    fi
  done
  return 1
}

pick_player() {
  local class ws player
  class=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')
  player_for_class "$class" && return 0

  ws=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id')
  for class in $(hyprctl clients -j 2>/dev/null | jq -r --argjson ws "${ws:-0}" \
    '.[] | select(.workspace.id == $ws) | .class'); do
    player_for_class "$class" && return 0
  done

  for player in $(playerctl -l 2>/dev/null); do
    [[ $(playerctl -p "$player" status 2>/dev/null) == "Playing" ]] && echo "$player" && return 0
  done

  player=$(cat "$last_file" 2>/dev/null)
  if [[ -n "$player" ]] && playerctl -l 2>/dev/null | grep -qx "$player"; then
    echo "$player"
    return 0
  fi
  playerctl -l 2>/dev/null | head -n1
}

player=$(pick_player)
if [[ -z "$player" ]]; then
  notify-send -e -u low -i "$music_icon" " Playback:" " No player"
  exit 0
fi
pctl() { playerctl -p "$player" "$@"; }

# The player's name for the notification title: its desktop entry's Name
# (org.mozilla.firefox -> Firefox, com.spotify.Client -> Spotify), else its
# MPRIS Identity. MPD plays the panel's music library.
player_label() {
  [[ "$player" == mpd ]] && echo "Library" && return
  local entry dir name
  entry=$(busctl --user get-property "org.mpris.MediaPlayer2.$player" /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2 DesktopEntry 2>/dev/null | sed -E 's/^s "(.*)"$/\1/')
  if [[ -n "$entry" ]]; then
    for dir in "$HOME/.local/share/applications" /usr/share/applications \
      "$HOME/.local/share/flatpak/exports/share/applications" /var/lib/flatpak/exports/share/applications; do
      name=$(grep -m1 '^Name=' "$dir/$entry.desktop" 2>/dev/null | cut -d= -f2-)
      [[ -n "$name" ]] && echo "$name" && return
    done
  fi
  busctl --user get-property "org.mpris.MediaPlayer2.$player" /org/mpris/MediaPlayer2 \
    org.mpris.MediaPlayer2 Identity 2>/dev/null | sed -E 's/^s "(.*)"$/\1/; s/^Mozilla //'
}

# The track's cover as a local file, or nothing. Players
# give a file:// path (MPD, Firefox) or a web URL (Spotify), downloaded once
# into the cache.
cover_art() {
  local url path cache
  url=$(pctl metadata mpris:artUrl 2>/dev/null)
  case "$url" in
  file://*)
    path="${url#file://}"
    path=$(printf '%b' "${path//%/\\x}")
    ;;
  http://* | https://*)
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/mediactrl"
    path="$cache/$(echo -n "$url" | sha1sum | cut -c1-16)"
    if [[ ! -s "$path" ]]; then
      mkdir -p "$cache"
      curl -sfL --max-time 3 -o "$path" "$url" || rm -f "$path"
    fi
    ;;
  esac
  [[ -n "$path" && -s "$path" ]] && echo "$path"
}

# notify-send with the track's cover, shown big by the panel's card
# (x-lagos-cover), else the music icon
notify_track() {
  local art
  art=$(cover_art)
  if [[ -n "$art" ]]; then
    notify-send -e -u low -i "$music_icon" -h "string:image-path:$art" -h boolean:x-lagos-cover:true "$@"
  else
    notify-send -e -u low -i "$music_icon" "$@"
  fi
}

# Play the next track
play_next() {
  pctl next
  sleep 0.3
  show_music_notification
}

# Play the previous track
play_previous() {
  pctl previous
  sleep 0.3
  show_music_notification
}

# Toggle play/pause
toggle_play_pause() {
  pctl play-pause
  mkdir -p "$(dirname "$last_file")"
  echo "$player" >"$last_file"
  sleep 0.2
  show_music_notification
}

# Stop playback
stop_playback() {
  pctl stop
  notify-send -e -u low -i "$music_icon" "Stopped · $(player_label)" ""
}

# Display notification with song information
show_music_notification() {
  status=$(pctl status)
  song_title=$(pctl metadata title)
  song_artist=$(pctl metadata artist)
  song="$song_title${song_artist:+ by $song_artist}"
  if [[ "$status" == "Playing" ]]; then
    notify_track "Now Playing · $(player_label)" "$song"
  elif [[ "$status" == "Paused" ]]; then
    notify_track "Paused · $(player_label)" "$song"
  fi
}

# Get media control action from command line argument
case "$1" in
"--nxt")
  play_next
  ;;
"--prv")
  play_previous
  ;;
"--pause")
  toggle_play_pause
  ;;
"--stop")
  stop_playback
  ;;
*)
  echo "Usage: $0 [--nxt|--prv|--pause|--stop]"
  exit 1
  ;;
esac
