-- lagos-wallpaper: Neovim in the wallpaper's colors (wallust), with the terminal's background.
--
-- The palette is ~/.config/lagos/nvim-colors.lua, written by scripts/AppColors.sh from wallust's
-- output while Settings → Wallpaper → Apps that follow the colors → Neovim is on. Off, that file
-- returns nil and this falls back to the previous theme (base16-tokyodark-terminal).
-- lua/plugins/colorscheme.lua makes it the default and reapplies it when the palette changes.
local FALLBACK = "base16-tokyodark-terminal"

local ok, p = pcall(dofile, vim.fn.expand("~/.config/lagos/nvim-colors.lua"))
if not ok or type(p) ~= "table" then
  vim.cmd.colorscheme(FALLBACK)
  return
end

-- "#rrggbb" a and b mixed: t = 0 gives a, t = 1 gives b
local function mix(a, b, t)
  local function rgb(h) return tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16) end
  local r1, g1, b1 = rgb(a)
  local r2, g2, b2 = rgb(b)
  local function m(x, y) return math.floor(x + (y - x) * t + 0.5) end
  return string.format("#%02x%02x%02x", m(r1, r2), m(g1, g2), m(b1, b2))
end

-- base16 slots: 00–07 background → text, 08–0F syntax (the palette's bright half)
require("base16-colorscheme").setup({
  base00 = p.background,
  base01 = mix(p.background, p.color0, 0.45),   -- status line, folds
  base02 = mix(p.background, p.color0, 0.8),    -- selection
  base03 = p.color8,                            -- comments
  base04 = p.color7,                            -- dark text
  base05 = p.foreground,                        -- text
  base06 = p.color15,
  base07 = p.color15,
  base08 = p.color9,                            -- variables, errors
  base09 = p.color13,                           -- numbers, constants
  base0A = p.color11,                           -- types
  base0B = p.color10,                           -- strings
  base0C = p.color14,                           -- regex, escapes
  base0D = p.color12,                           -- functions (the accent)
  base0E = p.color13,                           -- keywords
  base0F = p.color4,
})

-- The terminal look: its own background (and transparency) shows through
for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "FloatBorder", "SignColumn", "LineNr",
                          "FoldColumn", "EndOfBuffer", "StatusLine", "StatusLineNC" }) do
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  hl.bg = nil
  vim.api.nvim_set_hl(0, group, hl)
end

vim.g.colors_name = "lagos-wallpaper"
