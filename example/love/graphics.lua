--[[----------------------------------------------------------------------------
--- @brief Graphics API implementation with Love2d
----------------------------------------------------------------------------]]--

local lg = love.graphics

local _M = {}

function _M:print(text, x, y, color)
    lg.setColor(unpack(color))
    lg.print(text, x, y)
end

function _M:rectangle(foreground, background, x, y, width, height)
    local opaque = not background[4] and background[4] ~= 0
    local mode = opaque and "fill" or "line"

    lg.setColor(unpack(foreground))
    if opaque then
        lg.setBackgroundColor(unpack(background))
    end

    lg.rectangle(mode, x, y, width, height)
end

function _M:color(r, g, b, a)
    return { r, g, b, a }
end

return _M
