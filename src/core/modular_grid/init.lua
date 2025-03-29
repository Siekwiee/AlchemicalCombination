--This is the init file for the modular grid module
local ModularGrid = {}
ModularGrid.__index = ModularGrid

-- Import components
local ModularGridCore = require("src.core.modular_grid.core")
local ModularGridVisualization = require("src.core.modular_grid.visualization")

-- Forward function declarations
ModularGrid.new = ModularGridCore.new
ModularGrid.update = ModularGridCore.update
ModularGrid.get_cell_at = ModularGridCore.get_cell_at
ModularGrid.get_cell_by_position = ModularGridCore.get_cell_by_position
ModularGrid.add_item = ModularGridCore.add_item
ModularGrid.remove_item = ModularGridCore.remove_item
ModularGrid.combine_items = ModularGridCore.combine_items
ModularGrid.draw = ModularGridVisualization.draw

return ModularGrid