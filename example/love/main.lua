--[[----------------------------------------------------------------------------
- @brief Simple example and tool to check UI API with Love2d
----------------------------------------------------------------------------]]--

local Api = require "graphics"
local Theme = require "theme"

local Ui = require("core.ui")(Api, Theme, true)

local lg = love.graphics

local TopBar = { use = 0, total = 100 }
local BottomBar = { use = 0, total = 100 }
local ListLines = { last = 0, use = 0, total = 10 }
local ListModel = { data = { } }

local window = Ui.Window {
    x = Theme.Left,
    y = Theme.Top,
    width = 800,
    height = 600,
    Ui.Bar {
        x = Theme.Left + Theme.Margin,
        y = Theme.Top + Theme.Margin,
        orientation = "horizontal",
        model = TopBar,
        width = 250,
        height = 50
    },
    Ui.Bar {
        x = Theme.Left + Theme.Margin,
        y = Theme.Top + 3 * Theme.Margin + 50,
        orientation = "vertical",
        model = BottomBar,
        width = 50,
        height = 250
    },
    Ui.List {
        x = Theme.Left + 3 * Theme.Margin + 50,
        y = Theme.Top + 3 * Theme.Margin + 50,
        width = 800 - (Theme.Left + 4 * Theme.Margin + 50),
        height = 600 - (Theme.Top + 4 * Theme.Margin + 50),
        model = ListModel
    }
}

function love.update(dt)
    TopBar.use = (TopBar.use + dt) % TopBar.total
    BottomBar.use = (BottomBar.use + 2 * dt) % BottomBar.total

    ListLines.last = ListLines.last + dt
    if 1 < ListLines.last then
        ListLines.last = 0
        if ListLines.total <= ListLines.use then
            ListLines.use = 0
            ListModel.data = { }
        else
            ListLines.use = ListLines.use + 1
            ListModel.data[#ListModel.data + 1] = {
                ListLines.use .. ": -> " .. os.time(), Theme.Color.Text
            }
        end
    end
end

function love.draw()
    lg.clear(0x1C, 0x28, 0x33, 0xFF)
    lg.setBackgroundColor(0x1C, 0x28, 0x33, 0xFF)
    Ui.draw(window)
end
