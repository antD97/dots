-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Freedesktop menu
local freedesktop = require("freedesktop")

-- Error Handling
-------------------------------------------------------------------------------
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, there were errors during startup!", text = awesome.startup_errors })
end
-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true
		naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err) })
		in_error = false
	end)
end

-- Variable definitions
-------------------------------------------------------------------------------
-- Themes define colours, icons, font and wallpapers.
local themes_path = require("gears.filesystem").get_themes_dir()
beautiful.init(themes_path .. "ant/theme.lua")

-- This is used later as the default terminal and editor to run.
browser = "exo-open --launch WebBrowser" or "firefox"
filemanager = "exo-open --launch FileManager" or "thunar"
gui_editor = "mousepad"
terminal = os.getenv("TERMINAL") or "lxterminal"

-- Default modkey
modkey = "Mod4"
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	-- awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

-- Helper functions
-------------------------------------------------------------------------------
local function client_menu_toggle_fn()
	local instance = nil
	return function()
		if instance and instance.wibox.visible then
			instance:hide()
			instance = nil
		else
			instance = awful.menu.clients({ theme = { width = 250 } })
		end
	end
end

-- Menu
-------------------------------------------------------------------------------
-- Create a launcher widget and a main menu
myawesomemenu = {
	{ "hotkeys", function() return false, hotkeys_popup.show_help end, menubar.utils.lookup_icon("preferences-desktop-keyboard-shortcuts") },
	-- { "manual", terminal .. " -e man awesome", menubar.utils.lookup_icon("system-help") },
	{ "edit config", gui_editor .. " " .. awesome.conffile,  menubar.utils.lookup_icon("accessories-text-editor") },
	{ "restart", awesome.restart, menubar.utils.lookup_icon("system-restart") }
}
myexitmenu = {
	{ "log out", function() awesome.quit() end, menubar.utils.lookup_icon("system-log-out") },
	{ "suspend", "systemctl suspend", menubar.utils.lookup_icon("system-suspend") },
	{ "hibernate", "systemctl hibernate", menubar.utils.lookup_icon("system-suspend-hibernate") },
	{ "reboot", "systemctl reboot", menubar.utils.lookup_icon("system-reboot") },
	{ "shutdown", "poweroff", menubar.utils.lookup_icon("system-shutdown") }
}
mymainmenu = freedesktop.menu.build({
	icon_size = 32,
	before = {
		{ "Terminal", terminal, menubar.utils.lookup_icon("utilities-terminal") },
		{ "Browser", browser, menubar.utils.lookup_icon("internet-web-browser") },
		{ "Files", filemanager, menubar.utils.lookup_icon("system-file-manager") },
		-- other triads can be put here
	},
	after = {
		{ "Awesome", myawesomemenu, "/usr/share/awesome/icons/awesome32.png" },
		{ "Exit", myexitmenu, menubar.utils.lookup_icon("system-shutdown") },
		-- other triads can be put here
	}
})
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Wibar
-------------------------------------------------------------------------------
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %b %d %I:%M%p")

separator = wibox.widget.textbox(' <span color="' .. beautiful.fg_normal .. '">| </span>')

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
		end),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
		end),
	awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() and c.first_tag then
				c.first_tag:view_only()
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
		end),
	awful.button({ }, 3, client_menu_toggle_fn()),
	awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
	awful.button({ }, 5, function() awful.client.focus.byidx(-1) end))

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({ }, 1, function() awful.layout.inc( 1) end),
		awful.button({ }, 3, function() awful.layout.inc(-1) end),
		awful.button({ }, 4, function() awful.layout.inc( 1) end),
		awful.button({ }, 5, function() awful.layout.inc(-1) end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
	
	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			-- mylauncher,
			s.mytaglist,
			s.mypromptbox
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			wibox.widget.systray(),
			mykeyboardlayout,
			separator,
			mytextclock,
			-- s.mylayoutbox
		},
	}
end)

-- Mouse bindings
-------------------------------------------------------------------------------
root.buttons(gears.table.join(
	awful.button({ }, 1, function() mymainmenu:hide() end),
	awful.button({ }, 3, function() mymainmenu:toggle() end)
))

-- Key bindings helper functions
-------------------------------------------------------------------------------
local function focus_switch_byd(c, dir)
	awful.client.focus.bydirection(dir)
	if client.focus then client.focus:raise() end
end

local function swap_or_move(c, dir)
	if c then
		-- swap non floating
		if not c.floating then
			awful.client.swap.bydirection(dir)
			client.focus:raise()

		-- move floating
		else
			if dir == "up" then c:relative_move(0, -20, 0, 0)
			elseif dir == "down" then c:relative_move(0, 20, 0, 0)
			elseif dir == "left" then c:relative_move(-20, 0, 0, 0)
			elseif dir == "right" then c:relative_move(20, 0, 0, 0) end
		end
	end
end

local function resize(c, dir)
	if c then
		if c.floating then
			if dir == "up" then c:relative_move(0, 0, 0, -20)
			elseif dir == "down" then c:relative_move(0, 0, 0, 20)
			elseif dir == "left" then c:relative_move(0, 0, -20, 0)
			elseif dir == "right" then c:relative_move(0, 0, 20, 0) end
		end
	end
end

local function restore_min()
	local c = awful.client.restore()
	-- Focus restored client
	if c then
		client.focus = c
		c:raise()
	end
end

local function fullscreen(c)
	c.fullscreen = not c.fullscreen
	c:raise()
end

local function maximize(c)
	c.maximized = not c.maximized
	c:raise()
end

-- Key bindings
-------------------------------------------------------------------------------
globalkeys = gears.table.join(

	-- Awesome
	---------------------------------------
	awful.key({ modkey }, "F1", hotkeys_popup.show_help,
			  {description="Help", group="Awesome"}),
	awful.key({ modkey,           }, "w", function() mymainmenu:show() end,
			  {description = "Main menu", group = "Awesome"}),
	awful.key({ modkey, "Control" }, "r", awesome.restart,
			  {description = "Reload", group = "Awesome"}),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit,
			  {description = "Quit", group = "Awesome"}),

	-- Client
	---------------------------------------
	-- minimize
	awful.key({ modkey, "Shift" }, "h", function() restore_min() end,
			  {description = "Restore minimized", group = "Client"}),

	-- Launcher
	---------------------------------------
	awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
			  {description = "Terminal", group = "Launcher"}),
	awful.key({ modkey }, "s", function() awful.spawn(browser) end,
			  {description = "Browser", group = "Launcher"}),
	awful.key({ modkey}, "r", function() awful.spawn("/usr/bin/thunar") end,
			  {description = "Filemanager", group = "Launcher"}),
	awful.key({ modkey, "Control"}, "Escape", function() awful.spawn("/usr/bin/rofi -show drun -modi drun") end,
			  {description = "Rofi", group = "Launcher"}),

	-- Layout
	---------------------------------------
	-- master width
	awful.key({ modkey }, "Right", function() awful.tag.incmwfact( 0.05) end,
			  {description = "Increase master width factor", group = "Layout"}),
	awful.key({ modkey }, "Left", function() awful.tag.incmwfact(-0.05) end,
			  {description = "Decrease master width factor", group = "Layout"}),
	-- num master clients
	awful.key({ modkey }, "Up", function() awful.tag.incnmaster( 1, nil, true) end,
			  {description = "Increase the number of master clients", group = "Layout"}),
	awful.key({ modkey }, "Down", function() awful.tag.incnmaster(-1, nil, true) end,
			  {description = "Decrease the number of master clients", group = "Layout"}),
	-- num columns
	awful.key({ modkey, "Shift" }, "Up", function() awful.tag.incncol( 1, nil, true) end,
			  {description = "Increase the number of columns", group = "Layout"}),
	awful.key({ modkey, "Shift" }, "Down", function() awful.tag.incncol(-1, nil, true) end,
			  {description = "Decrease the number of columns", group = "Layout"}),
	-- layout select
	awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(1) end,
			  {description = "Select next", group = "Layout"}),

	-- Screen
	---------------------------------------
	awful.key({ modkey }, "o", function() awful.screen.focus_relative(1) end,
			  {description = "Focus the next screen", group = "Screen"}),

	-- Screenshot
	---------------------------------------
	awful.key({ }, "Print", function() awful.spawn("/usr/bin/i3-scrot -d") end,
			  {description = "Screenshot", group = "Screenshot"}),
	awful.key({ "Shift" }, "Print", function() awful.spawn("/usr/bin/i3-scrot -s") end,
			  {description = "Screenshot of selection", group = "Screenshot"}),
	awful.key({ "Control" }, "Print", function() awful.spawn("/usr/bin/i3-scrot -w") end,
			  {description = "Screenshot of active window", group = "Screenshot"}),

	-- Tag
	---------------------------------------
	awful.key({ modkey }, "l", awful.tag.viewprev,
              {description = "View previous", group = "Tag"}),
    awful.key({ modkey }, "y", awful.tag.viewnext,
              {description = "View next", group = "Tag"})
)

clientkeys = gears.table.join(

	-- Client
	---------------------------------------
	-- focus navigation
	awful.key({ modkey }, "u", function(c) focus_switch_byd(c, "up") end,
		{description = "Move focus up", group = "Client"}),
	awful.key({ modkey }, "e", function(c) focus_switch_byd(c, "down") end,
		{description = "Move focus down", group = "Client"}),
	awful.key({ modkey }, "n", function(c) focus_switch_byd(c, "left") end,
		{description = "Move focus left", group = "Client"}),
	awful.key({ modkey }, "i", function(c) focus_switch_byd(c, "right") end,
		{description = "Move focus right", group = "Client"}),

	-- swapping or moving
	awful.key({ modkey, "Shift" }, "u", function(c) swap_or_move(c, "up") end,
			  {description = "Swap or move up", group = "Client"}),
	awful.key({ modkey, "Shift" }, "e", function(c) swap_or_move(c, "down") end,
			  {description = "Swap or move down", group = "Client"}),
	awful.key({ modkey, "Shift" }, "n", function(c) swap_or_move(c, "left") end,
			  {description = "Swap or move left", group = "Client"}),
	awful.key({ modkey, "Shift" }, "i", function(c) swap_or_move(c, "right") end,
			  {description = "Swap or move right", group = "Client"}),

	-- resizing
	awful.key({ modkey, "Control" }, "u", function(c) resize(c, "up") end,
			  {description = "Increase floating client height", group = "Client"}),
	awful.key({ modkey, "Control" }, "e", function(c) resize(c, "down") end,
			  {description = "Decrease floating client height", group = "Client"}),
	awful.key({ modkey, "Control" }, "n", function(c) resize(c, "left") end,
			  {description = "Decrease floating client width", group = "Client"}),
	awful.key({ modkey, "Control" }, "i", function(c) resize(c, "right") end,
			  {description = "Increase floating client width", group = "Client"}),

	-- fullscreen
	awful.key({ modkey, "Shift" }, "f", function(c) fullscreen(c) end,
		{description = "Fullscreen", group = "Client"}),
	-- close
	awful.key({ modkey }, "x", function(c) c:kill() end,
			  {description = "Close", group = "Client"}),
	-- floating
	awful.key({ modkey }, "f",  awful.client.floating.toggle,
			  {description = "Toggle floating", group = "Client"}),
	-- move to screen
	awful.key({ modkey, "Shift"}, "o", function(c) c:move_to_screen() end,
			  {description = "Move to next screen", group = "Client"}),
	-- keep on top
	awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
			  {description = "Toggle keep on top", group = "Client"}),
	-- minimize
	awful.key({ modkey }, "h", function(c) c.minimized = true end,
		{description = "Minimize", group = "Client"}),
	-- maximize
	awful.key({ modkey }, "m", function(c) maximize(c) end,
		{description = "Toggle maximized", group = "Client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
				  function()
						local screen = awful.screen.focused()
						local tag = screen.tags[i]
						if tag then
						   tag:view_only()
						end
				  end,
				  {description = "View tag #"..i, group = "Tag"}),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9,
				  function()
					  local screen = awful.screen.focused()
					  local tag = screen.tags[i]
					  if tag then
						 awful.tag.viewtoggle(tag)
					  end
				  end,
				  {description = "Toggle tag #" .. i, group = "Tag"}),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				  function()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:move_to_tag(tag)
						  end
					 end
				  end,
				  {description = "Move focused client to tag #"..i, group = "Tag"}),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
				  function()
					  if client.focus then
						  local tag = client.focus.screen.tags[i]
						  if tag then
							  client.focus:toggle_tag(tag)
						  end
					  end
				  end,
				  {description = "Toggle focused client on tag #" .. i, group = "Tag"})
	)
end

clientbuttons = gears.table.join(
	awful.button({ }, 1, function(c) client.focus = c; c:raise()
				 mymainmenu:hide() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)

-- Rules
-------------------------------------------------------------------------------
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	  properties = { border_width = beautiful.border_width,
					 border_color = beautiful.border_normal,
					 focus = awful.client.focus.filter,
					 raise = true,
					 keys = clientkeys,
					 buttons = clientbuttons,
					 size_hints_honor = false, -- Remove gaps between terminals
					 screen = awful.screen.preferred,
					 callback = awful.client.setslave,
					 placement = awful.placement.no_overlap+awful.placement.no_offscreen,
					 floating  = true
	 }
	},

	-- Floating clients.
	--[[
	{ rule_any = {
		instance = {
		  "DTA",  -- Firefox addon DownThemAll.
		  "copyq",  -- Includes session name in class.
		},
		class = {
		  "Arandr",
		  "Gpick",
		  "Kruler",
		  "MessageWin",  -- kalarm.
		  "Sxiv",
		  "Wpa_gui",
		  "pinentry",
		  "veromix",
		  "xtightvncviewer"},

		name = {
		  "Event Tester",  -- xev.
		},
		role = {
		  "AlarmWindow",  -- Thunderbird's calendar.
		  "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
		}
	  }, properties = { floating = true }},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = {type = { "normal", "dialog" } },
	  properties = { titlebars_enabled = false }
	}
	--]]
}

-- Signals
-------------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end
	if awesome.startup and
	  not c.size_hints.user_position
	  and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({ }, 1, function()
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
		awful.button({ }, 3, function()
			client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c) : setup {
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout  = wibox.layout.fixed.horizontal
		},
		{ -- Middle
			{ -- Title
				align  = "center",
				widget = awful.titlebar.widget.titlewidget(c)
			},
			buttons = buttons,
			layout  = wibox.layout.flex.horizontal
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton (c),
			awful.titlebar.widget.stickybutton   (c),
		   -- awful.titlebar.widget.ontopbutton    (c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton    (c),
			layout = wibox.layout.fixed.horizontal()
		},
		layout = wibox.layout.align.horizontal
	}
		-- Hide the menubar if we are not floating
   -- local l = awful.layout.get(c.screen)
   -- if not (l.name == "floating" or c.floating) then
   --     awful.titlebar.hide(c)
   -- end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Disable borders on lone windows
-- Handle border sizes of clients.
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function()
	local clients = awful.client.visible(s)
	local layout = awful.layout.getname(awful.layout.get(s))

	for _, c in pairs(clients) do
		-- No borders with only one humanly visible client
		if c.maximized then
			c.border_width = 0
		elseif c.floating or layout == "floating" then
			c.border_width = beautiful.border_width
		elseif layout == "max" or layout == "fullscreen" then
			c.border_width = 0
		else
			c.border_width = beautiful.border_width
		end
	end
end)
end

awful.spawn.with_shell("~/.config/awesome/autorun.sh")