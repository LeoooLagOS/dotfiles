-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================
-- User layer-rule overrides template.

local user_layer_rules_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_layer_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_layer_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_layer_rules_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.apply_layer_rule then
          user_layer_rules_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_layer_rules_helper then
    error("Failed to load user_layer_rules_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end

local apply_layer_rule = user_layer_rules_helper.apply_layer_rule

-- Example:
-- apply_layer_rule({
--   name = "user-rofi-blur",
--   match = { namespace = "rofi" },
--   blur = true,
--   ignore_alpha = 0,
-- })

-- Power menu (scripts/wm/PowerMenu.py): blur what's behind it so the buttons
-- stay readable over busy windows.
apply_layer_rule({
  name = "user-powermenu-blur",
  match = { namespace = "powermenu" },
  blur = true,
  ignore_alpha = 0,
})

-- Frosted background for the swaync notification panel (its CSS background is translucent)
apply_layer_rule({
  name = "user-swaync-control-center-blur",
  match = { namespace = "swaync-control-center" },
  blur = true,
  -- 0 = also blur the fullscreen transparent backdrop, so the whole screen
  -- gets a soft blur while the panel is open
  ignore_alpha = 0,
})

-- Quickshell panel blur: on unless ~/.config/lagos/panel-blur says "off"
-- (scripts/wm/PanelBlur.sh, or the panel's Settings → Appearance → Blur, which
-- also change these two rules live)
local panel_blur = true
do
  local f = io.open((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/lagos/panel-blur", "r")
  if f then
    panel_blur = (f:read("*l") or "on") ~= "off"
    f:close()
  end
end

-- Quickshell panel (config/quickshell/panel): fullscreen transparent layer,
-- only the translucent card is blurred
apply_layer_rule({
  name = "user-quickshell-panel-blur",
  match = { namespace = "quickshell:panel" },
  blur = panel_blur,
  ignore_alpha = 0.05,
})

-- Quickshell panel dim: click-through layer with a ~10% backdrop, so
-- ignore_alpha = 0 softly blurs the whole screen while the pointer is on the panel
apply_layer_rule({
  name = "user-quickshell-panel-dim-blur",
  match = { namespace = "quickshell:panel-dim" },
  blur = panel_blur,
  ignore_alpha = 0,
})

-- Quickshell notification popups (config/quickshell/panel): frosted cards
apply_layer_rule({
  name = "user-quickshell-notifications-blur",
  match = { namespace = "quickshell:notifications" },
  blur = true,
  ignore_alpha = 0.05,
})

-- Quickshell dock for the communication apps (SUPER Y, CommsDock.qml): frosted
apply_layer_rule({
  name = "user-quickshell-dock-blur",
  match = { namespace = "quickshell:dock" },
  blur = true,
  ignore_alpha = 0.05,
})
