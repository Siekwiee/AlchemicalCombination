local love = require("love")
local Debug = require("src.core.debug.init")

local GridCellVisualization = {}

---Draws a grid cell
---@param cell table The grid cell to draw
function GridCellVisualization.draw(cell)
  local r, g, b, a = love.graphics.getColor()
  
  -- Define colors based on cell state
  local bg_color = {0.2, 0.2, 0.2, 0.8}
  local border_color = {0.5, 0.5, 0.5, 1}
  
  if cell.hover then
    bg_color = {0.3, 0.3, 0.3, 0.8}
    border_color = {0.7, 0.7, 0.7, 1}
  end
  
  if cell.active then
    bg_color = {0.4, 0.4, 0.4, 0.8}
    border_color = {0.9, 0.9, 0.9, 1}
  end
  
  -- Draw cell background
  love.graphics.setColor(bg_color)
  love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
  
  -- Draw cell border
  love.graphics.setColor(border_color)
  love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
  
  -- Draw item if present
  if cell.item then
    love.graphics.setColor(1, 1, 1, 1)
    -- Draw item representation
    if cell.item.texture then
      -- If the item has a texture, draw it
      love.graphics.draw(
        cell.item.texture,
        cell.x + (cell.width - cell.item.texture:getWidth()) / 2,
        cell.y + (cell.height - cell.item.texture:getHeight()) / 2
      )
    else
      -- Otherwise, draw a placeholder
      love.graphics.setColor(1, 0.8, 0.3, 1)
      love.graphics.rectangle(
        "fill",
        cell.x + cell.width * 0.2,
        cell.y + cell.height * 0.2,
        cell.width * 0.6,
        cell.height * 0.6
      )
      
      -- Draw item name if available
      if cell.item.name then
        love.graphics.setColor(0, 0, 0, 1)
        local font = love.graphics.getFont()
        local text_width = font:getWidth(cell.item.name)
        local text_x = cell.x + (cell.width - text_width) / 2
        local text_y = cell.y + cell.height * 0.4
        
        love.graphics.print(cell.item.name, text_x, text_y)
      end
    end
  end
  
  -- Restore original color
  love.graphics.setColor(r, g, b, a)
end

return GridCellVisualization 