-- User keybind overrides.
-- Add, override, or rebind keybinds here.
--
-- =============================================================================
-- KEYBIND RULES & SYNTAX
-- =============================================================================
-- • bind("MODS", "KEY", action, [options])
-- • unbind("MODS", "KEY")
--
-- Supported modifiers:
--   "SUPER", "SHIFT", "CTRL", "ALT", or combinations like "SUPER SHIFT", "SUPER ALT"
--
-- Actions:
--   • exec_cmd("command")       -> launches a terminal command or script
--   • dispatch("dispatcher", [arg]) -> triggers a Hyprland dispatcher (e.g. killactive, togglefloating)
--
-- =============================================================================
-- EXAMPLES
-- =============================================================================
--
-- NOTE ON LUA REBINDS:
--   Yes — same rule as Hyprlang applies in practice: if a key combo is already bound,
--   unbind("MODS", "KEY") first, then bind(...) it to the new action.
--   This keeps behavior explicit and avoids duplicate/conflicting binds.
--
-- 1. ADDING A BRAND NEW KEYBIND (combo not used by default):
--    bind("SUPER", "Z", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--    bind("SUPER SHIFT", "V", exec_cmd("pavucontrol"), { description = "Audio Control" })
--    bind("SUPER", "X", dispatch("killactive"), { description = "Close active window" })
--
-- 2. OVERRIDING AN EXISTING COMBO WITH A DIFFERENT APP/COMMAND:
--    -- To replace what SUPER+Return opens (default: kitty):
--    unbind("SUPER", "Return")
--    bind("SUPER", "Return", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--
-- 3. REBINDING / MOVING AN ACTION TO A NEW KEY COMBINATION:
--    -- Example: Move File Manager from SUPER+E to SUPER+F, and use SUPER+E for Emacs:
--    unbind("SUPER", "E")       -- unbind default file manager from SUPER+E
--    unbind("SUPER", "F")       -- unbind whatever SUPER+F was doing (default: fake fullscreen)
--    bind("SUPER", "F", exec_cmd("$HOME/.config/hypr/scripts/LaunchFileManager.sh '$files' '$term'"), { description = "File manager" })
--    bind("SUPER", "E", exec_cmd("emacsclient -c -a 'emacs'"), { description = "Launch Emacs" })
--
-- 4. REBINDING COMPOSITOR DISPATCHERS (e.g. workspace, fullscreen, floating):
--    unbind("SUPER", "Q")
--    bind("SUPER", "Q", dispatch("killactive"), { description = "Close active window" })
--    unbind("SUPER", "F") -- default fakefullscreen
--    bind("SUPER SHIFT", "F", dispatch("fullscreen", "0"), { description = "Toggle fullscreen" })
--    bind("SUPER ALT", "W", dispatch("workspace", "special:scratchpad"), { description = "Toggle scratchpad" })
--
-- 5. BIND OPTIONS (locked, repeating):
--    -- locked = true     -> runs even when lockscreen is active (e.g. media keys)
--    -- repeating = true  -> repeats when key is held down (e.g. volume / brightness)
--    bind("CTRL ALT", "bracketright", exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"), { description = "Brightness up", repeating = true })
--    bind("", "XF86AudioMute", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle"), { description = "Mute audio", locked = true })
--
-- =============================================================================
local user_keybinds_helper = nil
do
	local source = (debug.getinfo(1, "S") or {}).source or ""
	local source_path = source:match("^@(.+)$")
	local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
	local home = os.getenv("HOME") or ""
	local candidate_paths = {
		source_dir and (source_dir .. "/../lua/user_keybinds_helper.lua") or nil,
		home ~= "" and (home .. "/.config/hypr/lua/user_keybinds_helper.lua") or nil,
		home ~= "" and (home .. "/.config/hypr/user_keybinds_helper.lua") or nil,
	}

	local tried_paths = {}
	for _, helper_path in ipairs(candidate_paths) do
		if helper_path then
			table.insert(tried_paths, helper_path)
			local f = io.open(helper_path, "r")
			if f then
				f:close()
				local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
				if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.bind then
					user_keybinds_helper = loaded_helpers
					break
				end
			end
		end
	end

	if not user_keybinds_helper then
		error("Failed to load user_keybinds_helper.lua from: " .. table.concat(tried_paths, ", "))
	end
end
local exec_cmd = user_keybinds_helper.exec_cmd
local dispatch = user_keybinds_helper.dispatch
local bind = user_keybinds_helper.bind
local unbind = user_keybinds_helper.unbind

-- SUPER SHIFT + N used to open swaync; notifications now live in the panel
unbind("SUPER SHIFT", "N")
bind(
	"SUPER SHIFT",
	"N",
	exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh Notifications"),
	{ description = "notifications (Quickshell panel)" }
)

-- One keybind per panel tab: SUPER SHIFT + letter opens the panel on that tab,
-- or closes it if that tab is already shown (PanelToggle.sh <Tab>)
--   N Notifications · M Media · T Weather (tiempo) · V Overview · D Calendar (días)
--   P Wallpapers (papel tapiz) · C Controls
local function panel_tab(key, tab, what)
	unbind("SUPER SHIFT", key)
	bind("SUPER SHIFT", key, exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh " .. tab), { description = "panel: " .. what })
end
panel_tab("M", "Media", "media (player / radio)")
panel_tab("T", "Weather", "weather")
panel_tab("V", "Overview", "overview")
panel_tab("D", "Calendar", "calendar")
panel_tab("P", "Wallpapers", "wallpapers")
panel_tab("C", "Controls", "controls")
-- RofiBeats (online stations / local music in Rofi) moves from SUPER SHIFT M
bind("SUPER CTRL SHIFT", "M", exec_cmd("$HOME/.config/hypr/scripts/RofiBeats.sh"), { description = "online music (RofiBeats)" })

-- Quickshell side panel (profile, weather, calendar, system, media…)
-- Opened with SUPER ALT + N or SUPER CTRL SHIFT + N
bind(
	"SUPER ALT",
	"N",
	exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh"),
	{ description = "side panel (Quickshell)" }
)
bind(
	"SUPER CTRL SHIFT",
	"N",
	exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh"),
	{ description = "side panel (Quickshell), alternate" }
)

-- Panel look and desktop toggles (scripts/wm/*.sh; the panel's Settings show the same values)
local scripts = "$HOME/.config/hypr/scripts/"
bind("SUPER ALT", "P", exec_cmd("qs -c panel ipc call panel settings ''"), { description = "panel settings" })
bind("SUPER ALT", "G", exec_cmd(scripts .. "PanelBlur.sh toggle"), { description = "panel blur on/off" })
bind("SUPER ALT", "minus", exec_cmd(scripts .. "PanelOpacity.sh -5"), { description = "panel more transparent", repeating = true })
bind("SUPER ALT", "equal", exec_cmd(scripts .. "PanelOpacity.sh +5"), { description = "panel more opaque", repeating = true })
bind("SUPER ALT", "W", exec_cmd(scripts .. "WallustToggle.sh toggle"), { description = "colors from the wallpaper (wallust) on/off" })
bind("SUPER ALT", "I", exec_cmd("qs -c panel ipc call panel caffeine"), { description = "caffeine: keep the screen awake on/off" })

-- Brightness: the panel changes it and draws the level itself (panel shell.qml,
-- GlobalShortcut quickshell:brightnessUp/Down), with no script or notification
-- in between, so the bar follows the key at once. Brightness.sh still works.
for _, k in ipairs({
  { "", "xf86MonBrightnessUp", "brightnessUp", "increase monitor brightness" },
  { "", "xf86MonBrightnessDown", "brightnessDown", "decrease monitor brightness" },
  { "CTRL ALT", "equal", "brightnessUp", "increase brightness" },
  { "CTRL ALT", "minus", "brightnessDown", "decrease brightness" },
  { "CTRL ALT", "KP_Add", "brightnessUp", "increase brightness (numpad)" },
  { "CTRL ALT", "KP_Subtract", "brightnessDown", "decrease brightness (numpad)" },
}) do
  unbind(k[1], k[2])
  bind(k[1], k[2], hl.dsp.global("quickshell:" .. k[3]), { description = k[4], locked = true, repeating = true })
end
-- Volume the same way (panel services/Audio.qml: PipeWire directly). Volume.sh still works.
for _, k in ipairs({
  { "", "xf86audioraisevolume", "volumeUp", "volume up", true },
  { "", "xf86audiolowervolume", "volumeDown", "volume down", true },
  { "ALT", "xf86audioraisevolume", "volumeUpFine", "volume up 1%", true },
  { "ALT", "xf86audiolowervolume", "volumeDownFine", "volume down 1%", true },
  { "", "xf86audiomute", "volumeMute", "mute / unmute the output", false },
  { "", "xf86AudioMicMute", "micMute", "mute / unmute the microphone", false },
}) do
  unbind(k[1], k[2])
  bind(k[1], k[2], hl.dsp.global("quickshell:" .. k[3]), { description = k[4], locked = true, repeating = k[5] })
end
-- The top bar is the panel's (TopBar.qml), not waybar: SUPER CTRL ALT B hides
-- or shows it (scripts/wm/BarSwitch.sh switches back to waybar for good)
unbind("SUPER CTRL ALT", "B")
bind("SUPER CTRL ALT", "B", exec_cmd("qs -c panel ipc call panel barToggle"), { description = "top bar: hide / show" })
-- WhatsApp / Thunderbird above a dock to switch between them (the panel's
-- services/Comms.qml; each app in its own special workspace)
bind("SUPER", "Y", exec_cmd("qs -c panel ipc call panel comms"), { description = "communication apps: WhatsApp, Thunderbird, Teams with a dock (show / hide)" })
bind("SUPER SHIFT", "Y", exec_cmd("qs -c panel ipc call panel commsDock"), { description = "communication apps: the keyboard to the dock (←/→, Enter, 1–9, Esc)" })
-- Inside one of them (its window in special:comms-*), SUPER TAB / SUPER SHIFT
-- TAB go to the next / previous app of the dock (the comms lock keeps you there
-- anyway: user_window_rules.lua); anywhere else they do what they did: the
-- group's next / previous tab and the monitor's next / previous workspace
local function comms_cycle(ipc, step)
  return function()
    local w = hl.get_active_window and hl.get_active_window()
    local name = w and w.workspace and w.workspace.name
    if type(name) == "string" and name:match("^special:comms%-") then
      hl.exec_cmd("qs -c panel ipc call panel " .. ipc)
      return
    end
    -- The group's tab (nothing outside a group), then the workspace
    pcall(function() hl.dispatch(step > 0 and hl.dsp.group.next() or hl.dsp.group.prev()) end)
    hl.dispatch(hl.dsp.focus({ workspace = step > 0 and "m+1" or "m-1" }))
  end
end
unbind("SUPER", "Tab")
unbind("SUPER SHIFT", "Tab")
unbind("CTRL", "Tab")
unbind("CTRL SHIFT", "Tab")
bind("SUPER", "Tab", comms_cycle("commsNext", 1), { description = "next workspace / group tab; in the communication apps: next app" })
bind("SUPER SHIFT", "Tab", comms_cycle("commsPrev", -1), { description = "previous workspace / group tab; in the communication apps: previous app" })
-- SUPER O: the focused window out to the next empty workspace (after the
-- current one; from a special workspace, the first empty one), following it.
-- From a special workspace (a comms app: a call opened from a WhatsApp link
-- lands there) that layer is closed first, so the comms lock lets you go
local function window_to_empty()
  local w = hl.get_active_window and hl.get_active_window()
  if not w then return end
  local cur = w.workspace
  local used = {}
  for _, ws in ipairs(hl.get_workspaces()) do
    if ws.id > 0 and ws.windows > 0 then used[ws.id] = true end
  end
  local target = (cur and cur.id and cur.id > 0) and cur.id + 1 or 1
  while used[target] do target = target + 1 end
  local name = cur and cur.name or ""
  if type(name) == "string" and name:match("^special:") then
    hl.dispatch(hl.dsp.workspace.toggle_special((name:gsub("^special:", ""))))
  end
  hl.dispatch(hl.dsp.window.move({ workspace = target, follow = true, window = "address:" .. w.address }))
end
bind("SUPER", "O", window_to_empty, { description = "window out to the next empty workspace (also out of comms)" })

-- Quick capture (the panel's QuickAdd.qml): one line in plain words becomes a
-- to-do or an event; SUPER SHIFT Z starts from the selected text
bind("SUPER", "Z", exec_cmd("qs -c panel ipc call panel quickAdd ''"), { description = "quick add: a to-do or an event, in plain words" })
bind("SUPER SHIFT", "Z", exec_cmd("qs -c panel ipc call panel quickAddSelection"), { description = "quick add from the selected text" })
bind("SUPER ALT", "Print", exec_cmd("qs -c panel ipc call panel record"), { description = "screen recording start / stop (gpu-screen-recorder)" })
bind("SUPER ALT", "D", exec_cmd(scripts .. "DarkLight.sh"), { description = "dark / light theme (whole desktop)" })

-- App launcher: RofiLauncher.sh adds inline math (quickcalc) to the Apps tab
unbind("SUPER", "D")
bind("SUPER", "D", exec_cmd(scripts .. "RofiLauncher.sh"), { description = "app launcher (type math for an instant answer)" })
bind("", "XF86Calculator", exec_cmd(scripts .. "RofiCalc.sh"), { description = "calculator" })

-- Menus that had no shortcut
bind("SUPER ALT", "M", exec_cmd(scripts .. "MonitorProfiles.sh"), { description = "monitor profiles" })
bind("SUPER ALT", "K", exec_cmd(scripts .. "HyprlockWallpaperSelect.sh"), { description = "lock screen wallpaper" })
bind("SUPER ALT", "T", exec_cmd(scripts .. "ChangeStarshipPrompt.sh"), { description = "Starship prompt style" })
bind("SUPER", "J", exec_cmd(scripts .. "JavaManager.sh"), { description = "Java versions (install / set default)" })
bind("SUPER ALT", "F", exec_cmd(scripts .. "FlavorMenu.sh"), { description = "flavors: audio mode and apps (dotfiles/flavors)" })
-- The Win+X system menu: the logo opens the start menu now, this stays on the keyboard (ADR-0014)
bind("SUPER", "X", exec_cmd(scripts .. "RofiSystemMenu.sh"), { description = "system menu (Win+X style)" })
-- SUPER alone (pressed and released, nothing else in between): the start menu on
-- the logo, as in Windows. A release bind, so SUPER + any key doesn't open it
bind("SUPER", "Super_L", exec_cmd("qs -c panel ipc call panel start"), { release = true, description = "start menu (SUPER alone)" })

bind(
	"SUPER SHIFT",
	"L",
	exec_cmd("$HOME/dotfiles/scripts/wm/ToggleWeatherLoc.sh"),
	{ description = "Toggle Weather Location" }
)

-- The default XF86AudioPlayPause bind is aliased to XF86AudioPlay, so the Play
-- key had two binds and toggled twice (no net change). Keep a single one.
unbind("", "XF86AudioPlay")
bind(
	"",
	"XF86AudioPlay",
	exec_cmd("$HOME/.config/hypr/scripts/MediaCtrl.sh --pause"),
	{ description = "play/pause", locked = true }
)

-- SUPER SHIFT + { / } moves the active window one workspace left/right on the
-- monitor and follows it. The default bracket binds pass -1/+1 as numbers,
-- which Hyprland reads as workspace IDs, so they're replaced. Binds match the
-- unshifted key, so { and } are bound as bracketleft/bracketright.
unbind("SUPER SHIFT", "bracketleft")
unbind("SUPER SHIFT", "bracketright")
bind("SUPER SHIFT", "bracketleft", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "r-1" }))
end, { description = "move window to left workspace" })
bind("SUPER SHIFT", "bracketright", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "r+1" }))
end, { description = "move window to right workspace" })

-- SUPER CTRL + [ / ] does the same without following the window.
unbind("SUPER CTRL", "bracketleft")
unbind("SUPER CTRL", "bracketright")
bind("SUPER CTRL", "bracketleft", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "r-1", follow = false }))
end, { description = "move window silently to left workspace" })
bind("SUPER CTRL", "bracketright", function()
	hl.dispatch(hl.dsp.window.move({ workspace = "r+1", follow = false }))
end, { description = "move window silently to right workspace" })
