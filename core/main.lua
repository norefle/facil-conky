require "cairo"

local Facil = require "facil"
local M = require "moses"
local Theme = nil

local Conf = {}

Conf.Tasks = {}
Conf.Tasks.Top = 50
Conf.Tasks.Left = 50
Conf.Tasks.Limit = 10

--[[
@todo Desired structure to describe the theme is the following one (pseudocode):
    @code
    local cpu = Conky.CPU {
        text = "cpu0"
    }
    local main = UI.Window {
        theme = Theme,
        width = 800,
        height = 600,
        UI.Horizontal {
            UI.Panel {
                width = 200,
                UI.Label {
                    text = "Hello world"
                }
            },
            UI.Spacer { },
            UI.Status {
                text = "CPU: 0",
                source = cpu,
            }
        }
    }
    @endcode
]]--

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

function conky_main(style, path)
    assert(style, "Expects not null style name")
    assert(path, "Expects not null path to facil")

    local updates = tonumber(conky_parse('${updates}'))
    if not conky_window or updates < 5 then
      return
    end

    if not Theme then
        Theme = require("core.theme." .. style)
    end


    local surface = cairo_xlib_surface_create(
      conky_window.display,
      conky_window.drawable,
      conky_window.visual,
      conky_window.width,
      conky_window.height
    )

    local display = cairo_create(surface)

    cairo_select_font_face(display, "Droid Sans Mono Slashed", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(display, 12)

    local states, description = Facil.status(path)
    if states then
        -- Transfrom to list of tuples: (string, color).
        local todoList = M.flatten(
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
        -- Print result on desktop.
        M.forEach(todoList, function(index, value)
            local text, color = unpack(value)
            cairo_set_source_rgba(display, unpack(color))
            cairo_move_to(display, Conf.Tasks.Left, Conf.Tasks.Top  + 20 * index)
            cairo_show_text(display, text)
        end)
    end

    cairo_destroy(display)
    cairo_surface_destroy(surface)
end
