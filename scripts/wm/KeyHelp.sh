#!/usr/bin/env bash
# Every keybind, read from Hyprland itself (`hyprctl binds`), so the list is
# never older than the config: what's bound is what's shown, with the
# description given in user_keybinds.lua.
#   KeyHelp.sh          SUPER H        all of them, grouped by modifier (the
#                                      rules of ADR-0015: SUPER opens, SUPER
#                                      SHIFT a panel tab…)
#   KeyHelp.sh search   SUPER SHIFT H  "what do I press for…": the
#                                      description first, type to filter
# Reference only: Enter does nothing (a bind can be a Lua function, which
# can't be run from outside).

. "$(dirname "$(readlink -f "$0")")/lagos_i18n.sh"
mode=${1:-sheet}
rofi_theme="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/rofi/config-keybinds.rasi"

# One modifier per group, in the order of the rules, then everything else
export KH_MODE=$mode
export KH_G_SUPER="$(t "SUPER · open something (Windows' letters)")"
export KH_G_SHIFT="$(t "SUPER SHIFT · a panel tab, or the other version of SUPER + letter")"
export KH_G_ALT="$(t "SUPER ALT · switches and looks")"
export KH_G_CTRL="$(t "SUPER CTRL · windows and layouts")"
export KH_G_OTHER="$(t "Everything else")"
export KH_ALONE="$(t "alone")"

rows=$(hyprctl binds -j 2>/dev/null | python3 -c '
import json, os, sys, html

binds = json.load(sys.stdin)
# Hyprland modmask bits
MODS = [(64, "SUPER"), (4, "CTRL"), (8, "ALT"), (1, "SHIFT")]
NAMES = {
    "return": "Enter", "escape": "Esc", "delete": "Del", "space": "Space", "tab": "Tab",
    "print": "PrtSc", "period": ".", "comma": ",", "minus": "-", "equal": "=",
    "bracketleft": "[", "bracketright": "]", "slash": "/", "backslash": "\\",
    "left": "←", "right": "→", "up": "↑", "down": "↓",
    "mouse_up": "wheel ↑", "mouse_down": "wheel ↓",
    "mouse:272": "left click", "mouse:273": "right click", "mouse:274": "middle click",
}

def key_name(b):
    k = b.get("key") or ""
    if k == "Super_L" and b.get("release"):
        return "(" + os.environ["KH_ALONE"] + ")"
    if not k and b.get("keycode"):
        return "code:%d" % b["keycode"]
    low = k.lower()
    if low in NAMES:
        return NAMES[low]
    if low.startswith("xf86"):
        return k[4:]
    if low.startswith("kp_"):
        return "Num " + k[3:]
    return k.upper() if len(k) == 1 else k

def mod_list(mask):
    return [n for bit, n in MODS if mask & bit]

def group(mods):
    if mods == ["SUPER"]: return 0, os.environ["KH_G_SUPER"]
    if mods == ["SUPER", "SHIFT"]: return 1, os.environ["KH_G_SHIFT"]
    if mods == ["SUPER", "ALT"]: return 2, os.environ["KH_G_ALT"]
    if mods == ["SUPER", "CTRL"]: return 3, os.environ["KH_G_CTRL"]
    return 4, os.environ["KH_G_OTHER"]

# One line per (modifiers, description): the keys that do the same are joined
# (SUPER 1 … SUPER 0 stay apart: their descriptions differ)
merged = {}
for b in binds:
    desc = (b.get("description") or "").strip()
    if not desc or b.get("submap"):
        continue
    mods = mod_list(b.get("modmask", 0))
    k = key_name(b)
    entry = merged.setdefault((tuple(mods), desc), [])
    if k not in entry:
        entry.append(k)

esc = lambda v: html.escape(v, quote=False)
out = []
if os.environ["KH_MODE"] == "search":
    for (mods, desc), keys in sorted(merged.items(), key=lambda i: i[0][1].lower()):
        combo = " ".join(mods) + (" " if mods else "") + " / ".join(keys)
        out.append("%s   <b>%s</b>" % (esc(desc), esc(combo)))
else:
    by_group = {}
    for (mods, desc), keys in merged.items():
        by_group.setdefault(group(list(mods)), []).append((list(mods), keys, desc))
    for (_, title), items in sorted(by_group.items()):
        out.append("<span weight=\"bold\" alpha=\"60%%\">── %s ──</span>" % esc(title))
        items.sort(key=lambda i: (len(i[0]), i[0], i[1][0].lower()))
        for mods, keys, desc in items:
            combo = " ".join(mods) + (" " if mods else "") + " / ".join(keys)
            out.append("<b>%s</b>   %s" % (esc(combo), esc(desc)))
print("\n".join(out))
')

if [[ -z $rows ]]; then
  notify-send -e -u low -a Hyprland -i preferences-desktop-keyboard-shortcuts \
    "$(t "Keybinds")" "$(t "Hyprland didn't answer")"
  exit 1
fi

if [[ $mode == search ]]; then
  placeholder=$(t "What do you want to do? (screenshot, volume…)")
else
  placeholder=$(t "Search keybinds")
fi

# rofi again closes it (one key opens and closes, like the panel's tabs)
pkill -x rofi && exit 0
"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/RofiFocusedWallpaperLink.sh" >/dev/null 2>&1 || true
printf '%s\n' "$rows" |
  rofi -dmenu -i -markup-rows -no-custom -config "$rofi_theme" \
    -theme-str "entry { placeholder: \"${placeholder//\"/}\"; }" \
    -mesg "$(t "Reference only: Enter does nothing")" >/dev/null
exit 0
