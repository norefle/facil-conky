--[[----------------------------------------------------------------------------
-- @brief Dark theme file for conky.
----------------------------------------------------------------------------]]--

return function(api)
    return {
        Color = {
            Warning = api:color(0xFA, 0x69, 0x00),
            Success = api:color(0xA7, 0xDB, 0xD8),
            Text = api:color(0xE0, 0xE4, 0xCC),
            Border = api:color(0xE0, 0xE4, 0xCC),
            Transparent = api:color(0xFF, 0xFF, 0xFF, 0x00),
            Accent = api:color(0xA7, 0xDB, 0xD8)
        }
    }
end
