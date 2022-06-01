local awful = require 'awful'

local mod = require 'bindings.mod'

client.connect_signal('request::default_mousebindings', function()
    awful.mouse.append_client_mousebindings {
        awful.button({}, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end),
        awful.button({ mod.super }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({ mod.super, mod.shift }, 1, function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c, "bottom_right")
        end)
    }
end)
