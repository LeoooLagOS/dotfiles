# 📝 nvim/ — Neovim IDE

A [LazyVim](https://www.lazyvim.org/)-based Neovim setup, linked to `~/.config/nvim`.

| Path | Purpose |
|---|---|
| `init.lua` | Entry point; bootstraps lazy.nvim through `lua/config/lazy.lua` |
| [`lua/`](lua/README.md) | Options, keymaps, autocommands and plugin specs |
| `lazyvim.json` | Enabled LazyVim extras |
| `lazy-lock.json` | Pinned plugin versions; commit it after `:Lazy update` |
| `colors/dms.lua` | `dms` colorscheme for DankMaterialShell; needs the `AvengeMedia/base46` plugin and errors out without it |

## Enabled extras

`lazyvim.json` turns on the fzf picker plus language support for Angular, Astro, C/C++ (clangd), CMake, Docker, .NET, Git, Go, Java, JSON, Kotlin, PHP, Python, R, Rust, SQL, Tailwind, Terraform, TOML, TypeScript and YAML. Manage them with `:LazyExtras`.

## Usage

```bash
nv file.py     # alias for nvim (zsh/conf.d/90-aliases.zsh)
sv /etc/hosts  # sudo nvim
```

Plugins install on first launch. `:Lazy` shows plugin status and `:checkhealth` diagnoses missing tools.
