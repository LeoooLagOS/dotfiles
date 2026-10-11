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
