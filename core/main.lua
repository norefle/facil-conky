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

local Conf = {}

Conf.Tasks = {}
Conf.Tasks.Top = 50
Conf.Tasks.Left = 50
Conf.Tasks.Limit = 10

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

local function initialize(style, path)
    if not Theme then
        Theme = require("core.theme." .. style)
    end

    if not Surface then
        Surface = cairo_xlib_surface_create(
            conky_window.display,
            conky_window.drawable,
            conky_window.visual,
            conky_window.width,
            conky_window.height
        )
    end
    if not Display then
        Display = cairo_create(Surface)
    end
    if not Graphics then
        Graphics = require("core.graphics")(Display)
    end
    if not Ui then
        Ui = require("core.ui")(Graphics, Theme)
    end

    if not Window then
        Window = Ui.Window {
            width = 900,
            height = 800,
            Ui.List {
                width = 800,
                height = 700,
                model = ListModel
            }
        }
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
    return M.flatten(
        M.map(states, function(_, board)
            local titleColor = exceededWip(board) and Theme.Color.Warning or Theme.Color.Success
            local textColor = Theme.Color.Text

            local title = { boardAsString(board), titleColor }

            local tasks = M.map(board.tasks, function(_, task) return { taskAsString(task), textColor } end)
            local tasksPrefix = M.take(tasks, (board.limit ~= 0) and board.limit or Conf.Tasks.Limit)
            return M.addTop(tasksPrefix, title, { "", Theme.Color.Text })
        end),
        true
    )
end

function conky_main(style, path)
    assert(style, "Expects not null style name")
    assert(path, "Expects not null path to facil")

    local updates = tonumber(conky_parse('${updates}'))
    if not conky_window or updates < 5 then
      return
    end

    initialize(style, path)

    cairo_select_font_face(Display, "Droid Sans Mono Slashed", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(Display, 12)

    ListModel.data = getTodoList(Facil.status(path))
    Ui.draw(Window, Conf.Tasks.Left, Conf.Tasks.Top)
end
