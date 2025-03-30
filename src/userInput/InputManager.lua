local Debug = require("src.core.debug.init")
local InputState = require("src.userInput.state.InputState")
local InputBindings = require("src.userInput.bindings.InputBindings")
local DefaultBindings = require("src.userInput.bindings.DefaultBindings")

-- Handlers
local StateHandlerFactory = require("src.userInput.handlers.StateHandlerFactory")
local GridHandler = require("src.userInput.handlers.GridHandler")
local UIHandler = require("src.userInput.handlers.UIHandler")
local InventoryHandler = require("src.userInput.handlers.InventoryHandler")

---@class InputManager
---@field game_state GameState The current game state
---@field state InputState Current input state tracking
---@field bindings InputBindings Key and button bindings
---@field handlers table Registered input handlers
local InputManager = {}
InputManager.__index = InputManager

---Creates a new input manager
---@param game_state GameState The game state to manage input for
---@return InputManager
function InputManager:new(game_state)
  local self = setmetatable({}, self)
  self.game_state = game_state
  
  -- Initialize input state tracking
  self.state = InputState:new()
  
  -- Initialize key and button bindings (with defaults)
  self.bindings = InputBindings:new(DefaultBindings)
  
  -- Initialize handlers
  self.handlers = {
    ui = UIHandler:new(game_state),
    grid = GridHandler:new(game_state),
    inventory = InventoryHandler:new(game_state),
    state = StateHandlerFactory:create_handler(game_state)
  }
  
  -- Logging options
  self.debug_enabled = false
  
  return self
end

---Updates the input state
---@param dt number Delta time
function InputManager:update(dt)
  self.state:update(dt)
  
  -- Update all handlers
  for _, handler in pairs(self.handlers) do
    if handler.update then
      handler:update(dt)
    end
  end
end

---Handles key press events
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
function InputManager:keypressed(key, scancode, isrepeat)
  -- Update state
  self.state:key_pressed(key, scancode, isrepeat)
  
  -- Debug output
  self:debug("keypressed", key)
  
  -- Check for game control keys
  if self:check_system_keys(key) then
    return
  end
  
  -- Forward to UI manager first (high priority)
  if self.handlers.ui:handle_key_pressed(key, scancode, isrepeat) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_key_pressed(key, scancode, isrepeat) then
    return
  end
  
  -- Handle specific game actions via bindings
  self:process_key_bindings(key)
end

---Checks system-level key operations
---@param key string The key that was pressed
---@return boolean Whether the key was handled
function InputManager:check_system_keys(key)
  -- Quit game
  if key == self.bindings:get_key("quit") then
    love.event.quit()
    return true
  end
  
  -- Toggle debug mode
  if key == self.bindings:get_key("debug_toggle") then
    self:toggle_debug()
    return true
  end
  
  return false
end

---Process key bindings to trigger game actions
---@param key string The key that was pressed
function InputManager:process_key_bindings(key)
  local action = self.bindings:get_action_for_key(key)
  
  if action == "inventory_toggle" then
    if self.game_state.components and self.game_state.components.inventory then
      self.game_state.components.inventory:toggle()
    end
  elseif action == "crafting_open" then
    if self.game_state.components and self.game_state.components.crafting then
      self.game_state.components.crafting:open_menu()
    end
  end
end

---Handles key release events
---@param key string The key that was released
---@param scancode string The scancode of the key
function InputManager:keyreleased(key, scancode)
  -- Update state
  self.state:key_released(key, scancode)
  
  -- Forward to UI manager first
  if self.handlers.ui:handle_key_released(key, scancode) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_key_released(key, scancode) then
    return
  end
end

---Handles mouse press events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param button number Mouse button that was pressed
function InputManager:mousepressed(x, y, button)
  -- Update state
  self.state:mouse_pressed(x, y, button)
  
  -- Debug output
  self:debug("mousepressed", x .. "," .. y .. " btn:" .. button)
  
  -- Forward to UI manager first (high priority)
  if self.handlers.ui:handle_mouse_pressed(x, y, button) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_mouse_pressed(x, y, button) then
    return
  end
  
  -- Forward to grid handler
  if self.handlers.grid:handle_mouse_pressed(x, y, button) then
    return
  end
  
  -- Forward to inventory handler
  if self.handlers.inventory:handle_mouse_pressed(x, y, button) then
    return
  end
end

---Handles mouse release events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param button number Mouse button that was released
function InputManager:mousereleased(x, y, button)
  -- Update state
  self.state:mouse_released(x, y, button)
  
  -- Debug output
  self:debug("mousereleased", x .. "," .. y .. " btn:" .. button)
  
  -- Forward to UI manager first
  if self.handlers.ui:handle_mouse_released(x, y, button) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_mouse_released(x, y, button) then
    return
  end
  
  -- Forward to grid handler
  if self.handlers.grid:handle_mouse_released(x, y, button) then
    return
  end
  
  -- Forward to inventory handler
  if self.handlers.inventory:handle_mouse_released(x, y, button) then
    return
  end
end

---Handles mouse move events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
function InputManager:mousemoved(x, y, dx, dy)
  -- Update state
  self.state:mouse_moved(x, y, dx, dy)
  
  -- Forward to UI manager first
  if self.handlers.ui:handle_mouse_moved(x, y, dx, dy) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_mouse_moved(x, y, dx, dy) then
    return
  end
end

---Handles mouse wheel events
---@param x number Horizontal wheel movement
---@param y number Vertical wheel movement
function InputManager:wheelmoved(x, y)
  -- Update state
  self.state:wheel_moved(x, y)
  
  -- Forward to UI manager first
  if self.handlers.ui:handle_wheel_moved(x, y) then
    return
  end
  
  -- Forward to current state handler
  if self.handlers.state and self.handlers.state:handle_wheel_moved(x, y) then
    return
  end
end

---Registers a new input handler
---@param name string Handler name/type
---@param handler table The handler to register
function InputManager:register_handler(name, handler)
  self.handlers[name] = handler
end

---Toggles debug mode for the input manager
function InputManager:toggle_debug()
  self.debug_enabled = not self.debug_enabled
  
  -- Also toggle in game components if available
  if self.game_state.components and self.game_state.components.debug then
    self.game_state.components.debug:toggle()
  end
  
  Debug.debug(Debug, "Input debug mode " .. (self.debug_enabled and "enabled" or "disabled"))
end

---Logs a debug message if debug is enabled
---@param event string Event name
---@param data any Data to log
function InputManager:debug(event, data)
  if not self.debug_enabled then return end
  Debug.debug(Debug, "InputManager:" .. event .. " - " .. tostring(data))
end

---Sets key bindings
---@param bindings table Key bindings to set
function InputManager:set_bindings(bindings)
  self.bindings:set_bindings(bindings)
end

return InputManager 