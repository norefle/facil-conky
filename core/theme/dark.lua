--[[----------------------------------------------------------------------------
-- @brief Dark theme file for conky.
----------------------------------------------------------------------------]]--

local Util = require "core.util"

return {
    Color = {
        Warning = Util.color(0xFA, 0x69, 0x00),
        Success = Util.color(0xA7, 0xDB, 0xD8),
        Text = Util.color(0xE0, 0xE4, 0xCC),
        Border = Util.color(0xE0, 0xE4, 0xCC)
    }
}
