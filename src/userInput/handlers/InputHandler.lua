---@class InputHandler
---@field game_state GameState The game state reference
local InputHandler = {}
InputHandler.__index = InputHandler

---Creates a new input handler
---@param game_state GameState Game state reference
---@return InputHandler
function InputHandler:new(game_state)
  local self = setmetatable({}, { __index = self })
  self.game_state = game_state
  return self
end

-- Input handling methods (to be overridden by subclasses)

---Handles key press events
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
---@return boolean Whether the input was handled
function InputHandler:handle_key_pressed(key, scancode, isrepeat)
  return false
end

---Handles key release events
---@param key string The key that was released
---@param scancode string The scancode of the key
---@return boolean Whether the input was handled
function InputHandler:handle_key_released(key, scancode)
  return false
end

---Handles mouse press events
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handle_mouse_pressed(x, y, button)
  return false
end

---Handles mouse release events
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function InputHandler:handle_mouse_released(x, y, button)
  return false
end

---Handles mouse move events
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Change in X position
---@param dy number Change in Y position
---@return boolean Whether the input was handled
function InputHandler:handle_mouse_moved(x, y, dx, dy)
  return false
end

---Handles mouse wheel events
---@param x number Horizontal wheel movement
---@param y number Vertical wheel movement
---@return boolean Whether the input was handled
function InputHandler:handle_wheel_moved(x, y)
  return false
end

---Updates the handler state
---@param dt number Delta time
function InputHandler:update(dt)
end

return InputHandler 