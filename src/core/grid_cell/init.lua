--This is the init file for the grid cell module
local GridCell = {}
GridCell.__index = GridCell

-- Import components
local GridCellCore = require("src.core.grid_cell.core")
local GridCellVisualization = require("src.core.grid_cell.visualization")

-- Forward function declarations
function GridCell.new(config)
  local cell = GridCellCore.new(config)
  return setmetatable(cell, GridCell)
end

function GridCell:update(mx, my)
  return GridCellCore.update(self, mx, my)
end

function GridCell:contains_point(x, y)
  return GridCellCore.contains_point(self, x, y)
end

function GridCell:add_item(item)
  return GridCellCore.add_item(self, item)
end

function GridCell:remove_item()
  return GridCellCore.remove_item(self)
end

function GridCell:has_item()
  return GridCellCore.has_item(self)
end

function GridCell:get_item()
  return self.item
end

function GridCell:draw()
  return GridCellVisualization.draw(self)
end

return GridCell