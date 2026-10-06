# 🐱 config/kitty — Terminal

[Kitty](https://sw.kovidgoyal.net/kitty/) configuration, linked to `~/.config/kitty`.

| File | Purpose |
|---|---|
| `kitty.conf` | Main config: FantasqueSansM Nerd Font Mono 14, 0.9 background opacity, cursor trail, remote control enabled, and the `include` line that selects the active theme |
| `kitty-themes/` | ~170 color schemes; `00-Default.conf` is the stock palette |

## Switching themes

Use the Kitty theme picker (`scripts/wm/Kitty_themes.sh`, a Rofi menu), which rewrites the `include` line in `kitty.conf` and reloads open terminals. To pick one by hand, edit that line and press `ctrl+shift+F5` in kitty.

`kitty-themes/01-Wallust.conf` is generated from the current wallpaper by Wallust and is git-ignored; select it to have the terminal follow the wallpaper.

## Related

- The dropdown terminal (`SUPER SHIFT + Return`) is a kitty instance with class `kitty-dropterm`; see [`config/hypr`](../hypr/README.md#notable-customizations).
