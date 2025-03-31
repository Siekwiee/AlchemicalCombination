local love = require("love")

local GridCellVisualization = {}

---Draws a grid cell
---@param cell table The grid cell to draw
---@param skip_item boolean Optional flag to skip drawing the item in this cell
function GridCellVisualization.draw(cell, skip_item)
  if not cell then
    return
  end
  
  local r, g, b, a = love.graphics.getColor()
  
  -- Draw cell background
  if cell.hover then
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
  else
    love.graphics.setColor(0.2, 0.2, 0.2, 0.6)
  end
  
  love.graphics.rectangle("fill", cell.x, cell.y, cell.width, cell.height)
  
  -- Draw cell border
  if cell.active then
    love.graphics.setColor(0.9, 0.7, 0.2, 1)
    love.graphics.setLineWidth(2)
  else
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setLineWidth(1)
  end
  
  love.graphics.rectangle("line", cell.x, cell.y, cell.width, cell.height)
  love.graphics.setLineWidth(1)
  
  -- Draw the item if there is one and we're not skipping it
  if cell.item and not skip_item then
    -- Draw item centered in cell
    local item_x = cell.x + cell.width / 2
    local item_y = cell.y + cell.height / 2
    
    if cell.item.texture then
      -- Draw item texture if available
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(
        cell.item.texture,
        item_x - cell.item.texture:getWidth() / 2,
        item_y - cell.item.texture:getHeight() / 2
      )
    else
      -- Draw a colored rectangle based on item type
      if cell.item.color then
        love.graphics.setColor(
          cell.item.color[1], 
          cell.item.color[2], 
          cell.item.color[3], 
          cell.item.color[4] or 1
        )
      else
        -- Default color if no specific color defined
        love.graphics.setColor(1, 0.8, 0.3, 1)
      end
      
      love.graphics.rectangle(
        "fill",
        item_x - cell.width * 0.35,
        item_y - cell.height * 0.35,
        cell.width * 0.7,
        cell.height * 0.7
      )
      
      -- Draw item name
      if cell.item.name then
        love.graphics.setColor(0, 0, 0, 1)
        local font = love.graphics.getFont()
        local text_width = font:getWidth(cell.item.name)
        local text_x = item_x - text_width / 2
        local text_y = item_y - font:getHeight() / 2
        
        love.graphics.print(cell.item.name, text_x, text_y)
      end
      
      -- Draw level indicator if applicable
      if cell.item.level and cell.item.level > 1 then
        love.graphics.setColor(1, 1, 1, 0.9)
        local level_text = "Lvl " .. cell.item.level
        local level_x = cell.x + cell.width - 5 - font:getWidth(level_text)
        local level_y = cell.y + cell.height - 5 - font:getHeight()
        
        love.graphics.print(level_text, level_x, level_y)
      end
    end
  end
  
  -- Restore original color
  love.graphics.setColor(r, g, b, a)
end

return GridCellVisualization 