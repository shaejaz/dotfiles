-- load luarocks if installed
pcall(require, 'luarocks.loader')

local beautiful = require 'beautiful'
local gears = require 'gears'
local awful = require 'awful'

beautiful.init(gears.filesystem.get_themes_dir() .. 'default/theme.lua')

-- load key and mouse bindings
require 'bindings'

-- load rules
require 'rules'

-- load signals
require 'signals'

awesome.connect_signal("startup", function()
    awful.spawn.with_shell(gears.filesystem.get_xdg_config_home() .. "awesome/autostart.sh")
end)
