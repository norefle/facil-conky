--[[----------------------------------------------------------------------------
- @brief Single file library for declarative UI description
----------------------------------------------------------------------------]]--

local M = require "moses"

-- External dependency
local Theme = nil
local Graphics = nil

--

local function hasMethod(obj, method)
    return "table" == type(obj) and "function" == type(obj[method])
end

local function properties(obj)
    return M.pick(obj, M.filter(M.keys(obj), function(_, v) return "number" ~= type(v) end))
end

local function children(obj)
    return M.pick(obj, M.filter(M.keys(obj), function(_, v) return "number" == type(v) end))
end

local function object(prototype, name)
    local obj = properties(prototype)
    obj.children = children(prototype)
    obj.name = name or "object"
    obj.x = obj.x or 0
    obj.y = obj.y or 0

    return obj
end

local function draw(element)
    if hasMethod(element, "draw") then
        element:draw()
    end

    M.forEach(element.children, function(_, child) draw(child) end)
end

-- Core functionality
local function Window(prototype)
    local obj = object(prototype)
    obj.name = "Window"
    function obj:draw()
        local x, y, width, height = self.x, self.y, self.width, self.height
    end

    return obj
end

local function List(prototype)
    local obj = object(prototype)
    obj.name = "List"
    obj.draw = function(self)
        if M.has(self, "model") and M.has(self.model, "data") then
            M.forEach(self.model.data, function(index, value)
                local text, color = unpack(value)
                Graphics:print(text, self.x + Theme.Margin, self.y + index * 20, color)
            end)
        end
    end

    return obj
end

local function Bar(prototype)
    local obj = object(prototype)
    obj.name = "Bar"

    obj.draw = function(self)
        local x, y, width, height = self.x, self.y, self.width, self.height
        Graphics:rectangle(Theme.Color.Border, Theme.Color.Transparent, x, y, width, height)

        local barX, barY, barHeight, barWidth = x, y, height, width
        local total = (self.model.total and 0 ~= self.model.total)
                      and self.model.total
                      or 100
        local use = self.model.use or 0
        local current = use / total
        if self.orientation and "vertical" == self.orientation then
            barHeight = math.modf(height * current)
            barY = y + (height - barHeight)
        else
            barWidth = math.modf(width * current)
        end
        Graphics:rectangle(Theme.Color.Border, Theme.Color.Accent, barX, barY, barWidth, barHeight)
    end

    return obj
end

return function(graphics, theme)
    assert(graphics, "UI expects valid graphics interface.")
    assert(theme, "UI expects valid theme configuration.")

    Graphics, Theme = graphics, theme

    return {
        Window = Window,
        List = List,
        Bar = Bar,
        draw = draw
    }
end
