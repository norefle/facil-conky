--[[----------------------------------------------------------------------------
- @brief Implementation of graphics API with cairo.
----------------------------------------------------------------------------]]--

require "cairo"

local _M = {}

function _M:print(text, x, y, color)
    cairo_set_source_rgba(self.context, unpack(color))
    cairo_move_to(self.context, x, y)
    cairo_show_text(self.context, text)
end

function _M:rectangle(foreground, background, x, y, width, height)
    cairo_set_source_rgba(self.context, unpack(foreground))
    cairo_rectangle(self.context, x, y, width, height)
    cairo_stroke_preserve(self.context)
    cairo_set_source_rgba(self.context, unpack(background))
    cairo_fill(self.context)
end

function _M:color(r, g, b, a)
    return { r / 256, g / 256, b / 256, a and (a / 255) or 1.0 }
end

return function(cairoContext)
    local obj = { context = cairoContext }
    return setmetatable(obj, { __index = _M })
end
