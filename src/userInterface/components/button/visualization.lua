local love = require("love")

---@class ButtonViz
---@field draw fun(button: Button)
-- Button Visualization
local ButtonViz = {}

function ButtonViz.draw(button)
  local r, g, b, a = love.graphics.getColor()
  
  -- Define colors based on button state
  local bg_color = {0.3, 0.3, 0.3, 1}
  if button.hover then
    bg_color = {0.5, 0.5, 0.5, 1}
  end
  if button.active then
    bg_color = {0.7, 0.7, 0.7, 1}
  end
  if button.disabled then
    bg_color = {0.2, 0.2, 0.2, 0.5}
  end
  
  -- Draw button background
  love.graphics.setColor(bg_color)
  love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
  
  -- Draw button border
  love.graphics.setColor(0.8, 0.8, 0.8, 1)
  love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
  
  -- Draw button text
  if button.text then
    love.graphics.setColor(1, 1, 1, 1)
    local font = love.graphics.getFont()
    local text_width = font:getWidth(button.text)
    local text_height = font:getHeight()
    local text_x = button.x + (button.width - text_width) / 2
    local text_y = button.y + (button.height - text_height) / 2
    
    love.graphics.print(button.text, text_x, text_y)
  end
  
  -- Restore original color
  love.graphics.setColor(r, g, b, a)
end

return ButtonViz
