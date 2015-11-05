local Conf = require "theme.conf"
--- @todo Replace explicit ListModel with model registration.
return function(Ui, width, height, ListModel)
    local windowWidth = width - 2 * Conf.Left
    local windowHeight = height - 2 * Conf.Top
--------------------------------------------------------------------------------
return Ui.Window {
    width = windowWidth,
    height = windowHeight,
    Ui.List {
        width = windowWidth / 2,
        height = windowHeight,
        model = ListModel
    }
}
--------------------------------------------------------------------------------
end
