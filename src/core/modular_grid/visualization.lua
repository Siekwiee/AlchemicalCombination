local love = require("love")
local Debug = require("src.core.debug.init")
local GridCellVisualization = require("src.core.grid_cell.visualization")

local ModularGridVisualization = {}

---Draws a modular grid
---@param grid table The grid to draw
function ModularGridVisualization.draw(grid)
  local r, g, b, a = love.graphics.getColor()
  
  -- Draw grid background
  love.graphics.setColor(0.2, 0.2, 0.2, 1)
  love.graphics.rectangle("fill", grid.x, grid.y, grid.width, grid.height)
  
  -- Draw grid border
  love.graphics.setColor(0.6, 0.6, 0.6, 1)
  love.graphics.rectangle(
    "line", 
    grid.x - grid.spacing, 
    grid.y - grid.spacing, 
    grid.width + grid.spacing * 2, 
    grid.height + grid.spacing * 2
  )
  
  -- Draw grid label if needed
  if grid.title then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(grid.title, grid.x, grid.y - 20)
  end
  
  -- Draw each cell
  for id, cell in pairs(grid.cells) do
    -- Draw cell background
    if cell == grid.selected_cell then
      -- Selected cell gets a bright highlight
      love.graphics.setColor(1, 0.8, 0.2, 1) -- Bright gold
    elseif cell.hover then
      -- Hovered cell gets a subtle highlight
      love.graphics.setColor(0.4, 0.4, 0.5, 1)
    else
      love.graphics.setColor(0.3, 0.3, 0.3, 1)
    end
    love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
    
    -- Draw cell border
    if cell == grid.selected_cell then
      -- Selected cell gets a thick bright border
      love.graphics.setColor(1, 1, 0, 1) -- Bright yellow
      love.graphics.setLineWidth(3)
    else
      love.graphics.setColor(0.4, 0.4, 0.4, 1)
      love.graphics.setLineWidth(1)
    end
    love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
    love.graphics.setLineWidth(1) -- Reset line width
    
    -- Draw cell contents
    if cell.item then
      -- Draw item
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf(cell.item.name or "???", 
        cell.x, cell.y + cell.height/2 - 10, 
        cell.width, "center")
    end
  end
  
  -- Reset color
  love.graphics.setColor(r, g, b, a)
end

return ModularGridVisualization 