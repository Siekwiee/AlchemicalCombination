local InputHandler = require("src.userInput.handlers.InputHandler")

---@class UIHandler : InputHandler
---@field game_state GameState Game state reference
local UIHandler = setmetatable({}, { __index = InputHandler })
UIHandler.__index = UIHandler

---Creates a new UI input handler
---@param game_state GameState Game state reference
---@return UIHandler
function UIHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

---Handles key press events for UI elements
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
---@return boolean Whether the input was handled
function UIHandler:handle_key_pressed(key, scancode, isrepeat)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_key_pressed then
    local handled = ui_manager:handle_key_pressed(key, scancode, isrepeat)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles key release events for UI elements
---@param key string The key that was released
---@param scancode string The scancode of the key
---@return boolean Whether the input was handled
function UIHandler:handle_key_released(key, scancode)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_key_released then
    local handled = ui_manager:handle_key_released(key, scancode)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse press events for UI elements
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function UIHandler:handle_mouse_pressed(x, y, button)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_mouse_pressed then
    local handled = ui_manager:handle_mouse_pressed(x, y, button)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse release events for UI elements
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function UIHandler:handle_mouse_released(x, y, button)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_mouse_released then
    local handled = ui_manager:handle_mouse_released(x, y, button)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse move events for UI elements
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
---@return boolean Whether the input was handled
function UIHandler:handle_mouse_moved(x, y, dx, dy)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_mouse_moved then
    local handled = ui_manager:handle_mouse_moved(x, y, dx, dy)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse wheel events for UI elements
---@param x number Horizontal wheel movement
---@param y number Vertical wheel movement
---@return boolean Whether the input was handled
function UIHandler:handle_wheel_moved(x, y)
  -- Forward to UI manager if available
  local ui_manager = self:get_ui_manager()
  if ui_manager and ui_manager.handle_wheel_moved then
    local handled = ui_manager:handle_wheel_moved(x, y)
    if handled then
      return true
    end
  end
  
  return false
end

---Gets the UI manager from the game state
---@return table|nil The UI manager or nil if not found
function UIHandler:get_ui_manager()
  -- Try to get UI manager from game state
  if self.game_state and self.game_state.ui_manager then
    return self.game_state.ui_manager
  end
  
  -- Try to get from current state
  if self.game_state and self.game_state.current_state and self.game_state.current_state.ui_manager then
    return self.game_state.current_state.ui_manager
  end
  
  return nil
end

return UIHandler 