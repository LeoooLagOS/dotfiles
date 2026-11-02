-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================
-- User decorations overrides template.
-- Keep this repo copy as comments only; put active custom values in:
--   ~/.config/hypr/UserConfigs/user_decorations.lua
--
-- Uncomment and edit examples below if you want defaults in the repo template.

-- Example general overrides:
hl.config({
  general = {
    border_size = 1,
    gaps_in = 4,
    gaps_out = 6,
  },
})

-- Example decoration overrides:
hl.config({
  decoration = {
    rounding = 10,
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    fullscreen_opacity = 1.0,
    dim_inactive = true,
    dim_strength = 0.1,
    dim_special = 0,     -- no dark veil behind special workspaces: the comms apps (SUPER Y) show the wallpaper
    shadow = {
      enabled = true,
      range = 2,
      render_power = 1,
      color = "rgba(8db4ffff)",
      color_inactive = "rgba(5f6578ff)",
    },
    blur = {
      enabled = true,
      size = 4,      -- soft; the level saved in ~/.config/lagos/blur-level wins (below)
      passes = 1,
      new_optimizations = true,
      xray = false,
      ignore_opacity = true,
      special = true,
      popups = true,
    },
  },
})

-- Blur strength: ~/.config/lagos/blur-level (off · soft · medium · strong),
-- set by the panel's Settings → Appearance → Blur or SUPER ALT O through
-- scripts/wm/Blur.sh, whose levels must match these
do
  local levels = {
    off = { enabled = false },
    soft = { size = 4, passes = 1 },
    medium = { size = 6, passes = 2 },
    strong = { size = 8, passes = 3 },
  }
  local f = io.open((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/lagos/blur-level", "r")
  local level = f and levels[(f:read("*l") or ""):match("^%s*(%S*)")]
  if f then f:close() end
  if level then hl.config({ decoration = { blur = level } }) end
end

-- Example group styling:
hl.config({
  group = {
    col = {
      border_active = "rgba(ffffffff)",
    },
    groupbar = {
      col = {
        active = "rgba(0f111aff)",
      },
    },
  },
})
