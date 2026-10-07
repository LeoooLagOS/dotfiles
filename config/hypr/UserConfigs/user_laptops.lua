-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================
-- User laptop overrides template.
-- Add lid/display behavior here if you need laptop-specific logic.

-- Examples:
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = "1" })
-- hl.monitor({ output = "eDP-1", disabled = true })

-- Docking: show only the external monitor while one is connected, and fall
-- back to the laptop panel when it's unplugged. The lid still turns the panel
-- off when closed.
local laptop = "eDP-1"
local panelEnabled = nil

local function lidClosed()
  local f = io.open("/proc/acpi/button/lid/LID0/state", "r")
  if not f then
    return false
  end
  local state = f:read("*a")
  f:close()
  return state:find("closed") ~= nil
end

-- `gone` is the name of a monitor that is being removed and may still be
-- listed by hl.get_monitors() while its event fires.
local function syncLaptopPanel(gone)
  local ok, monitors = pcall(hl.get_monitors)
  if not ok then
    return
  end
  local docked = false
  for _, m in ipairs(monitors or {}) do
    if m.name ~= laptop and m.name ~= gone and not m.name:find("^HEADLESS") then
      docked = true
    end
  end
  local enable = not docked and not lidClosed()
  if enable == panelEnabled then
    return
  end
  panelEnabled = enable
  if enable then
    hl.monitor({ output = laptop, mode = "preferred", position = "auto", scale = 1 })
  else
    hl.monitor({ output = laptop, disabled = true })
  end
end

local function monitorName(m)
  return type(m) == "table" and m.name or nil
end

hl.on("monitor.added", function(m)
  if monitorName(m) ~= laptop then
    syncLaptopPanel()
  end
end)

hl.on("monitor.removed", function(m)
  local name = monitorName(m)
  if name ~= laptop then
    syncLaptopPanel(name)
  end
end)

hl.on("hyprland.start", function()
  syncLaptopPanel()
end)

hl.bind("switch:on:Lid Switch", function()
  syncLaptopPanel()
end)

hl.bind("switch:off:Lid Switch", function()
  syncLaptopPanel()
end)

syncLaptopPanel()
