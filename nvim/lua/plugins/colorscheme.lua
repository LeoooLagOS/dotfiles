-- lagos-wallpaper (colors/lagos-wallpaper.lua) is the default: the wallpaper's colors on the
-- terminal's background, built on base16-nvim. Being the current one, it's first in the theme
-- picker (<leader>uC: fzf-lua puts the current colorscheme on top).
--
-- When the wallpaper changes, scripts/AppColors.sh rewrites ~/.config/lagos/nvim-colors.lua;
-- every open Neovim watches it and reapplies the theme, if it's the one in use.
local palette_dir = vim.fn.expand("~/.config/lagos")

local function watch_palette()
  local w = vim.uv.new_fs_event()
  if not w then return end
  w:start(palette_dir, {}, vim.schedule_wrap(function(err, file)
    if err or file ~= "nvim-colors.lua" then return end
    if vim.g.colors_name == "lagos-wallpaper" then vim.cmd.colorscheme("lagos-wallpaper") end
  end))
end

return {
  { "RRethy/base16-nvim", lazy = false, priority = 1000, config = watch_palette },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "lagos-wallpaper",
    },
  },
}
