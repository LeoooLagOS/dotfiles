#!/usr/bin/env bash
# Restart a running Chromium browser to give it its theme preferences: light / dark
# (browser.theme.color_scheme2) and the color variant (color_variant2) are read only at start,
# and the file can't be edited while it runs (it writes its own back on exit).
#   BrowserRestart.sh ID   a Flatpak app id (com.brave.Browser) or a native process name (brave…)
# The values come from `AppColors.sh values` (0 system · 1 light · 2 dark, and 0 system · 1 tonal
# spot · 3 vibrant), read once the browser is closed: the latest choice wins
# Run by scripts/wm/AppColors.sh as its own systemd unit (a service's leftover processes die
# with it). Never loses tabs:
#   - the browser set to "Continue where you left off" (session.restore_on_startup = 1): once
#     none of its windows is in front, it restarts and reopens them itself
#   - else it waits until you've closed its browser windows (its web apps, like the Comms
#     dock's WhatsApp, don't count: the dock reopens them, hidden)
# Then: closed cleanly (SIGTERM), the preferences written into every profile, opened again,
# and the panel's Comms dock asked to reopen the apps that didn't come back.
set -u
id=$1
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/lagos-browser-restart-$id.lock"
flock -n 9 || exit 0          # one restart at a time per browser

case $id in
  # roots · any of its windows (web apps too) · its browser windows only
  com.brave.Browser|brave)     roots=("$HOME/.var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser" "$HOME/.config/BraveSoftware/Brave-Browser"); class='^(brave-browser|brave-.*)$'; tabs='^brave-browser$' ;;
  com.google.Chrome|chrome)    roots=("$HOME/.var/app/com.google.Chrome/config/google-chrome" "$HOME/.config/google-chrome"); class='^(google-chrome|chrome-.*)$'; tabs='^google-chrome$' ;;
  org.chromium.Chromium|chromium|chromium-browse) roots=("$HOME/.var/app/org.chromium.Chromium/config/chromium" "$HOME/.config/chromium"); class='^(chromium|chromium-browser|chrome-.*)$'; tabs='^(chromium|chromium-browser)$' ;;
  com.microsoft.Edge|msedge)   roots=("$HOME/.var/app/com.microsoft.Edge/config/microsoft-edge" "$HOME/.config/microsoft-edge"); class='^(microsoft-edge|msedge-.*)$'; tabs='^microsoft-edge$' ;;
  *) echo "unknown browser $id" >&2; exit 2 ;;
esac
flatpak=0; [[ $id == *.* ]] && flatpak=1

# The browser's main process (its name: brave, chrome, chromium, msedge), not a helper (no
# --type=); a Flatpak's runs from /app/
case $id in *brave*) proc=brave ;; *Chrome|chrome) proc=chrome ;; *Edge|msedge) proc=msedge ;; *) proc=chromium ;; esac
main_pid() {
  ps -eo pid=,comm=,args= | awk -v p="$proc" -v fp="$flatpak" \
    '($2 == p || $2 == p "-browse") && $0 !~ /--type=/ && ((fp == 1) == ($3 ~ "^/app/")) {print $1; exit}'
}

pid=$(main_pid)
[ -n "$pid" ] || exit 0

# Does it reopen its tabs by itself? (any profile set to "Continue where you left off")
restores=0
for root in "${roots[@]}"; do
  for pref in "$root"/Default/Preferences "$root"/Profile\ */Preferences; do
    [ -f "$pref" ] && [ "$(jq '.session.restore_on_startup // 0' "$pref")" = 1 ] && restores=1
  done
done
in_front() { hyprctl activewindow -j 2>/dev/null | jq -e --arg re "$class" '.class // "" | test($re; "i")' >/dev/null; }
tab_windows() { hyprctl clients -j 2>/dev/null | jq -e --arg re "$tabs" 'any(.[]; .class | test($re; "i"))' >/dev/null; }
if [ $restores = 1 ]; then
  while in_front; do sleep 3; done                      # not while you're using it
else
  echo "browser-restart: $id waits until its windows are closed (it doesn't reopen tabs by itself)"
  while tab_windows || in_front; do sleep 5; done       # no tabs to lose
fi
pid=$(main_pid); [ -n "$pid" ] || exit 0
exe=$(readlink -f "/proc/$pid/exe")

echo "browser-restart: closing $id ($pid) for its theme"
kill -TERM "$pid"
for _ in $(seq 40); do kill -0 "$pid" 2>/dev/null || break; sleep 0.5; done
if kill -0 "$pid" 2>/dev/null; then echo "browser-restart: $id didn't close; left as it is" >&2; exit 1; fi

read -r scheme variant < <("$(dirname "$(readlink -f "$0")")/AppColors.sh" values)
for root in "${roots[@]}"; do
  for pref in "$root"/Default/Preferences "$root"/Profile\ */Preferences; do
    [ -f "$pref" ] || continue
    jq --argjson s "$scheme" --argjson v "$variant" \
       '.browser.theme.color_scheme2 = $s | .browser.theme.color_variant2 = $v' "$pref" > "$pref.lagos" &&
      mv "$pref.lagos" "$pref" && echo "browser-restart: scheme $scheme, variant $variant → $pref"
  done
done

# Open it again through Hyprland (its environment)
if [ $flatpak = 1 ]; then cmd="flatpak run $id"; else cmd="$exe"; fi
[ $restores = 1 ] || cmd="$cmd --no-startup-window"       # its windows were closed: none to open
hyprctl dispatch "hl.dsp.exec_cmd(\"$cmd\")" >/dev/null 2>&1 || hyprctl dispatch exec "$cmd" >/dev/null 2>&1
sleep 6
qs -c panel ipc call panel commsStart >/dev/null 2>&1 || true
