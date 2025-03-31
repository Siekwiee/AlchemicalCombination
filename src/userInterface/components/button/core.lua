---@class ButtonCore
---@field check_click fun(button: Button, x: number, y: number, mouse_button: number): boolean
---@field update_state fun(button: Button, x: number, y: number): boolean
-- Button Core Logic
local ButtonCore = {}


function ButtonCore.check_click(button, x, y, mouse_button)
  -- Default to left mouse button if not specified
  if mouse_button ~= 1 then
    return false
  end
  
  if x >= button.x and x <= button.x + button.width and
   y >= button.y and y <= button.y + button.height then
    return true
  end

  return false
end
---@class Button
---@param button Button
function ButtonCore.update_state(button, mx, my)
  -- TODO:
  local hover = false
  if mx and my then
    hover = mx >= button.x and mx <= button.x + button.width and
                   my >= button.y and my <= button.y + button.height
  end

  return hover
end

return ButtonCore