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

    function obj:draw(x, y)
        local x, y, width, height = x, y, self.width, self.height
        Graphics:rectangle(Theme.Color.Border, x, y, width, height)
    end

    return obj
end

local function draw(element, x, y)
    if hasMethod(element, "draw") then
        element:draw(x or 0, y or 0)
    end

    M.forEach(element.children, function(_, child) draw(child, x, y) end)
end

-- Core functionality
local function Window(prototype)
    local obj = object(prototype)
    obj.name = "Window"

    return obj
end

local function List(prototype)
    local obj = object(prototype)
    obj.name = "List"
    obj.draw = M.wrap(obj.draw, function(f, self, x, y)
        f(self, x, y)
        if M.has(self, "model") and M.has(self.model, "data") then
            M.forEach(self.model.data, function(index, value)
                local text, color = unpack(value)
                Graphics:print(text, x, y + index * 20, color)
            end)
        end
    end)

    return obj
end

return function(graphics, theme)
    assert(graphics, "UI expects valid graphics interface.")
    assert(theme, "UI expects valid theme configuration.")

    Graphics, Theme = graphics, theme

    return {
        Window = Window,
        List = List,
        draw = draw
    }
end