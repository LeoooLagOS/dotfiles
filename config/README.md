# 🗂️ config/ — Application Registry

Configuration for every desktop application, linked into `~/.config` by the `links` step of `install.sh`. Each directory is linked whole, except `quickshell/`, whose sub-configs are linked one by one so generated files stay local.

| Directory | Linked to | Purpose |
|---|---|---|
| [`hypr/`](hypr/README.md) | `~/.config/hypr` | Hyprland WM: Lua config engine, rules, Rofi, theming |
| `waybar/` | `~/.config/waybar` | Status bar (below) |
| `swaync/` | `~/.config/swaync` | Notification center (below) |
| [`kitty/`](kitty/README.md) | `~/.config/kitty` | GPU-accelerated terminal and its theme library |
| [`quickshell/`](quickshell/README.md) | `~/.config/quickshell/{overview,qs-hyprview}` | Workspace overview and window exposé |
| [`starship/`](starship/README.md) | `~/.config/starship` | Selectable prompt profiles |
| [`fastfetch/`](fastfetch/README.md) | `~/.config/fastfetch` | System info dashboard shown on shell start |
| `wlogout/` | `~/.config/wlogout` | Icons for the power menu (below); `layout` and `style.css` are kept only for upstream syncs |

Most of these started as [KoolDots](https://github.com/LinuxBeginnings/Hyprland-Dots) configs; `scripts/ops/kooldots-sync` brings in upstream updates (see the [root README](../README.md#-upstream-updates-kooldots)).

## 📊 Waybar

The status bar, from KoolDots.

- `configs/` holds the bar layouts and `style/` the stylesheets. The active ones are the `config` and `style.css` symlinks, switched by `scripts/wm/WaybarLayout.sh` and `WaybarStyles.sh` (so switching shows up as a change in git).
- `Modules*`, `UserModules` and `ModulesCustom` define the modules the layouts include; `UserModules` is the place for personal ones.
- `wallust/colors-waybar.css` is generated from the wallpaper by Wallust and is git-ignored.
- Reload with `scripts/wm/Refresh.sh`.

Upstream KoolDots has since moved Waybar to `~/.config/hypr/waybar`; until that migration is synced, this directory is the live one.

## 🔔 SwayNC

The notification center and its quick-settings panel, from KoolDots: `config.json` (layout, widgets, buttons), `style.css` and the `icons/` and `images/` it uses. Reload with `swaync-client -R -rs`.

## 🚪 Power menu

The power menu is `scripts/wm/PowerMenu.py`, a GTK layer-shell window that replaced wlogout (wlogout runs an action on the first keypress).

- **L** locks immediately. **U** (logout), **O** (shutdown), **R** (reboot) and **S** (suspend) must be held for 500 ms; the tile fills while held and drains if released early. Holding the left mouse button works the same way, and Esc closes the menu.
- It reuses `config/wlogout/icons/` and the wallust colors from `waybar/wallust/colors-waybar.css`. `config/wlogout/layout` and `style.css` are no longer used.
- `scripts/wm/Wlogout.sh` (still called by Waybar, swaync and Ctrl+Alt+P) toggles it open and closed.
- The blurred background comes from the `powermenu` layer rule in `hypr/UserConfigs/user_layer_rules.lua`.
