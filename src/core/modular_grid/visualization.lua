local love = require("love")
local Debug = require("src.core.debug.init")
local GridCellVisualization = require("src.core.grid_cell.visualization")

local ModularGridVisualization = {}

---Draws a modular grid
---@param grid table The grid to draw
function ModularGridVisualization.draw(grid)
  local r, g, b, a = love.graphics.getColor()
  
  -- Draw grid background
  love.graphics.setColor(0.15, 0.15, 0.15, 0.5)
  love.graphics.rectangle(
    "fill", 
    grid.x - grid.spacing, 
    grid.y - grid.spacing, 
    grid.width + grid.spacing * 2, 
    grid.height + grid.spacing * 2
  )
  
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
    -- Instead of using cell:draw() which doesn't exist, use the visualization module directly
    GridCellVisualization.draw(cell)
  end
  
  -- Draw dragged item if any
  if grid.drag_item then
    local mx, my = love.mouse.getPosition()
    
    -- Draw item centered on mouse
    love.graphics.setColor(1, 1, 1, 0.8)
    if grid.drag_item.texture then
      love.graphics.draw(
        grid.drag_item.texture,
        mx - grid.drag_item.texture:getWidth() / 2,
        my - grid.drag_item.texture:getHeight() / 2
      )
    else
      -- Draw placeholder
      love.graphics.setColor(1, 0.8, 0.3, 0.8)
      love.graphics.rectangle(
        "fill",
        mx - grid.cell_width * 0.3,
        my - grid.cell_height * 0.3,
        grid.cell_width * 0.6,
        grid.cell_height * 0.6
      )
      
      -- Draw item name if available
      if grid.drag_item.name then
        love.graphics.setColor(0, 0, 0, 1)
        local font = love.graphics.getFont()
        local text_width = font:getWidth(grid.drag_item.name)
        local text_x = mx - text_width / 2
        local text_y = my - font:getHeight() / 2
        
        love.graphics.print(grid.drag_item.name, text_x, text_y)
      end
    end
  end
  
  -- Restore original color
  love.graphics.setColor(r, g, b, a)
end

return ModularGridVisualization 