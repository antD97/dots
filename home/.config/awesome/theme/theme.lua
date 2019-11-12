--[[
    Cesious Awesome WM theme
    Created by Culinax
    Modified by Thanos Apostolou
--]]

local theme_assets = require("beautiful.theme_assets")
local themes_path = require("gears.filesystem").get_configuration_dir() .. "theme/"

theme = {}

theme.font              = "Noto Sans Regular 10"
theme.notification_font = "Noto Sans Regular 10"
-- theme.font              = "FontAwesome 10"
-- theme.notification_font = "FontAwesome 10"

-- Colors
--------------------------------------------------------------------------------

theme.bg_normal   = "#161616"
theme.fg_normal   = "#efefef"

theme.bg_focus    = "#666666" -- "#383838" -- "#42717b"
theme.bg_urgent   = theme.bg_normal
theme.bg_minimize = "#222222" -- theme.bg_normal
theme.bg_systray  = theme.bg_normal

theme.fg_focus    = theme.fg_normal
theme.fg_urgent   = "#d23d3d"
theme.fg_minimize = "#666666" -- theme.fg_normal

-- Border
--------------------------------------------------------------------------------

theme.border_width  = 3
theme.useless_gap = 5
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.fg_normal -- theme.bg_focus
theme.border_marked = theme.fg_normal -- theme.bg_focus

-- Other
--------------------------------------------------------------------------------

theme.hotkeys_modifiers_fg = "#ffffff"
theme.titlebar_bg_focus = theme.fg_normal

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
local taglist_square_size = 5
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

--theme.taglist_squares_sel   = themes_path .. "taglist/squarefw.png"
--theme.taglist_squares_unsel = themes_path .. "taglist/squarew.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path .. "submenu.png"
theme.menu_height = 25
theme.menu_width  = 200

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal              = themes_path .. "titlebar/close_normal_arc.png"
theme.titlebar_close_button_focus               = themes_path .. "titlebar/close_focus_arc.png"

theme.titlebar_ontop_button_normal_inactive     = themes_path .. "titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = themes_path .. "titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = themes_path .. "titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = themes_path .. "titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive    = themes_path .. "titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = themes_path .. "titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = themes_path .. "titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = themes_path .. "titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive  = themes_path .. "titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = themes_path .. "titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = themes_path .. "titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = themes_path .. "titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path .. "titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = themes_path .. "titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = themes_path .. "titlebar/maximized_focus_active.png"

theme.titlebar_minimize_button_normal = themes_path .. "titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path .. "titlebar/minimize_focus.png"

theme.wallpaper = function(s)
	if s.index == 1 then
		return themes_path .. "wallpaper1.png"
	else
		return themes_path .. "wallpaper2.png"
	end
end

-- You can use your own layout icons like this:
theme.layout_fairh      = themes_path .. "layouts/fairhw.png"
theme.layout_fairv      = themes_path .. "layouts/fairvw.png"
theme.layout_floating   = themes_path .. "layouts/floatingw.png"
theme.layout_magnifier  = themes_path .. "layouts/magnifierw.png"
theme.layout_max        = themes_path .. "layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path .. "layouts/tileleftw.png"
theme.layout_tile       = themes_path .. "layouts/tilew.png"
theme.layout_tiletop    = themes_path .. "layouts/tiletopw.png"
theme.layout_spiral     = themes_path .. "layouts/spiralw.png"
theme.layout_dwindle    = themes_path .. "layouts/dwindlew.png"
theme.layout_cornernw   = themes_path .. "layouts/cornernww.png"
theme.layout_cornerne   = themes_path .. "layouts/cornernew.png"
theme.layout_cornersw   = themes_path .. "layouts/cornersww.png"
theme.layout_cornerse   = themes_path .. "layouts/cornersew.png"

theme.awesome_icon = themes_path .. "manjaro-icon.png"

-- Tag icons
theme.tag_chat = themes_path .. "tags/chat.png"

-- Define the icon theme for application icons. If not set then the icons 
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = "Papirus-Dark"

return theme
