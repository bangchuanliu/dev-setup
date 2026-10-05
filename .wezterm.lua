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
