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

function _M:rectangle(color, x, y, width, height)
    cairo_set_source_rgba(self.context, unpack(color))
    cairo_rectangle(self.context, x, y, width, height)
    cairo_stroke(self.context)
end

return function(cairoContext)
    local obj = { context = cairoContext }
    return setmetatable(obj, { __index = _M })
end
