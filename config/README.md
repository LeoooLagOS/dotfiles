# 🗂️ config/ — Application Registry

Configuration for every desktop application, linked into `~/.config` by the `links` step of `install.sh`. Each directory is linked whole, except `quickshell/`, whose sub-configs are linked one by one so generated files stay local.

| Directory | Linked to | Purpose |
|---|---|---|
| [`hypr/`](hypr/README.md) | `~/.config/hypr` | Hyprland WM: Lua config engine, rules, Rofi, theming |
| [`kitty/`](kitty/README.md) | `~/.config/kitty` | GPU-accelerated terminal and its theme library |
| [`quickshell/`](quickshell/README.md) | `~/.config/quickshell/{overview,qs-hyprview}` | Workspace overview and window exposé |
| [`starship/`](starship/README.md) | `~/.config/starship` | Selectable prompt profiles |
| [`fastfetch/`](fastfetch/README.md) | `~/.config/fastfetch` | System info dashboard shown on shell start |
| `wlogout/` | `~/.config/wlogout` | Logout / power menu (below) |

## 🚪 wlogout

A glassmorphism power menu (lock, logout, suspend, hibernate, reboot, shutdown).

- `layout` defines the buttons and the commands they run.
- `style.css` styles the menu; `icons/` holds the line/fill SVG pairs for each button.
- It is opened by `scripts/wm/Wlogout.sh`, which sizes the button margins to the focused monitor's resolution and toggles the menu off if it is already open.
