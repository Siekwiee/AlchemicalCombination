--This is the init file for the grid cell module
local GridCell = {}
GridCell.__index = GridCell

-- Import components
local GridCellCore = require("src.core.grid_cell.core")
local GridCellVisualization = require("src.core.grid_cell.visualization")

-- Forward function declarations
GridCell.new = GridCellCore.new
GridCell.update = GridCellCore.update
GridCell.contains_point = GridCellCore.contains_point
GridCell.add_item = GridCellCore.add_item
GridCell.remove_item = GridCellCore.remove_item
GridCell.has_item = GridCellCore.has_item
GridCell.draw = GridCellVisualization.draw

return GridCell