-- Button Core Logic
local ButtonCore = {}

function ButtonCore.check_click(button, x, y, mouse_button)
  -- Default to left mouse button if not specified
  mouse_button = mouse_button or 1
  
  -- Check if point is within button boundaries
  if x >= button.x and x <= button.x + button.width and
     y >= button.y and y <= button.y + button.height then
    -- Call the on_click callback if provided
    if button.on_click then
      button.on_click(button)
    end
    return true
  end
  
  return false
end

function ButtonCore.update_state(button, x, y)
  -- Update hover state
  button.hover = x and y and 
                 x >= button.x and x <= button.x + button.width and
                 y >= button.y and y <= button.y + button.height
  
  return button.hover
end

return ButtonCore