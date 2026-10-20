# nvim/lua — Configuration Modules

Lua modules loaded by LazyVim. Files under `config/` are loaded automatically at the right time; every file under `plugins/` returns lazy.nvim plugin specs that are merged with LazyVim's defaults.

## config/

| File | Purpose |
|---|---|
| `lazy.lua` | Bootstraps lazy.nvim and imports LazyVim, the Markdown extra and `plugins/` |
| `options.lua` | Editor options (e.g. `conceallevel = 2` so rendered Markdown hides its markers) |
| `keymaps.lua` | Personal keymaps on top of LazyVim's (currently empty) |
| `autocmds.lua` | Personal autocommands (currently empty) |

## plugins/

| File | Purpose |
|---|---|
| `colorscheme.lua` | Sets the LazyVim colorscheme to `base16-tokyodark-terminal` |
| `render-markdown.lua` | `render-markdown.nvim` for in-buffer Markdown rendering (Markdown and Avante buffers) |

To add a plugin, create a new file in `plugins/` returning a spec table; LazyVim picks it up on the next start.
