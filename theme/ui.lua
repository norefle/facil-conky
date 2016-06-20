local Conf = require "flconky.theme.conf"
--- @todo Replace explicit ListModel with model registration.
return function(Ui, width, height, ListModel, CpuModel, TempModel, MemoryModel, NetworkModel)
    local windowWidth = width - 2 * Conf.Left
    local windowHeight = height - 2 * Conf.Top

    local function cpu(x, y, width, height, count)
        local bars = {}
        for i = 1, count do
            local spacer = 5
            bars[#bars + 1] = Ui.Bar {
                x = x + (i - 1) * width + spacer * math.modf((i - 1) / 2),
                y = y,
                orientation = "vertical",
                model = CpuModel[i],
                width = width,
                height = height
            }
        end

        return bars
    end
--------------------------------------------------------------------------------
    local window = Ui.Window {
        x = Conf.Left,
        y = Conf.Top,
        width = windowWidth,
        height = windowHeight,
        -- Ui.Vertical {
        -- @todo Remove x,y and use layouts instead.
        Ui.List {
            x = Conf.Left + 5,
            y = Conf.Top + 5,
            width = windowWidth / 2,
            height = windowHeight - 10,
            model = ListModel
        },
        -- Ui.Horizontal {
        Ui.List {
            x = windowWidth - 210,
            y = windowHeight - 270 - ((TempModel.data and #TempModel.data or 0) * 20),
            width = 215,
            height = 250,
            model = TempModel
        },
        Ui.Bar {
            -- Memory
            x = windowWidth - 210,
            y = windowHeight - 55,
            orientation = "horizontal",
            model = MemoryModel,
            width = 215,
            height = 50
        },
        Ui.Bar {
            -- Network up
            x = windowWidth - 210,
            y = windowHeight + 10,
            orientation = "horizontal",
            model = NetworkModel.up,
            width = 215,
            height = 25
        },
        Ui.Bar {
            -- Network down
            x = windowWidth - 210,
            y = windowHeight + 35,
            orientation = "horizontal",
            model = NetworkModel.down,
            width = 215,
            height = 25
        }

    }
--------------------------------------------------------------------------------
    local cpus = cpu(windowWidth - 210, windowHeight - 170, 25, 100, #CpuModel)
    for _, v in pairs(cpus) do
        window.children[#window.children + 1] = v
    end
    return window
end
