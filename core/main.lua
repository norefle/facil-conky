require "cairo"

local Facil = require "facil"
local Moses = require "moses"
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
    cairo_set_source_rgba(display, 0, 0, 255, 1)

    cairo_select_font_face(display, "Droid Sans Mono Slashed", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(display, 12)

    local states, description = Facil.status(path)
    if states then
        -- Transfrom to string list.
        local todoList = Moses.flatten(
            Moses.map(states, function(_, board)
                local title = string.format("[ %3d | %3d ] %s", #board.tasks, board.wip, board.name)
                local tasks = Moses.map(board.tasks, function(_, task)
                    return string.format("%s %s (%s)",
                        os.date("%d.%m.%Y", task.moved),
                        task.name,
                        task.id:sub(1, 8)
                    )
                end)
                return Moses.addTop(Moses.take(tasks, (board.limit ~= 0) and board.limit or Conf.Tasks.Limit), { "", title })
            end)
        )
        -- Print result on desktop.
        Moses.forEach(todoList, function(index, value)
            cairo_set_source_rgba(display, unpack(Theme.Color.Text))
            cairo_move_to(display, Conf.Tasks.Left, Conf.Tasks.Top  + 20 * index)
            cairo_show_text(display, value)
        end)
    end

    cairo_destroy(display)
    cairo_surface_destroy(surface)
end
