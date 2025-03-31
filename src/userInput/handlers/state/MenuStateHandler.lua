local InputHandler = require("src.userInput.handlers.InputHandler")

---@class MenuStateHandler : InputHandler
---@field game_state GameState Game state reference
local MenuStateHandler = setmetatable({}, { __index = InputHandler })
MenuStateHandler.__index = MenuStateHandler

---Creates a new menu state input handler
---@param game_state GameState Game state reference
---@return MenuStateHandler
function MenuStateHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

---Handles key press events in menu state
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
---@return boolean Whether the input was handled
function MenuStateHandler:handle_key_pressed(key, scancode, isrepeat)
  local current_state = self.game_state.current_state
  
  -- Navigation keys in menu
  if key == "up" or key == "w" then
    if current_state and current_state.select_previous_button then
      current_state:select_previous_button()
      return true
    end
  elseif key == "down" or key == "s" then
    if current_state and current_state.select_next_button then
      current_state:select_next_button()
      return true
    end
  elseif key == "return" or key == "space" then
    if current_state and current_state.activate_selected_button then
      current_state:activate_selected_button()
      return true
    end
  end
  
  -- If the current state has its own handler, use that
  if current_state and current_state.keypressed then
    local handled = current_state:keypressed(key, scancode, isrepeat)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse press events in menu state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function MenuStateHandler:handle_mouse_pressed(x, y, button)
  -- Only handle left clicks for menu buttons
  if button ~= 1 then
    return false
  end
  
  -- Check current menu state
  local current_state = self.game_state.current_state
  if not current_state then
    return false
  end
  
  -- If the state has a dedicated handler, use it
  if current_state.mousepressed then
    local handled = current_state:mousepressed(x, y, button)
    if handled then
      return true
    end
  end
  
  -- Handle button clicks
  if current_state.ui_buttons then
    for _, button in ipairs(current_state.ui_buttons) do
      if self:is_point_in_button(button, x, y) then
        button.active = true
        return true
      end
    end
  end
  
  return false
end

---Handles mouse release events in menu state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function MenuStateHandler:handle_mouse_released(x, y, button)
  -- Only handle left clicks for menu
  if button ~= 1 then
    return false
  end
  
  -- Check current menu state
  local current_state = self.game_state.current_state
  if not current_state then
    return false
  end
  
  -- If the state has a dedicated handler, use it
  if current_state.mousereleased then
    local handled = current_state:mousereleased(x, y, button)
    if handled then
      return true
    end
  end
  
  -- Handle button clicks
  if current_state.ui_buttons then
    for i, ui_button in ipairs(current_state.ui_buttons) do
      -- Check if button was active
      if ui_button.active then
        ui_button.active = false
        
        -- Check if release is within the button
        if self:is_point_in_button(ui_button, x, y) then
          if ui_button.on_click then
            ui_button:on_click()
          end
          return true
        end
      end
    end
  end
  
  return false
end

---Checks if a point is within a button
---@param button table Button to check
---@param x number Point X position
---@param y number Point Y position
---@return boolean Whether the point is within the button
function MenuStateHandler:is_point_in_button(button, x, y)
  return x >= button.x and x <= button.x + button.width and
         y >= button.y and y <= button.y + button.height
end

return MenuStateHandler 