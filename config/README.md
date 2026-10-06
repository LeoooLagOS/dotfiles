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
| `wlogout/` | `~/.config/wlogout` | Logout / power menu (below) |

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

## 🚪 wlogout

A glassmorphism power menu (lock, logout, suspend, hibernate, reboot, shutdown).

- `layout` defines the buttons and the commands they run.
- `style.css` styles the menu; `icons/` holds the line/fill SVG pairs for each button.
- It is opened by `scripts/wm/Wlogout.sh`, which sizes the button margins to the focused monitor's resolution and toggles the menu off if it is already open.
