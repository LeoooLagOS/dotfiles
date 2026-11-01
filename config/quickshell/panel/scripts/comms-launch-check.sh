#!/usr/bin/env bash
# A communication app started from the dock that shows no window yet
# (services/Comms.qml: launch → settlePending).
#   comms-launch-check.sh alive DESKTOP_ID   exit 1 if it's surely not running
#                                            (a Flatpak with no instance and no
#                                            `flatpak run` starting it); 0 if it
#                                            is, or if that can't be told
#   comms-launch-check.sh fix DESKTOP_ID     a Flatpak whose document portal has
#                                            lost its mount (bwrap then fails:
#                                            "Can't find source path
#                                            /run/user/…/doc/by-app/…"): restarts
#                                            it and prints "portal"
set -u
mode=$1
entry=${2%.desktop}

# The Flatpak app behind the entry: X-Flatpak (its own entry) or
# X-Flatpak-Part-Of (a browser's web app), from the first entry found
flatpak_of() {
    local dirs d f
    IFS=: read -ra dirs <<< "${XDG_DATA_HOME:-$HOME/.local/share}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    for d in "${dirs[@]}"; do
        f="$d/applications/$entry.desktop"
        [[ -f $f ]] || continue
        sed -n 's/^X-Flatpak\(-Part-Of\)\?=//p' "$f" | head -1
        return
    done
}
app=$(flatpak_of)

case $mode in
    alive)
        [[ -z $app ]] && exit 0
        flatpak ps --columns=application 2>/dev/null | grep -qxF "$app" && exit 0
        pgrep -f "flatpak run .*$app" >/dev/null && exit 0
        exit 1 ;;
    fix)
        [[ -z $app ]] && exit 0
        doc="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/doc"
        if ! mountpoint -q "$doc"; then
            systemctl --user restart xdg-document-portal && echo portal
        fi ;;
esac
exit 0
