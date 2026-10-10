# 🔭 config/quickshell — Overviews & panel

[Quickshell](https://quickshell.org/) configurations: two overviews taken from KoolDots and a custom side panel. Each one is linked individually into `~/.config/quickshell/`, so the Wallust-generated `~/.config/quickshell/qml_color.json` stays a local file outside the repo.

| Config | Keybind | What it shows |
|---|---|---|
| [`overview/`](overview/README.md) | `SUPER + A` | Every workspace with live window previews and drag-and-drop between them |
| [`qs-hyprview/`](qs-hyprview/README.md) | `SUPER CTRL + Tab` | Window exposé of the current windows, with selectable layouts |
| [`panel/`](panel/README.md) | `SUPER ALT + N` / `SUPER CTRL SHIFT + N` | Tabbed side panel: overview (clock, weather, calendar with events, system, notifications, media), media player, forecast, wallpaper picker, Wi-Fi/Bluetooth/sound controls |

## How they run

All three are started at login by the Hyprland startup config and stay resident; the keybinds talk to them over IPC:

```bash
qs ipc -c overview call overview toggle          # via scripts/wm/OverviewToggle.sh
qs -c qs-hyprview ipc call expose toggle smartgrid   # via scripts/wm/toggle-qs-hyprview.sh
qs -c panel ipc call panel toggle                    # via scripts/wm/PanelToggle.sh
```

The wrapper scripts start the daemon if it isn't running.

## qs-hyprview layout

The default layout is read from `config/hypr/UserConfigs/hyprview-layout.conf` (first line). Available layouts: `smartgrid`, `justified`, `masonry`, `bands`, `hero`, `spiral`, `satellite`, `staggered`, `columnar`, `vortex`, `random`. `scripts/wm/select-hyprview-layout.sh` picks one from a menu.

## Troubleshooting

If a keybind does nothing, check the daemon and its config link:

```bash
pgrep -af '^qs'
ls -l ~/.config/quickshell/
```

Missing links are restored with `./install.sh --only links`.
