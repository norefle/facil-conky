require "cairo"

local Surface = nil
local Display = nil

local M = require "moses"
local Facil = require "facil"

local Graphics = nil
local Ui = nil
local Window = nil
local Theme = nil
local ListModel = {}
local CpuModel = { }
local MemoryModel = { use = 0, total = 100 }
local NetworkModel = {
    up = { use = 0, total = 5000 },
    down = { use = 0, total = 5000 }
}

local function boardAsString(board)
    return string.format("[ %3d | %3d ] %s",
        #board.tasks,
        board.wip,
        board.name
    )
end

local function taskAsString(task)
    return string.format("%s %s (%s)",
        os.date("%d.%m.%Y", task.moved),
        task.name,
        task.id:sub(1, 8)
    )
end

local function exceededWip(board)
    return (board.wip ~= 0) and (#board.tasks >= board.wip)
end

local function initialize(style, path, width, height, cpus)
    if not Surface then
        Surface = cairo_xlib_surface_create(
            conky_window.display,
            conky_window.drawable,
            conky_window.visual,
            conky_window.width,
            conky_window.height
        )
        Display = cairo_create(Surface)
    end
    if not Window then
        Theme = M.extend(require("flconky.theme." .. style), require("flconky.theme.conf"))
        Theme.Tasks.Limit = math.modf((height / 20) / 4)
        Graphics = require("flconky.core.graphics")(Display)
        Ui = require("flconky.core.ui")(Graphics, Theme)
        CpuModel = M.map(M.range(1, cpus), function(_, index)
            return { use = 0, total = 100 }
        end)
        Window = require("flconky.theme.ui")(Ui, width, height, ListModel, CpuModel, MemoryModel, NetworkModel)
    end
end

local function cleanup()
    cairo_destroy(Display)
    cairo_surface_destroy(Surface)
end

local function getTodoList(states, description)
    if not states then
        return { { description, Theme.Color.Warning } }
    end
    return M.tail(M.flatten(
        M.map(states, function(_, board)
            local titleColor = exceededWip(board) and Theme.Color.Warning or Theme.Color.Success
            local textColor = Theme.Color.Text

            local title = { boardAsString(board), titleColor }

            local tasks = M.map(board.tasks, function(_, task) return { taskAsString(task), textColor } end)
            local tasksPrefix = M.take(tasks, (board.limit ~= 0) and board.limit or Theme.Tasks.Limit)
            local gap = #tasks - #tasksPrefix
            if gap > 0 then
                M.push(tasksPrefix, {string.format("...%d more...", gap), textColor })
            end
            return M.addTop(tasksPrefix, title, { "", Theme.Color.Text })
        end),
        true
    ), 2)
end

function conky_main(style, path, width, height, netinterface, cpus)
    assert(style, "Expects not null style name")
    assert(path, "Expects not null path to facil")

    local updates = tonumber(conky_parse('${updates}'))
    if not conky_window or updates < 5 then
      return
    end

    initialize(style, path, width, height, cpus)

    M.forEach(CpuModel, function(index, _)
        CpuModel[index].use = tonumber(conky_parse("${cpu cpu" .. index .. "}"))
    end)

    MemoryModel.use = tonumber(conky_parse("${memperc}"))
    NetworkModel.up.use = tonumber(conky_parse("${upspeedf " .. netinterface .. "}"))
    NetworkModel.down.use = tonumber(conky_parse("${downspeedf " .. netinterface .. "}"))



    cairo_select_font_face(Display, "Droid Sans Mono Slashed", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(Display, 12)

    ListModel.data = getTodoList(Facil.status(path))
    Ui.draw(Window, Theme.Left, Theme.Top)
end
