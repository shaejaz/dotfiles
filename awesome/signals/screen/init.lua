local awful = require 'awful'

local vars = require 'config.vars'
local widgets = require 'widgets'

screen.connect_signal('request::desktop_decoration', function(s)
    awful.tag(vars.tags, s, awful.layout.layouts[1])
    s.promptbox = widgets.create_promptbox()
    s.layoutbox = widgets.create_layoutbox(s)
    s.taglist   = widgets.create_taglist(s)
    s.tasklist  = widgets.create_tasklist(s)
    s.wibox     = widgets.create_wibox(s)
end)
