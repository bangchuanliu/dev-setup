local wezterm = require("wezterm")

local config = wezterm.config_builder()

----------------------------------------------------------------------
-- Appearance
----------------------------------------------------------------------

config.color_scheme = "Dracula"
config.font = wezterm.font_with_fallback({
	"Meslo LG L DZ for Powerline",
})
config.font_size = 16.0
config.line_height = 1.1
-- Disable ligatures (e.g. "fi") to avoid glyph-width rendering artifacts
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_background_opacity = 0.96
config.macos_window_background_blur = 20

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false

config.send_composed_key_when_left_alt_is_pressed = true
config.send_composed_key_when_right_alt_is_pressed = false
----------------------------------------------------------------------
-- Performance
----------------------------------------------------------------------

config.front_end = "WebGpu"
config.animation_fps = 120
config.max_fps = 120

----------------------------------------------------------------------
-- Cursor
----------------------------------------------------------------------

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 600

----------------------------------------------------------------------
-- Clipboard
----------------------------------------------------------------------

config.selection_word_boundary = " \t\n{}[]()\"'`,;:@"

-- WezTerm recognizes URLs and file:// URIs by default, but terminal output
-- commonly contains plain paths (absolute, home-relative, or relative to the
-- shell's cwd), often followed by :line or :line:col. Turn those into links
-- so Command-click can open them with macOS.
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Absolute paths, e.g. /Users/me/project/foo.lua
-- (not preceded by ~, a word char, or . -- those belong to the other rules)
table.insert(config.hyperlink_rules, {
	regex = [[(?<![\w~.])/[\w./~_-]+]],
	format = "file://$0",
})

-- Home-relative paths, e.g. ~/project/foo.lua
table.insert(config.hyperlink_rules, {
	regex = [[~(/[\w./_-]+)]],
	format = "file://" .. (os.getenv("HOME") or "") .. "$1",
})

-- Paths relative to the shell's current working directory, e.g.
-- src/foo.ts, ./foo.lua, or compiler-style foo.go:12:5. These can't be
-- resolved to an absolute path at config-load time, so they're tagged with
-- a custom scheme and resolved against the pane's actual cwd (via OSC 7)
-- in the open-uri handler below.
table.insert(config.hyperlink_rules, {
	regex = [[(?<![\w./-])((?:\.\.?/|[\w-]+/)[\w./-]*\.\w+)(:\d+(:\d+)?)?]],
	format = "relfile://$1",
})

-- Bare filenames with no directory component, e.g. the last column of
-- `ls -l`/`ll` output (Brewfile, install.sh, README.md). Only matched at
-- end-of-line and must start with a letter/underscore so it doesn't catch
-- numeric tokens like file sizes (2.6K) or IP addresses (127.0.0.1).
table.insert(config.hyperlink_rules, {
	regex = [[(?<![\w./-])([A-Za-z_][\w-]*\.\w{1,10})(?=\s*$)]],
	format = "relfile://$1",
})

-- Resolve and open the custom relfile:// links created above.
wezterm.on("open-uri", function(window, pane, uri)
	local relpath = uri:match("^relfile://(.+)$")
	if not relpath then
		return true
	end

	local base_dir = os.getenv("HOME")
	local cwd_url = pane:get_current_working_dir()
	if cwd_url then
		base_dir = cwd_url.file_path
	end

	local full_path = base_dir .. "/" .. relpath
	wezterm.open_with(full_path)
	return false
end)

----------------------------------------------------------------------
-- Scrolling
----------------------------------------------------------------------

config.scrollback_lines = 100000

----------------------------------------------------------------------
-- Mouse
----------------------------------------------------------------------

config.enable_scroll_bar = false

config.mouse_bindings = {
	-- Copy on selection (macOS style)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection"),
	},
	-- Open a URL or file:// link under the pointer with Command-click.
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

----------------------------------------------------------------------
-- Leader key (optional)
----------------------------------------------------------------------

config.leader = {
	key = "a",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

----------------------------------------------------------------------
-- Key bindings
----------------------------------------------------------------------

config.keys = {

	--------------------------------------------------------------------
	-- Font size
	--------------------------------------------------------------------

	{
		key = "=",
		mods = "CMD",
		action = wezterm.action.IncreaseFontSize,
	},

	{
		key = "-",
		mods = "CMD",
		action = wezterm.action.DecreaseFontSize,
	},

	{
		key = "0",
		mods = "CMD",
		action = wezterm.action.ResetFontSize,
	},

	--------------------------------------------------------------------
	-- Clipboard
	--------------------------------------------------------------------

	{
		key = "c",
		mods = "CMD",
		action = wezterm.action.CopyTo("Clipboard"),
	},

	{
		key = "v",
		mods = "CMD",
		action = wezterm.action.PasteFrom("Clipboard"),
	},

	--------------------------------------------------------------------
	-- Search scrollback
	--------------------------------------------------------------------

	{
		key = "f",
		mods = "CMD|SHIFT",
		action = wezterm.action.Search({ CaseInSensitiveString = "" }),
	},

	--------------------------------------------------------------------
	-- New window
	--------------------------------------------------------------------

	{
		key = "n",
		mods = "CMD",
		action = wezterm.action.SpawnWindow,
	},

	--------------------------------------------------------------------
	-- Reload config
	--------------------------------------------------------------------

	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},

	--------------------------------------------------------------------
	-- Disable accidental close
	--------------------------------------------------------------------

	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.DisableDefaultAssignment,
	},
	-- macOS-style cursor movement

	{
		key = "LeftArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bb"), -- Alt+b
	},
	{
		key = "RightArrow",
		mods = "OPT",
		action = wezterm.action.SendString("\x1bf"), -- Alt+f
	},

	{
		key = "LeftArrow",
		mods = "CMD",
		action = wezterm.action.SendString("\x01"), -- Ctrl+a
	},
	{
		key = "RightArrow",
		mods = "CMD",
		action = wezterm.action.SendString("\x05"), -- Ctrl+e
	},

	{
		key = "Backspace",
		mods = "OPT",
		action = wezterm.action.SendString("\x17"), -- delete previous word
	},

	{
		key = "Backspace",
		mods = "CMD",
		action = wezterm.action.SendString("\x15"), -- delete to beginning of line
	},
	-- Close tab
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
	},

	-- Split left/right
	{
		key = "d",
		mods = "CMD",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- Split top/bottom
	{
		key = "D",
		mods = "CMD|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- close current pane
	{
		key = "k",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
}

----------------------------------------------------------------------
-- Shell
----------------------------------------------------------------------

config.default_prog = {
	"/bin/zsh",
	"-l",
}

return config
