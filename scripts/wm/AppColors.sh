#!/usr/bin/env bash
# Apps that follow the wallpaper colors (panel: Settings → Wallpaper → Apps that follow the colors).
#
# wallust renders each app's colors into ~/.config/lagos/app-colors/staging/<app>.css (templates
# config/hypr/wallust/templates/colors-<app>.css). This copies them into the app while its switch
# is on, or puts the app's stock look back when it's off. Only a real change is written.
#   thunderbird  ~/.config/lagos/thunderbird-colors.css (its userChrome imports it); a change
#                restarts it hidden when idle (thunderbird-colors.path → ThunderbirdColors.sh)
#   vesktop      a Vencord theme file (enable "lagOS wallpaper" once in Vencord → Themes); live
#   obsidian     a CSS snippet in each vault (enable it once in Appearance → CSS snippets); live
#   firefox      pywal's ~/.cache/wal/colors.json for the Pywalfox add-on; `pywalfox update`; live
#   nvim         ~/.config/lagos/nvim-colors.lua for the lagos-wallpaper colorscheme; every open
#                Neovim reloads it (nvim/lua/plugins/colorscheme.lua)
#   btop         a theme file; btop.conf points at it (or back at the previous theme when off);
#                a running btop reloads (SIGUSR2)
# Starship needs nothing: its prompt uses the terminal's colors, which wallust already sets.
#
#   AppColors.sh sync            every app, per the state (on each new palette: lagos-app-colors.path)
#   AppColors.sh APP on|off      switch one app (the panel's switches run this)
# State: ~/.config/lagos/app-colors/off lists the apps turned off; missing = all on. The panel
# reads it, so this script also works on its own.
set -u
# systemd's PATH lacks ~/.local/bin (pipx: pywalfox)
PATH=$HOME/.local/bin:$PATH
dir=${XDG_CONFIG_HOME:-$HOME/.config}/lagos/app-colors
stage=$dir/staging
offfile=$dir/off
apps=(thunderbird firefox vesktop obsidian nvim btop)
staged() { case $1 in firefox) echo "$stage/firefox.json" ;; nvim) echo "$stage/nvim.lua" ;; btop) echo "$stage/btop.theme" ;; *) echo "$stage/$1.css" ;; esac; }
btopconf=${XDG_CONFIG_HOME:-$HOME/.config}/btop/btop.conf
btoptheme=${XDG_CONFIG_HOME:-$HOME/.config}/btop/themes/lagos-wallpaper.theme
mkdir -p "$stage"

is_on() { ! grep -qx "$1" "$offfile" 2>/dev/null; }

# Obsidian's vaults, from its own list (Flatpak or native)
vaults() {
  local f
  for f in "$HOME/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json" "$HOME/.config/obsidian/obsidian.json"; do
    [ -f "$f" ] && jq -r '.vaults[]?.path' "$f" 2>/dev/null
  done
}

# Where each app reads its colors (one line per file)
targets() {
  case $1 in
    thunderbird) echo "$HOME/.config/lagos/thunderbird-colors.css" ;;
    vesktop) [ -d "$HOME/.var/app/dev.vencord.Vesktop/config/vesktop" ] &&
               echo "$HOME/.var/app/dev.vencord.Vesktop/config/vesktop/themes/lagos-wallpaper.theme.css" ;;
    obsidian) vaults | while read -r v; do [ -d "$v/.obsidian" ] && echo "$v/.obsidian/snippets/lagos-wallpaper.css"; done ;;
    firefox) echo "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors.json" ;;
    nvim) echo "$HOME/.config/lagos/nvim-colors.lua" ;;
    btop) [ -f "$btopconf" ] && echo "$btoptheme" ;;
  esac
}

# After an app's colors change. btop: point btop.conf at the theme (remembering the one it had)
# or back, then a running btop reloads. Firefox: Pywalfox reads the new colors.json.
after() {
  local app=$1
  case $app in
    btop)
      [ -f "$btopconf" ] || return 0
      local cur; cur=$(sed -n 's/^color_theme = "\(.*\)"$/\1/p' "$btopconf")
      if is_on btop; then
        [ "$cur" != "$btoptheme" ] && { echo "$cur" > "$dir/btop-previous"; sed -i "s|^color_theme = .*|color_theme = \"$btoptheme\"|" "$btopconf"; }
      elif [ "$cur" = "$btoptheme" ]; then
        sed -i "s|^color_theme = .*|color_theme = \"$(cat "$dir/btop-previous" 2>/dev/null || echo Default)\"|" "$btopconf"
      fi
      pkill -USR2 -x btop 2>/dev/null || true ;;
    firefox)
      is_on firefox && command -v pywalfox >/dev/null && pywalfox update >/dev/null 2>&1 || true ;;
  esac
}

# What an app gets when its switch is off: its stock look (Vesktop keeps the header so the
# theme stays listed and enabled; it just has no colors)
off_text() {
  case $1 in
    vesktop) printf '/**\n * @name lagOS wallpaper\n * @description Off: Settings → Wallpaper → Apps that follow the colors.\n * @author lagOS\n * @version 1.0.0\n*/\n' ;;
    nvim) printf -- '-- lagOS wallpaper colors: off (Settings → Wallpaper). lagos-wallpaper falls back to its previous theme\nreturn nil\n' ;;
    btop) printf '# lagOS wallpaper colors: off (btop.conf points back at the previous theme)\n' ;;
    firefox) printf '{}\n' ;;   # Pywalfox keeps its last colors: its own "Reset" brings Firefox's back
    *) printf '/* lagOS wallpaper colors: off (Settings → Wallpaper → Apps that follow the colors) */\n' ;;
  esac
}

apply() {
  local app=$1 new t changed=0 src; src=$(staged "$app")
  if is_on "$app" && [ -s "$src" ]; then new=$(cat "$src"); else new=$(off_text "$app"); fi
  while read -r t; do
    [ -n "$t" ] || continue
    mkdir -p "$(dirname "$t")"
    [ "$(cat "$t" 2>/dev/null)" = "$new" ] && continue     # unchanged: no restart, no reload
    printf '%s\n' "$new" > "$t"                              # in place: watchers see the write
    changed=1
    echo "$app: $(is_on "$app" && echo "wallpaper colors" || echo "stock colors") → $t"
  done < <(targets "$app")
  # btop.conf follows the switch even when the theme file itself didn't change
  [ "$changed" = 1 ] || [ "$app" = btop ] && after "$app"
  return 0
}

case "${1:-sync}" in
  sync) for a in "${apps[@]}"; do apply "$a"; done ;;
  thunderbird|firefox|vesktop|obsidian|nvim|btop)
    app=$1
    case "${2:-}" in
      on)  [ -f "$offfile" ] && { grep -vx "$app" "$offfile" > "$offfile.tmp"; mv "$offfile.tmp" "$offfile"; } ;;
      off) is_on "$app" && echo "$app" >> "$offfile" ;;
      *) echo "usage: $0 $app on|off" >&2; exit 2 ;;
    esac
    apply "$app" ;;
  *) echo "usage: $0 [sync] | APP on|off   (apps: ${apps[*]})" >&2; exit 2 ;;
esac
