local module = {}

local awful = require 'awful'
local hotkeys_popup = require 'awful.hotkeys_popup'
local beautiful = require 'beautiful'
local wibox = require 'wibox'

local apps = require 'config.apps'
local mod = require 'bindings.mod'

module.awesomemenu = {
    { 'hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { 'manual', apps.manual_cmd },
    { 'edit config', apps.editor_cmd .. ' ' .. awesome.conffile },
    { 'restart', awesome.restart },
    { 'quit', function()
        awesome.quit()
    end },
}

module.mainmenu = awful.menu {
    items = {
        { 'awesome', module.awesomemenu, beautiful.awesome_icon },
        { 'open terminal', apps.terminal }
    }
}

module.launcher = awful.widget.launcher {
    image = beautiful.awesome_icon,
    menu = module.mainmenu
}

module.keyboardlayout = awful.widget.keyboardlayout()
module.textclock      = wibox.widget.textclock()


function module.create_promptbox() return awful.widget.prompt() end

function module.create_layoutbox(s)
    return awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button {
                modifiers = {},
                button    = 1,
                on_press  = function() awful.layout.inc(1) end,
            },
            awful.button {
                modifiers = {},
                button    = 3,
                on_press  = function() awful.layout.inc(-1) end,
            },
            awful.button {
                modifiers = {},
                button    = 4,
                on_press  = function() awful.layout.inc(-1) end,
            },
            awful.button {
                modifiers = {},
                button    = 5,
                on_press  = function() awful.layout.inc(1) end,
            },
        }
    }
end

function module.create_taglist(s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = {
            awful.button {
                modifiers = {},
                button    = 1,
                on_press  = function(t) t:view_only() end,
            },
            awful.button {
                modifiers = { mod.super },
                button    = 1,
                on_press  = function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end,
            },
            awful.button {
                modifiers = {},
                button    = 3,
                on_press  = awful.tag.viewtoggle,
            },
            awful.button {
                modifiers = { mod.super },
                button    = 3,
                on_press  = function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end
            },
            awful.button {
                modifiers = {},
                button    = 4,
                on_press  = function(t) awful.tag.viewprev(t.screen) end,
            },
            awful.button {
                modifiers = {},
                button    = 5,
                on_press  = function(t) awful.tag.viewnext(t.screen) end,
            },
        }
    }
end

function module.create_tasklist(s)
    return awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button {
                modifiers = {},
                button    = 1,
                on_press  = function(c)
                    c:activate { context = 'tasklist', action = 'togglemoduleinimization' }
                end,
            },
            awful.button {
                modifiers = {},
                button    = 3,
                on_press  = function() awful.menu.client_list { theme = { width = 250 } } end,
            },
            awful.button {
                modifiers = {},
                button    = 4,
                on_press  = function() awful.client.focus.byidx(-1) end
            },
            awful.button {
                modifiers = {},
                button    = 5,
                on_press  = function() awful.client.focus.byidx(1) end
            },
        }
    }
end

function module.create_wibox(s)
    return awful.wibar {
        screen = s,
        position = 'top',
        widget = {
            layout = wibox.layout.align.horizontal,
            -- left widgets
            {
                layout = wibox.layout.fixed.horizontal,
                module.launcher,
                s.taglist,
                s.promptbox,
            },
            -- middle widgets
            s.tasklist,
            -- right widgets
            {
                layout = wibox.layout.fixed.horizontal,
                module.keyboardlayout,
                wibox.widget.systray(),
                module.textclock,
                s.layoutbox,
            }
        }
    }
end

return module
