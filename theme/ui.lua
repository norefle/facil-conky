local Conf = require "theme.conf"
--- @todo Replace explicit ListModel with model registration.
return function(Ui, width, height, ListModel, CpuModel, MemoryModel, NetworkModel)
    local windowWidth = width - 2 * Conf.Left
    local windowHeight = height - 2 * Conf.Top
--------------------------------------------------------------------------------
return Ui.Window {
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
    Ui.Bar {
        -- CPU0
        x = windowWidth - 210,
        y = windowHeight - 170,
        orientation = "vertical",
        model = CpuModel[1],
        width = 50,
        height = 100
    },
    Ui.Bar {
        -- CPU1
        x = windowWidth - 215 + 60,
        y = windowHeight - 170,
        orientation = "vertical",
        model = CpuModel[2],
        width = 50,
        height = 100
    },
    Ui.Bar {
        -- CPU2
        x = windowWidth - 215 + 115,
        y = windowHeight - 170,
        orientation = "vertical",
        model = CpuModel[3],
        width = 50,
        height = 100
    },
    Ui.Bar {
        -- CPU3
        x = windowWidth - 215 + 170,
        y = windowHeight - 170,
        orientation = "vertical",
        model = CpuModel[4],
        width = 50,
        height = 100
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
end
