# ⭐ config/starship — Prompt Profiles

A library of [Starship](https://starship.rs/) prompt profiles, linked to `~/.config/starship`.

Starship reads `~/.config/starship.toml`, which is a symlink to one of these profiles. Switch profiles with the Rofi picker `scripts/wm/ChangeStarshipPrompt.sh`, or by hand:

```bash
ln -sf ~/.config/starship/lag-os-01.toml ~/.config/starship.toml
```

| Profile | Style |
|---|---|
| `lag-os-01.toml` | lagOS house style |
| `lag-os-02.toml` | `2-line-nixos` colors, path shown as `~/first/second/.../last-but-one/last` |
| `1-line-*.toml`, `purple-1line.toml`, `simple-prompt.toml`, `vill-minimalist.toml` | Single-line prompts |
| `2-line-*.toml`, `classic.toml` | Two-line prompts |
| `chris-titus.toml`, `eric-dubois.toml`, `nobara.toml`, `ranbow.toml` | Profiles adapted from other distros and creators |

Starship is initialized last in `~/.zshrc`; see [`zsh/`](../../zsh/README.md).
