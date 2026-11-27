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

-- SUPER SHIFT N: Do Not Disturb, SUPER N's other version (SUPER N opens the
-- notifications; it was SUPER CTRL SHIFT N, three modifiers for a daily key).
-- Said on the island
unbind("SUPER SHIFT", "N")
bind("SUPER SHIFT", "N", exec_cmd("qs -c panel ipc call panel toggleDnd"), { description = "Do Not Disturb on/off" })

-- One keybind per panel tab: SUPER SHIFT + letter opens the panel on that tab,
-- or closes it if that tab is already shown (PanelToggle.sh <Tab>)
--   M Media · T Weather (tiempo) · V Overview · D Calendar (días)
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

-- =============================================================================
-- Keybind layout (vault: lagOS_Panel/ADRs/ADR-0015_Keybind_Layout)
--   SUPER + letter         open something; Windows' letters do what they do there
--   SUPER SHIFT + letter   a tab of the panel (above)
--   SUPER ALT + letter     switches and looks (caffeine, blur, dark / light…)
--   SUPER CTRL + letter    windows and layouts
-- =============================================================================
local wm = "$HOME/.config/hypr/scripts/"
-- Each Windows key: what was on it moves to the SUPER CTRL / SUPER ALT twin
local function move(mods, key, new_mods, new_key, action, what)
	unbind(mods, key)
	unbind(new_mods, new_key)
	bind(new_mods, new_key, action, { description = what })
end
local function win(mods, key, action, what, opts)
	unbind(mods, key)
	local o = opts or {}
	o.description = what
	bind(mods, key, action, o)
end

-- SUPER R: Run, a one-line "mini terminal" under the logo (Win+R)
win("SUPER", "R", exec_cmd(wm .. "RofiRun.sh"), "run a command (Win+R)")
-- SUPER ALT R: screen recording (Win+Alt+R); SUPER ALT Print still works.
-- Refreshing the bar and menus moves to SUPER SHIFT R, and reloads Hyprland too
win("SUPER ALT", "R", exec_cmd("qs -c panel ipc call panel record"), "screen recording start / stop (Win+Alt+R)")
win("SUPER SHIFT", "R", exec_cmd("hyprctl reload && " .. wm .. "Refresh.sh"), "reload Hyprland, refresh bar and menus")
-- SUPER L: lock (Win+L); CTRL ALT L still works
win("SUPER", "L", exec_cmd(wm .. "LockScreen.sh"), "lock screen (Win+L)")
-- SUPER I: the panel's Settings (Win+I)
win("SUPER", "I", exec_cmd("qs -c panel ipc call panel settings ''"), "settings (Win+I)")
-- SUPER N: notifications (Win+N); the night light moves to SUPER ALT N
-- (the panel's plain toggle was SUPER ALT N: SUPER N, SUPER A and the
-- SUPER SHIFT tabs open it)
move("SUPER", "N", "SUPER ALT", "N", exec_cmd(wm .. "Hyprsunset.sh toggle"), "night light on/off")
win("SUPER", "N", exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh Notifications"), "notifications (Win+N)")
-- SUPER A: the panel's Controls, the quick settings (Win+A); the desktop
-- overview moves to SUPER CTRL A (it was Ags', which isn't installed)
move("SUPER", "A", "SUPER CTRL", "A", exec_cmd(wm .. "OverviewToggle.sh"), "desktop overview")
win("SUPER", "A", exec_cmd("$HOME/dotfiles/scripts/wm/PanelToggle.sh Controls"), "quick settings: the panel's Controls (Win+A)")
-- SUPER V: clipboard history (Win+V)
win("SUPER", "V", exec_cmd(wm .. "ClipManager.sh"), "clipboard history (Win+V)")
-- SUPER P: monitors (Win+P)
move("SUPER", "P", "SUPER CTRL", "P", dispatch("pseudo", ""), "toggle pseudo (dwindle)")
win("SUPER", "P", exec_cmd(wm .. "MonitorProfiles.sh"), "monitor profiles (Win+P)")
-- CTRL SHIFT Esc: the system monitor (Task Manager)
win("CTRL SHIFT", "Escape", exec_cmd("qs -c panel ipc call panel systemMonitor"), "system monitor (Task Manager)")
-- ALT F4: close the window
win("ALT", "F4", dispatch("killactive", ""), "close active window (Alt+F4)")
-- CTRL ALT Del: the power menu. It quit Hyprland at once, everything open lost,
-- the first thing someone from Windows presses when something hangs; quitting
-- is the power menu's Logout
win("CTRL ALT", "Delete", exec_cmd(wm .. "Wlogout.sh"), "power menu: lock, log out, restart, shut down")
-- CTRL ALT P: the same, for one hand (Del is far on some keyboards)
win("CTRL ALT", "P", exec_cmd(wm .. "Wlogout.sh"), "power menu (CTRL ALT Del is far)")
-- SUPER C: Connections, the SSH hosts of ~/.ssh/config
win("SUPER", "C", exec_cmd(wm .. "rofi-ssh-menu.sh"), "connections: SSH sessions (~/.ssh/config)")
-- ALT SHIFT Tab: the previous window, ALT Tab's pair (it was SUPER K)
win("ALT SHIFT", "Tab", exec_cmd(wm .. "LuaCycleWindow.sh previous"), "previous window")

-- SUPER SHIFT + letter is a panel tab or the other version of SUPER + that
-- letter (R reload, Q force kill, W wallpaper effects, H search a key…).
-- KoolDots' others move to SUPER ALT, a switch or a look, or go
move("SUPER SHIFT", "A", "SUPER ALT", "A", exec_cmd(wm .. "Animations.sh"), "animations menu")
move("SUPER SHIFT", "G", "SUPER ALT", "G", exec_cmd(wm .. "GameMode.sh"), "game mode on/off")
-- Muting the window: SUPER ALT V (volume); SUPER ALT M is the modes menu (ADR-0016)
move("SUPER SHIFT", "H", "SUPER ALT", "V", exec_cmd(wm .. "Toggle-Active-Window-Audio.sh"), "mute / unmute the focused window")
win("SUPER ALT", "M", exec_cmd("qs -c panel ipc call panel modes"), "modes: work, study, pomodoro, sleep… (the bar's menu)")
unbind("SUPER SHIFT", "E")       -- KoolDots' quick settings: the panel's Settings (SUPER I)
unbind("SUPER SHIFT", "B")       -- static rainbow border
-- SUPER H: every keybind, read from Hyprland itself, so it can't go stale;
-- SUPER SHIFT H: the same list to search ("screenshot" → the key)
win("SUPER", "H", exec_cmd(wm .. "KeyHelp.sh"), "keybinds: all of them, by modifier")
win("SUPER SHIFT", "H", exec_cmd(wm .. "KeyHelp.sh search"), "keybinds: search what a key does")
unbind("SUPER SHIFT", "K")       -- KeyBinds.sh read the old .conf files
-- Duplicates of a Windows key
unbind("SUPER", "M")             -- split ratio 0.3 (dwindle): SUPER CTRL L, SUPER SHIFT arrows
unbind("SUPER", "k")             -- previous window: ALT SHIFT Tab

-- Screenshots, as in Windows (ScreenShot.sh):
--   SUPER SHIFT S     an area, to the clipboard; the notice opens the editor
--   SUPER Print       the whole screen      ALT Print  the focused window
--   SUPER CTRL Print  the screen in 5 s     SUPER ALT R / SUPER ALT Print  recording
win("SUPER SHIFT", "S", exec_cmd(wm .. "ScreenShot.sh --swappy"), "screenshot of an area (Win+Shift+S)")
for _, k in ipairs({
	{ "SUPER SHIFT", "Print" },          -- an area: SUPER SHIFT S
	{ "SUPER CTRL SHIFT", "Print" },     -- 10 s: SUPER CTRL Print waits 5
	{ "ALT SHIFT", "S" },                -- Hyprshot's area
	{ "SUPER", "F6" }, { "SUPER SHIFT", "F6" }, { "SUPER CTRL", "F6" }, { "SUPER ALT", "F6" }, { "ALT", "F6" },
}) do
	unbind(k[1], k[2])
end

-- =============================================================================
-- Window layouts: one letter, L
--   SUPER ALT L    the next layout (master → dwindle → scrolling → monocle)
--   SUPER CTRL L   the current layout's own move:
--                    dwindle    turn the split (side by side ↔ one over the other)
--                    master     the window to the big side (swap with the main one)
--                    scrolling  the next column width
--                    monocle    the next window
-- They were on four letters (SUPER SHIFT I, SUPER CTRL I, SUPER CTRL R, SUPER
-- CTRL Return), and a key used in another layout showed Hyprland's red Lua
-- error. The keys that only exist in one layout now go through
-- ChangeLayout.sh too, which says in a short notice where they work.
-- =============================================================================
local layout = wm .. "ChangeLayout.sh "
local function only_in(layouts, msg)
	return exec_cmd(layout .. "msg '" .. msg .. "' " .. layouts)
end
win("SUPER ALT", "L", exec_cmd(layout .. "toggle"), "next window layout: master → dwindle → scrolling → monocle")
win("SUPER CTRL", "L", exec_cmd(layout .. "action"),"the layout's own move: split, main window, column width, next window")
unbind("SUPER SHIFT", "I")       -- toggle split: SUPER CTRL L in dwindle
unbind("SUPER CTRL", "I")        -- add master: SUPER CTRL L in master swaps with it
unbind("SUPER CTRL", "R")        -- column width: SUPER CTRL L in scrolling
win("SUPER CTRL", "Return", only_in("master", "swapwithmaster auto"), "swap with master (master)")
win("SUPER CTRL", "D", only_in("master", "removemaster"), "remove master (master)")
-- "move ±col" scrolls the view a column (the window stays where it is);
-- moving the window is swapcol, below
win("SUPER SHIFT", "period", only_in("scrolling", "move +col"), "scroll the view a column right (scrolling)")
win("SUPER SHIFT", "comma", only_in("scrolling", "move -col"), "scroll the view a column left (scrolling)")
win("SUPER ALT", "period", only_in("scrolling", "swapcol r"), "move the window's column right (scrolling)")
win("SUPER ALT", "comma", only_in("scrolling", "swapcol l"), "move the window's column left (scrolling)")
-- Scrolling's strip sideways <-> up and down. SUPER ALT H / SUPER CTRL V set
-- each way with `hyprctl keyword`, which a Lua config doesn't have: one toggle
win("SUPER ALT", "S", exec_cmd(layout .. "direction"), "scrolling: sideways <-> up and down")
unbind("SUPER ALT", "H")
unbind("SUPER CTRL", "V")
-- Groups: "move right into group" was SUPER CTRL L; J and K are a pair now
win("SUPER CTRL", "K", dispatch("moveintogroup", "r"), "move right into group")

-- Cleanup: binds for things that aren't here any more
unbind("SUPER ALT", "B")         -- waybar layout menu (the bar is the panel's)
unbind("SUPER CTRL", "B")        -- waybar styles menu
unbind("SUPER", "j")             -- "cycle next (layout-aware)": SUPER J opens Java
-- SUPER CTRL K (Kitty themes, now SUPER ALT T) is "move right into group" above
unbind("SUPER CTRL", "G")        -- Ghostty themes: SUPER ALT T
unbind("SUPER CTRL SHIFT", "R")  -- rofi themes (modified): SUPER ALT T
unbind("SUPER SHIFT", "O")       -- Oh My Zsh themes: Starship draws the prompt

-- Do Not Disturb moved to SUPER SHIFT N (top of the file)
unbind("SUPER CTRL SHIFT", "N")

-- Panel look and desktop toggles (scripts/wm/*.sh; the panel's Settings show the same values)
local scripts = "$HOME/.config/hypr/scripts/"
-- Blur strength: KoolDots' ChangeBlur.sh went up to "Ultra" behind the panel's
-- back and was lost on reload; Blur.sh saves it and the panel's Settings follow
-- ("off" is one of the steps: the on/off key SUPER ALT G is game mode now)
unbind("SUPER ALT", "O")
bind("SUPER ALT", "O", exec_cmd(scripts .. "Blur.sh level cycle"), { description = "blur strength: off · soft · medium · strong" })
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
-- The focused window's opacity the same way (panel services/WindowOpacity.qml):
-- KoolDots' ToggleOpacity.sh showed its level only after a dozen hyprctl / jq calls
unbind("SUPER CTRL", "O")
bind("SUPER CTRL", "O", hl.dsp.global("quickshell:windowOpacity"), { description = "window opacity: 100 → 85 → 70 → 50 %" })
-- SUPER CTRL + wheel: ±2 % without leaving the window (the pointer on the
-- level's popup would move the focus, follow_mouse)
bind("SUPER CTRL", "mouse_up", hl.dsp.global("quickshell:windowOpacityUp"), { description = "window opacity +2 %" })
bind("SUPER CTRL", "mouse_down", hl.dsp.global("quickshell:windowOpacityDown"), { description = "window opacity −2 %" })
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
bind("SUPER ALT", "D", exec_cmd(scripts .. "SystemMode.sh toggle"), { description = "dark / light theme (whole desktop)" })

-- App launcher: RofiLauncher.sh (Apps · Files · Run · Windows · Calc tabs)
unbind("SUPER", "D")
bind("SUPER", "D", exec_cmd(scripts .. "RofiLauncher.sh"), { description = "app launcher (apps, files, run, windows, calculator)" })
bind("", "XF86Calculator", exec_cmd(scripts .. "RofiCalc.sh"), { description = "calculator" })

-- Menus that had no shortcut
bind("SUPER ALT", "K", exec_cmd(scripts .. "HyprlockWallpaperSelect.sh"), { description = "lock screen wallpaper" })
-- Themes of the terminals, the prompt and the menus, in one menu with a tab
-- each (RofiThemes.sh); they had a keybind each (SUPER CTRL K / G / R,
-- SUPER CTRL SHIFT R, SUPER ALT T was the prompt alone)
bind("SUPER ALT", "T", exec_cmd(scripts .. "RofiThemes.sh"), { description = "themes: terminals (Kitty, Ghostty), prompt, menus" })
bind("SUPER", "J", exec_cmd(scripts .. "JavaManager.sh"), { description = "Java versions (install / set default)" })
bind("SUPER ALT", "F", exec_cmd(scripts .. "FlavorMenu.sh"), { description = "flavors: audio mode and apps (dotfiles/flavors)" })
-- The Win+X system menu: the logo opens the start menu now, this stays on the keyboard (ADR-0014)
bind("SUPER", "X", exec_cmd(scripts .. "RofiSystemMenu.sh"), { description = "system menu (Win+X style)" })
-- SUPER alone (pressed and released, nothing else in between): the start menu on
-- the logo, as in Windows. A release bind, so SUPER + any key doesn't open it
bind("SUPER", "Super_L", exec_cmd("qs -c panel ipc call panel start"), { release = true, description = "start menu (SUPER alone)" })

-- Laptop screen still black after waking up: reconnect it (PanelRelink.py; the
-- lagos-panel-relink service does it on its own, this is the manual rescue).
-- locked = true so it works on the lock screen, pressed blind.
bind("SUPER CTRL ALT", "P", exec_cmd(scripts .. "PanelRelink.py now"), { description = "laptop screen black after waking: reconnect it", locked = true })

-- The weather's place is chosen in the panel's Weather tab (SUPER SHIFT T)
unbind("SUPER SHIFT", "L")

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
