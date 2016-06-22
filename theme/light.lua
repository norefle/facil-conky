--[[----------------------------------------------------------------------------
-- @brief Light theme file for conky.
----------------------------------------------------------------------------]]--

return function(api)
    return {
        Color = {
            Warning = api:color(0xFA, 0x69, 0x00),
            Success = api:color(0xA7, 0xDB, 0xD8),
            Text = api:color(0x00, 0x00, 0x02),
            Border = api:color(0x00, 0x00, 0x02),
            Transparent = api:color(0xFF, 0xFF, 0xFF, 0x00),
            Accent = api:color(0xA7, 0xDB, 0xD8)
        }
    }
end
