local Debug = require("src.core.debug.init")
local InputHandler = require("src.userInput.handlers.InputHandler")

---@class PlayStateHandler : InputHandler
---@field game_state GameState Game state reference
local PlayStateHandler = setmetatable({}, { __index = InputHandler })
PlayStateHandler.__index = PlayStateHandler

---Creates a new play state input handler
---@param game_state GameState Game state reference
---@return PlayStateHandler
function PlayStateHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

---Handles key press events in play state
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
---@return boolean Whether the input was handled
function PlayStateHandler:handle_key_pressed(key, scancode, isrepeat)
  local current_state = self.game_state.current_state
  
  -- If the current state has its own handler, use that
  if current_state and current_state.keypressed then
    local handled = current_state:keypressed(key, scancode, isrepeat)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse press events in play state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function PlayStateHandler:handle_mouse_pressed(x, y, button)
  local current_state = self.game_state.current_state
  
  -- If the current state has its own handler, use that
  if current_state and current_state.mousepressed then
    local handled = current_state:mousepressed(x, y, button)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse release events in play state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function PlayStateHandler:handle_mouse_released(x, y, button)
  local current_state = self.game_state.current_state
  
  -- If the current state has its own handler, use that
  if current_state and current_state.mousereleased then
    local handled = current_state:mousereleased(x, y, button)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles mouse move events in play state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
---@return boolean Whether the input was handled
function PlayStateHandler:handle_mouse_moved(x, y, dx, dy)
  local current_state = self.game_state.current_state
  
  -- If the current state has its own handler, use that
  if current_state and current_state.mousemoved then
    local handled = current_state:mousemoved(x, y, dx, dy)
    if handled then
      return true
    end
  end
  
  return false
end

---Handles wheel events in play state
---@param x number Horizontal wheel movement
---@param y number Vertical wheel movement
---@return boolean Whether the input was handled
function PlayStateHandler:handle_wheel_moved(x, y)
  local current_state = self.game_state.current_state
  
  -- If the current state has its own handler, use that
  if current_state and current_state.wheelmoved then
    local handled = current_state:wheelmoved(x, y)
    if handled then
      return true
    end
  end
  
  return false
end

return PlayStateHandler 