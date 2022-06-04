local awful = require 'awful'

local vars = require 'config.vars'
local widgets = require 'widgets'

screen.connect_signal('request::desktop_decoration', function(s)
    for i, v in ipairs(vars.tags) do
        local _selected = false
        if i == 1 then
            _selected = true
        end
        awful.tag.add(v, {
            screen            = s,
            layout            = awful.layout.layouts[1],
            gap_single_client = true,
            gap               = 10,
            selected          = _selected
        })
    end

    s.promptbox = widgets.create_promptbox()
    s.layoutbox = widgets.create_layoutbox(s)
    s.taglist   = widgets.create_taglist(s)
    s.tasklist  = widgets.create_tasklist(s)
    s.wibox     = widgets.create_wibox(s)
end)
