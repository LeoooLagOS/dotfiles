# 🗂️ config/ — Application configs

Configuration for every desktop application, linked into `~/.config` by the `links` step of `install.sh`. Each directory is linked whole, except `quickshell/`, whose sub-configs are linked one by one so generated files stay local.

| Directory | Linked to | Purpose |
|---|---|---|
| [`hypr/`](hypr/README.md) | `~/.config/hypr` | Hyprland WM: Lua config engine, rules, Rofi, theming |
| `waybar/` | `~/.config/waybar` | Status bar ([below](#-waybar)) |
| `swaync/` | `~/.config/swaync` | Notification center ([below](#-swaync)) |
| [`kitty/`](kitty/README.md) | `~/.config/kitty` | GPU-accelerated terminal and its theme library |
| [`quickshell/`](quickshell/README.md) | `~/.config/quickshell/{overview,qs-hyprview}` | Workspace overview and window exposé |
| [`starship/`](starship/README.md) | `~/.config/starship` | Selectable prompt profiles |
| [`fastfetch/`](fastfetch/README.md) | `~/.config/fastfetch` | System info dashboard shown on shell start |
| `wlogout/` | `~/.config/wlogout` | Icons for the [power menu](#-power-menu) |

Most of these started as [KoolDots](https://github.com/LinuxBeginnings/Hyprland-Dots) configs; `scripts/ops/kooldots-sync` brings in upstream updates (see the [root README](../README.md#-upstream-updates-kooldots)).

## 📊 Waybar

The status bar, from KoolDots.

- `configs/` holds the bar layouts and `style/` the stylesheets. The active ones are the `config` and `style.css` symlinks, switched by `scripts/wm/WaybarLayout.sh` and `scripts/wm/WaybarStyles.sh` (so switching shows up as a change in git).
- `Modules*`, `UserModules` and `ModulesCustom` define the modules the layouts include; `UserModules` is the place for personal ones.
- `wallust/colors-waybar.css` is generated from the wallpaper by Wallust and is git-ignored.
- Reload with `scripts/wm/Refresh.sh`.

Upstream KoolDots has since moved Waybar to `~/.config/hypr/waybar`; until that migration is synced, this directory is the live one.

## 🔔 SwayNC

The notification center and its quick-settings panel, from KoolDots: `config.json` (layout, widgets, buttons), `style.css` and the `icons/` and `images/` it uses. Reload with `swaync-client -R -rs`.

## 🚪 Power menu

The power menu is `scripts/wm/PowerMenu.py`, a GTK layer-shell window that replaced wlogout, which ran an action on the first keypress.

| Key | Action | Trigger |
|---|---|---|
| L | Lock | Tap |
| O | Logout | Hold 500 ms |
| P | Shutdown | Hold 500 ms |
| R | Reboot | Hold 500 ms |
| S | Suspend | Hold 500 ms |
| Esc | Close the menu | Tap |

While a key is held, its tile fills up; releasing early drains it. Holding the left mouse button on a tile works the same way.

- It reuses the icons in `config/wlogout/icons/` and the wallust colors from `config/waybar/wallust/colors-waybar.css`. The `layout` and `style.css` in `config/wlogout/` are no longer used and are kept only for upstream syncs.
- `scripts/wm/Wlogout.sh` toggles the menu open and closed. It keeps its old name because Waybar, swaync and the Ctrl+Alt+P keybind call it.
- The blurred background comes from the `powermenu` layer rule in `config/hypr/UserConfigs/user_layer_rules.lua`.
