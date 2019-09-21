-- QWERTY

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

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
local hotkeys_popup = require("awful.hotkeys_popup")
-- Freedesktop menu
local freedesktop = require("freedesktop")
-- Multimonitor
local xrandr = require("xrandr")

-- Error handling
--------------------------------------------------------------------------------
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
					 title = "Oops, there were errors during startup!",
					 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
						 title = "Oops, an error happened!",
						 text = tostring(err) })
		in_error = false
	end)
end

-- Variable definitions
--------------------------------------------------------------------------------
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

-- This is used later as the default terminal and editor to run.
browser = "exo-open --launch WebBrowser"
filemanager = "exo-open --launch FileManager"
terminal = os.getenv("TERMINAL") or "lxterminal"
editor = "subl"

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile.right,
	awful.layout.suit.tile.left,
	awful.layout.suit.floating
}

-- Menu
--------------------------------------------------------------------------------
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "edit config", editor .. " " .. awesome.conffile },
   { "restart", awesome.restart }
}

myexitmenu = {
	{ "log out", function() awesome.spawn("pkill redshift") awesome.quit() end, menubar.utils.lookup_icon("system-log-out") },
	{ "suspend", "systemctl suspend", menubar.utils.lookup_icon("system-suspend") },
	{ "hibernate", "systemctl hibernate", menubar.utils.lookup_icon("system-suspend-hibernate") },
	{ "reboot", "systemctl reboot", menubar.utils.lookup_icon("system-reboot") },
	{ "shutdown", "poweroff", menubar.utils.lookup_icon("system-shutdown") }
}

mymainmenu = freedesktop.menu.build({
	before = {
		{ "URxvt", terminal, menubar.utils.lookup_icon("utilities-terminal")},
		{ "Firefox", browser, menubar.utils.lookup_icon("firefox")},
		{ "Files", filemanager, menubar.utils.lookup_icon("system-file-manager")}
	},
	after = {
		{ "awesome", myawesomemenu, "/usr/share/awesome/icons/awesome32.png" },
		{ "Exit", myexitmenu, menubar.utils.lookup_icon("system-shutdown")}
	}
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Wibar
--------------------------------------------------------------------------------
-- Create a launcher widget
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %b %d %I:%M%p")

-- Create a separator widget
separator = wibox.widget.textbox(' <span color="' .. beautiful.fg_normal .. '">| </span>')

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({ }, 1, function(t) t:view_only() end),
	awful.button({ }, 3, awful.tag.viewtoggle)
)

local tasklist_buttons = gears.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal(
				"request::activate",
				"tasklist",
				{raise = true}
				)
		end
		end),
	awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end))

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

	num_displays = 0
	for _ in pairs(xrandr.outputs()) do num_displays = num_displays + 1 end

	-- Each screen has its own tag table.
	-- One display
	if num_displays == 1 then
		awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

		-- chat tag
		awful.tag.add("chat", { screen = s, layout = awful.layout.layouts[1] })

	-- More than one display
	else
		awful.tag({ "1", "2", "3", "4" }, s, awful.layout.layouts[1])

		-- chat tag
		if s.index == 2 then
			awful.tag.add("chat", { screen = s, layout = awful.layout.layouts[1] })
		else
			awful.tag.add("5", { screen = s, layout = awful.layout.layouts[1] })
		end
	end

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)

	s.mylayoutbox:buttons(gears.table.join(
		awful.button({ }, 1, function()
			if awful.layout.get() == awful.layout.layouts[1] then awful.layout.set(awful.layout.layouts[2])
			elseif awful.layout.get() == awful.layout.layouts[2] then awful.layout.set(awful.layout.layouts[1]) end
		end),
		awful.button({ }, 3, function()
			if awful.layout.get() ~= awful.layout.layouts[3] then awful.layout.set(awful.layout.layouts[3])
			elseif awful.layout.get() == awful.layout.layouts[3] then awful.layout.set(awful.layout.layouts[1]) end
		end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons
	}

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist {
		screen  = s,
		filter  = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
		widget_template = {
	        {
                {
                    {
                    	widget = wibox.widget.imagebox,
                        id = 'icon_role'
                    },
                    widget = wibox.container.margin,
                    margins = 5
                },
                {
                	widget = wibox.widget.textbox,
                    id = 'text_role'
                },
                layout = wibox.layout.fixed.horizontal
	        },
	        widget = wibox.container.background,
	        id = 'background_role'
	    }
	}

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "bottom", screen = s })

	if s.index == 1 then	-- main monitor
		-- Add widgets to the wibox
		s.mywibox:setup {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				wibox.container.margin(mylauncher, 1, 1, 1, 1),
				wibox.container.margin(s.mytaglist, 0, 2),
				s.mypromptbox,
			},
			s.mytasklist,
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				wibox.container.margin(wibox.widget.systray(), 1, 1, 1, 1),
				separator,
				wibox.container.margin(mytextclock, 4, 8),
				wibox.container.margin(s.mylayoutbox, 1, 1, 1, 1)
			},
		}
	else	-- other monitors
		-- Add widgets to the wibox
		s.mywibox:setup {
			layout = wibox.layout.align.horizontal,
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				wibox.container.margin(mylauncher, 1, 1, 1, 1),
				wibox.container.margin(s.mytaglist, 0, 2),
				s.mypromptbox,
			},
			s.mytasklist,
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				wibox.container.margin(mytextclock, 5, 8),
				wibox.container.margin(s.mylayoutbox, 1, 1, 1, 1)
			},
		}
	end
end)

-- Mouse bindings
--------------------------------------------------------------------------------
root.buttons(gears.table.join(
	awful.button({ }, 1, function() mymainmenu:hide() end),
	awful.button({ }, 3, function() mymainmenu:toggle() end)
))

-- Key bindings helper functions
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
globalkeys = gears.table.join(

	-- Awesome
	---------------------------------------
	awful.key({ modkey }, "F1", hotkeys_popup.show_help,
			  {description = "Help", group="Awesome"}),
	awful.key({ modkey }, "w", function() mymainmenu:show() end,
			  {description = "Main menu", group = "Awesome"}),
	awful.key({ modkey, "Control" }, "r", awesome.restart,
			  {description = "Reload", group = "Awesome"}),
	awful.key({ modkey, "Shift" }, "q", function() awesome.spawn("pkill redshift") awesome.quit() end,
			  {description = "Quit", group = "Awesome"}),

	-- Client
	---------------------------------------
	-- minimize
	awful.key({ modkey, "Shift" }, "n", function() restore_min() end,
			  {description = "Restore minimized", group = "Client"}),

	-- Launcher
	---------------------------------------
	awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
			  {description = "Terminal", group = "Launcher"}),
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
	-- layout side
	awful.key({ modkey }, "space",
			  function()
				if awful.layout.get() == awful.layout.layouts[1] then awful.layout.set(awful.layout.layouts[2])
				elseif awful.layout.get() == awful.layout.layouts[2] then awful.layout.set(awful.layout.layouts[1])
				end
			  end,
			  {description = "Toggle tile master client side", group = "Layout"}),
	-- float layout
	awful.key({ modkey, "Shift" }, "space",
			  function()
				if awful.layout.get() == awful.layout.layouts[3] then awful.layout.set(awful.layout.layouts[1])
				else awful.layout.set(awful.layout.layouts[3])
				end
			  end,
			  {description = "Toggle floating layout", group = "Layout"}),
	-- reset tile layout
	awful.key({ modkey }, "r",
			function()
				if awful.layout.get() ~= awful.layout.layouts[3] then
					awful.tag.setmwfact(0.5)
					awful.tag.setncol(1)
					awful.tag.setnmaster(1)
				end
			end,
			{description = "Toggle floating layout", group = "Layout"}),

	-- Screen
	---------------------------------------
	awful.key({ modkey }, ";", function() awful.screen.focus_relative(1) end,
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
	awful.key({ modkey }, "u", awful.tag.viewprev,
              {description = "View previous", group = "Tag"}),
    awful.key({ modkey }, "o", awful.tag.viewnext,
              {description = "View next", group = "Tag"})
)

clientkeys = gears.table.join(

	-- Client
	---------------------------------------
	-- focus navigation
	awful.key({ modkey }, "i", function(c) focus_switch_byd(c, "up") end,
		{description = "Move focus up", group = "Client"}),
	awful.key({ modkey }, "k", function(c) focus_switch_byd(c, "down") end,
		{description = "Move focus down", group = "Client"}),
	awful.key({ modkey }, "j", function(c) focus_switch_byd(c, "left") end,
		{description = "Move focus left", group = "Client"}),
	awful.key({ modkey }, "l", function(c) focus_switch_byd(c, "right") end,
		{description = "Move focus right", group = "Client"}),

	-- swapping or moving
	awful.key({ modkey, "Shift" }, "i", function(c) swap_or_move(c, "up") end,
			  {description = "Swap or move up", group = "Client"}),
	awful.key({ modkey, "Shift" }, "k", function(c) swap_or_move(c, "down") end,
			  {description = "Swap or move down", group = "Client"}),
	awful.key({ modkey, "Shift" }, "j", function(c) swap_or_move(c, "left") end,
			  {description = "Swap or move left", group = "Client"}),
	awful.key({ modkey, "Shift" }, "l", function(c) swap_or_move(c, "right") end,
			  {description = "Swap or move right", group = "Client"}),

	-- resizing
	awful.key({ modkey, "Control" }, "i", function(c) resize(c, "up") end,
			  {description = "Increase floating client height", group = "Client"}),
	awful.key({ modkey, "Control" }, "k", function(c) resize(c, "down") end,
			  {description = "Decrease floating client height", group = "Client"}),
	awful.key({ modkey, "Control" }, "j", function(c) resize(c, "left") end,
			  {description = "Decrease floating client width", group = "Client"}),
	awful.key({ modkey, "Control" }, "l", function(c) resize(c, "right") end,
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
	awful.key({ modkey, "Shift"}, ";", function(c) c:move_to_screen() end,
			  {description = "Move to next screen", group = "Client"}),
	-- keep on top
	awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
			  {description = "Toggle keep on top", group = "Client"}),
	-- minimize
	awful.key({ modkey }, "n", function(c) c.minimized = true end,
		{description = "Minimize", group = "Client"}),
	-- maximize
	awful.key({ modkey }, "m", function(c) maximize(c) end,
		{description = "Toggle maximized", group = "Client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
num_displays = 0
for _ in pairs(xrandr.outputs()) do num_displays = num_displays + 1 end

if num_displays == 1 then n_tags = 10 else n_tags = 5 end

for i = 1, n_tags do
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
				  {description = "Move focused client to tag #"..i, group = "Tag"})
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
--------------------------------------------------------------------------------
num_displays = 0
for _ in pairs(xrandr.outputs()) do num_displays = num_displays + 1 end
if num_displays == 1 then discord_screen = 1
else discord_screen = 2 end

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {

	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen,
			titlebars_enabled = false
		}
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA",			-- Firefox addon DownThemAll.
				"copyq",		-- Includes session name in class.
				"pinentry"
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin",	-- kalarm.
				"Sxiv",
				"Tor Browser",	-- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer"
			},
			-- Note that the name property shown in xprop might be set slightly after creation of
			-- the client and the name shown there might not match defined rules here.
			name = {
				"Event Tester"	-- xev.
			},
			role = {
				"AlarmWindow",	-- Thunderbird's calendar.
				"ConfigManager",	-- Thunderbird's about:config.
				"pop-up"			-- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	},

	-- Application specific
	{
		rule = { class = "discord" },
		properties = { screen = discord_screen, tag = "chat" }
	},
	{
		rule = { class = "URxvt" },
		properties = { size_hints_honor = false }
	}
}

-- Signals
--------------------------------------------------------------------------------
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup
	  and not c.size_hints.user_position
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
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

	awful.titlebar(c, {size = 10}) : setup {

		-- left
		{
			wibox.widget.textbox(""),
			buttons = buttons,
			layout = wibox.layout.flex.horizontal
		},

		-- middle
		{
			wibox.widget.textbox(""),
			buttons = buttons,
			layout = wibox.layout.flex.horizontal
		},
		--[[
		{
			widget = awful.titlebar.widget.titlewidget(c),
			align = "center"
		},
		--]]

		-- right
		{
			awful.titlebar.widget.minimizebutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal
		},

		layout = wibox.layout.align.horizontal
	}
end
)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

awful.spawn.with_shell("~/.config/awesome/autorun.sh")