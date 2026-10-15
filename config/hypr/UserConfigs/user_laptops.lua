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
-- back to the laptop panel when it's unplugged.
--
-- The panel is never disabled while it's the only display: with zero outputs
-- Hyprland creates a "FALLBACK" headless output, and the panel would stay
-- black after unplugging the monitor or opening the lid. With the lid closed
-- and nothing plugged in, the panel is only blanked (DPMS), not removed.
--
-- hl.monitor() only registers a rule. Hyprland applies rules on config load
-- and when an output is plugged in, but not when one is unplugged or on lid
-- events, so a handler that finds the panel in the wrong state reloads the
-- config (which re-runs this file and applies the rule).
--
-- What closing the lid does (lock, suspend, screen off) is chosen in the
-- Quickshell panel (Settings → Power & idle) and done by scripts/LaptopLid.sh.
local laptop = "eDP-1"
local lidScript = (os.getenv("HOME") or "") .. "/.config/hypr/scripts/LaptopLid.sh"
local runtimeDir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
local reloadStamp = runtimeDir .. "/hypr-laptop-panel-reload"
local panelEnabled = nil

-- Docked = some non-internal connector is physically connected. Read from
-- sysfs instead of hl.get_monitors(): the kernel updates it before the
-- hotplug event fires, and it never lists FALLBACK/HEADLESS outputs.
local function docked()
  local p = io.popen("cat /sys/class/drm/card*-*/status 2>/dev/null; echo; ls -d /sys/class/drm/card*-* 2>/dev/null")
  if not p then
    return false
  end
  local out = p:read("*a")
  p:close()
  local statuses, names = {}, {}
  for line in out:gmatch("[^\n]+") do
    if line:find("^/sys/") then
      names[#names + 1] = line:match("card%d+%-(.+)$")
    else
      statuses[#statuses + 1] = line
    end
  end
  for i, name in ipairs(names) do
    if statuses[i] == "connected" and not name:find("^eDP") then
      return true
    end
  end
  return false
end

local function lidClosed()
  local f = io.open("/proc/acpi/button/lid/LID0/state", "r")
  if not f then
    return false
  end
  local state = f:read("*a")
  f:close()
  return state:find("closed") ~= nil
end

-- hl.get_monitors() only lists enabled outputs.
local function laptopActive()
  local ok, monitors = pcall(hl.get_monitors)
  if not ok then
    return false
  end
  for _, m in ipairs(monitors or {}) do
    local okName, name = pcall(function()
      return m.name
    end)
    if okName and name == laptop then
      return true
    end
  end
  return false
end

-- Run hyprctl in the background: a blocking call from inside a Hyprland
-- callback would wait on Hyprland itself.
local function dpms(action)
  os.execute("hyprctl dispatch hl.dsp.dpms '{ action = \"" .. action .. "\", monitor = \"" .. laptop .. "\" }' >/dev/null 2>&1 &")
end

-- At most one reload every few seconds, so a panel that fails to come up
-- can't keep reloading the config. The stamp lives in a file because a
-- reload resets this file's locals.
local function reloadConfig()
  local now = os.time()
  local f = io.open(reloadStamp, "r")
  local last = f and tonumber(f:read("*l"))
  if f then
    f:close()
  end
  if last and now - last < 5 then
    return
  end
  f = io.open(reloadStamp, "w")
  if f then
    f:write(now, "\n")
    f:close()
  end
  os.execute("(sleep 0.3; hyprctl reload) >/dev/null 2>&1 &")
end

local function syncLaptopPanel(apply)
  local enable = not docked()
  if enable ~= panelEnabled then
    panelEnabled = enable
    if enable then
      hl.monitor({ output = laptop, mode = "preferred", position = "auto", scale = 1 })
    else
      hl.monitor({ output = laptop, disabled = true })
    end
  end
  if apply and enable ~= laptopActive() then
    print("[laptop] " .. laptop .. " should be " .. (enable and "on" or "off") .. ", reloading config")
    reloadConfig()
  end
end

local function monitorName(m)
  local ok, name = pcall(function()
    return m.name
  end)
  return ok and type(name) == "string" and name or nil
end

local function isVirtual(name)
  return name ~= nil and (name:find("^FALLBACK") ~= nil or name:find("^HEADLESS") ~= nil)
end

local function lidAction()
  os.execute("\"" .. lidScript .. "\" close >/dev/null 2>&1 &")
end

hl.on("monitor.added", function(m)
  syncLaptopPanel(true)
  -- awww-daemon leaves a newly enabled output blank; re-apply the wallpapers.
  if not isVirtual(monitorName(m)) then
    os.execute("(sleep 1; \"$HOME/.config/hypr/scripts/WallpaperDaemon.sh\") >/dev/null 2>&1 &")
  end
end)

hl.on("monitor.removed", function(m)
  syncLaptopPanel(true)
  -- Unplugging the monitor with the lid closed is closing the lid undocked.
  local name = monitorName(m)
  if name ~= laptop and not isVirtual(name) and lidClosed() and not docked() then
    lidAction()
  end
end)

hl.on("hyprland.start", function()
  syncLaptopPanel(true)
end)

hl.bind("switch:on:Lid Switch", function()
  syncLaptopPanel(true)
  if lidClosed() then
    lidAction()
  end
end)

hl.bind("switch:off:Lid Switch", function()
  syncLaptopPanel(true)
  if panelEnabled then
    dpms("on")
  end
end)

-- Config load: only register the rule; Hyprland applies it after loading.
syncLaptopPanel(false)
