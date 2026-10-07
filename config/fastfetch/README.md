# 📊 config/fastfetch — System Dashboard

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) configurations, linked to `~/.config/fastfetch`.

| File | Used for |
|---|---|
| `config-pokemon.jsonc` | Shell-start dashboard when `pokemon-colorscripts` is installed; the logo is a random Pokémon piped in on stdin |
| `config-compact.jsonc` | Shell-start fallback without `pokemon-colorscripts`; uses `fedora.png` as the logo |
| `config.jsonc` | Default, used by a plain `fastfetch` |
| `config-v2.jsonc` | Alternative layout (expects a `nixos.png` logo, not tracked) |
| `fedora.png` | Logo image for the compact layout |

The shell-start dashboard is wired in `zsh/conf.d/40-plugins.zsh`, which runs the [Sentinel](../../zsh/README.md#sentinel-auditor) check right after it (first shell after boot, then at most hourly). `pokemon-colorscripts` is installed by the `shell` step of `install.sh`.

Try a layout without changing anything:

```bash
fastfetch -c ~/.config/fastfetch/config-compact.jsonc
```
