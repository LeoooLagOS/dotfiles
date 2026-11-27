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
#   chromium     every Chromium browser (Brave, Chrome, Chromium, Edge; native or Flatpak): the
#                panel writes staging/browser.json (services/BrowserTheme.qml: seed color, light /
#                dark, normal / vibrant). The seed goes live through the policy BrowserThemeColor
#                in /etc/<browser>/policies/managed/lagos-theme.json. Those
#                files are made yours once per computer: sudo scripts/wm/BrowserPolicies.sh.
#                A native browser rereads them at once; a Flatpak links them into its sandbox at
#                start and watches only that folder, so the link is remade inside each sandbox.
#                Light / dark and the variant (inverted = vibrant) have no policy: they're
#                preferences, read at start. A closed browser gets them in its profiles; an open
#                one restarts for them (BrowserRestart.sh: when it's not in front, tabs restored)
#   firefox's mode follows staging/browser.json too: `pywalfox dark | light | auto`
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
apps=(thunderbird firefox chromium vesktop obsidian nvim btop)
staged() { case $1 in firefox) echo "$stage/firefox.json" ;; chromium) echo "$stage/browser.json" ;; nvim) echo "$stage/nvim.lua" ;; btop) echo "$stage/btop.theme" ;; *) echo "$stage/$1.css" ;; esac; }
btopconf=${XDG_CONFIG_HOME:-$HOME/.config}/btop/btop.conf
btoptheme=${XDG_CONFIG_HOME:-$HOME/.config}/btop/themes/lagos-wallpaper.theme
# Chromium browsers: policy folder · Flatpak app id · native process · profile folders (Preferences)
chromium_policies=(/etc/brave/policies/managed /etc/opt/chrome/policies/managed /etc/chromium/policies/managed /etc/opt/edge/policies/managed)
chromium_flatpaks=(com.brave.Browser com.google.Chrome org.chromium.Chromium com.microsoft.Edge)
chromium_procs=(brave chrome chromium chromium-browse msedge)   # process names: 15 characters at most
chromium_profiles=("$HOME/.config/BraveSoftware/Brave-Browser" "$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"
                   "$HOME/.config/google-chrome" "$HOME/.var/app/com.google.Chrome/config/google-chrome"
                   "$HOME/.config/chromium" "$HOME/.var/app/org.chromium.Chromium/config/chromium"
                   "$HOME/.config/microsoft-edge" "$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge")
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
    chromium) local d; for d in "${chromium_policies[@]}"; do [ -w "$d/lagos-theme.json" ] && echo "$d/lagos-theme.json"; done ;;
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
    chromium)
      # Flatpaks: remake the policy's link inside each sandbox, so the running browser rereads it
      local i id d
      while read -r i id; do
        for d in "${chromium_policies[@]}"; do
          flatpak enter "$i" sh -c "[ -d '$d' ] && [ -e '/run/host$d/lagos-theme.json' ] &&
            ln -sfn '/run/host$d/lagos-theme.json' '$d/lagos-theme.json'" >/dev/null 2>&1 || true
        done
      done < <(flatpak ps --columns=instance,application 2>/dev/null | awk -v ids=" ${chromium_flatpaks[*]} " 'index(ids, " " $2 " ")')
      chromium_prefs ;;
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
    chromium) printf '{}\n' ;;  # no policy: each browser's own theme
    *) printf '/* lagOS wallpaper colors: off (Settings → Wallpaper → Apps that follow the colors) */\n' ;;
  esac
}

# What a target holds: the staged file as it is, except for the browsers' policies
render() {
  case $1 in
    chromium) jq '{BrowserThemeColor: .seed}' "$(staged chromium)" ;;
    *) cat "$(staged "$1")" ;;
  esac
}

# Chromium's light / dark and color variant: preferences, read only at start (no policy
# for them). "S V": browser.theme.color_scheme2 (0 system, 1 light, 2 dark) and color_variant2
# (0 system, 1 tonal spot = normal, 3 vibrant = inverted); with the switch off, the system's
chromium_values() {
  local src s=0 v=0; src=$(staged chromium)
  if is_on chromium && [ -s "$src" ]; then
    case $(jq -r .scheme "$src") in light) s=1 ;; dark) s=2 ;; esac
    [ "$(jq -r .variant "$src")" = vibrant ] && v=3 || v=1
  fi
  echo "$s $v"
}
# Into each browser's profiles: a closed one is written now; an open one restarts for it
# (BrowserRestart.sh: when it's not in front, its tabs restored)
chromium_prefs() {
  local s v root pref p running need flatpaks
  read -r s v < <(chromium_values)
  flatpaks=$(flatpak ps --columns=application 2>/dev/null)
  for root in "${chromium_profiles[@]}"; do
    [ -d "$root" ] || continue
    case $root in
      */.var/app/*) p=${root#*/.var/app/}; p=${p%%/*}; running=$(grep -x "$p" <<<"$flatpaks") ;;
      *) case $root in *BraveSoftware*) p=brave ;; *google-chrome*) p=chrome ;; *chromium*) p=chromium ;; *) p=msedge ;; esac
         running=$(ps -eo comm=,args= | awk -v p="$p" '($1 == p || $1 == p "-browse") && $2 !~ "^/app/" {print; exit}') ;;
    esac
    need=0
    for pref in "$root"/Default/Preferences "$root"/Profile\ */Preferences; do
      [ -f "$pref" ] || continue
      [ "$(jq -c '[.browser.theme.color_scheme2 // 0, .browser.theme.color_variant2 // 0]' "$pref")" = "[$s,$v]" ] && continue
      if [ -n "$running" ]; then need=1; continue; fi
      jq --argjson s "$s" --argjson v "$v" '.browser.theme.color_scheme2 = $s | .browser.theme.color_variant2 = $v' \
        "$pref" > "$pref.lagos" && mv "$pref.lagos" "$pref" && echo "chromium: scheme $s, variant $v → $pref"
    done
    if [ "$need" = 1 ]; then
      echo "chromium: $p restarts for its theme (scheme $s, variant $v)"
      # Its own unit: a service's leftover processes die with it (one at a time per browser)
      systemd-run --user --quiet --collect --unit="lagos-browser-restart-${p//./-}" \
        "$(dirname "$(readlink -f "$0")")/BrowserRestart.sh" "$p" 2>/dev/null || true
    fi
  done
}

# Firefox's light / dark (Pywalfox), from the browser palette's scheme; only when it changes
firefox_mode() {
  is_on firefox && command -v pywalfox >/dev/null || return 0
  local scheme last=$dir/firefox-mode
  scheme=$(jq -r '.scheme // empty' "$(staged chromium)" 2>/dev/null)
  [ -n "$scheme" ] && [ "$(cat "$last" 2>/dev/null)" != "$scheme" ] || return 0
  case $scheme in light) pywalfox light ;; dark) pywalfox dark ;; *) pywalfox auto ;; esac >/dev/null 2>&1 &&
    echo "$scheme" > "$last" && echo "firefox: $scheme"
}

apply() {
  local app=$1 new t changed=0 src; src=$(staged "$app")
  if is_on "$app" && [ -s "$src" ]; then new=$(render "$app"); else new=$(off_text "$app"); fi
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
  # Not in the policy file, so checked every time (each writes only a real change)
  [ "$app" = chromium ] && [ "$changed" = 0 ] && chromium_prefs
  [ "$app" = firefox ] && firefox_mode
  return 0
}

case "${1:-sync}" in
  sync) for a in "${apps[@]}"; do apply "$a"; done ;;
  variant|prefs) chromium_prefs ;;          # at login (lagos-browser-variant.service)
  values) chromium_values ;;                # for BrowserRestart.sh
  thunderbird|firefox|chromium|vesktop|obsidian|nvim|btop)
    app=$1
    case "${2:-}" in
      on)  [ -f "$offfile" ] && { grep -vx "$app" "$offfile" > "$offfile.tmp"; mv "$offfile.tmp" "$offfile"; } ;;
      off) is_on "$app" && echo "$app" >> "$offfile" ;;
      *) echo "usage: $0 $app on|off" >&2; exit 2 ;;
    esac
    apply "$app" ;;
  *) echo "usage: $0 [sync | variant] | APP on|off   (apps: ${apps[*]})" >&2; exit 2 ;;
esac
