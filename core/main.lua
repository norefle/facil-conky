require "cairo"

local Facil = require "facil"
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
        local count = 0
        for _, lane in pairs(states) do
            local limit = (lane.limit ~= 0) and lane.limit or Conf.Tasks.Limit
            local header = string.format(
                "[ %3d | %3d ] %s", #lane.tasks, lane.wip, lane.name
            )
            local full = (lane.wip ~= 0) and (#lane.tasks >= lane.wip) or false
            if full then
              cairo_set_source_rgba(display, unpack(Theme.Color.Warning))
            else
              cairo_set_source_rgba(display, unpack(Theme.Color.Success))
            end
            cairo_move_to(display, Conf.Tasks.Left, Conf.Tasks.Top  + 20 * count)
            cairo_show_text(display, header)
            cairo_set_source_rgba(display, unpack(Theme.Color.Text))
            local taskCount = 0
            for _, task in pairs(lane.tasks) do
                count = count + 1
                cairo_move_to(display, Conf.Tasks.Left, Conf.Tasks.Top  + 20 * count)

                taskCount = taskCount + 1
                if limit < taskCount then
                    cairo_show_text(display, "..." .. (#lane.tasks - taskCount) .. " more ...")
                    break
                end
                local result = string.format(
                    "%s %s (%s)",
                    os.date("%d.%m.%Y", task.moved),
                    task.name,
                    task.id:sub(1, 8)
                )
                cairo_show_text(display, result)
            end
          count = count + 2
        end
    end

    cairo_destroy(display)
    cairo_surface_destroy(surface)
end
