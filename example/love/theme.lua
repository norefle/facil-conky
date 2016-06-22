local Api = require "graphics"

return {
    Top = 0,
    Left = 0,
    Margin = 5,
    Color = {
        Warning = Api:color(0xFA, 0x69, 0x00),
        Success = Api:color(0xA7, 0xDB, 0xD8),
        Text = Api:color(0xE0, 0xE4, 0xCC),
        Border = Api:color(0xE0, 0xE4, 0xCC),
        Transparent = Api:color(0xFF, 0xFF, 0xFF, 0x00),
        Accent = Api:color(0xA7, 0xDB, 0xD8)
    }
}
