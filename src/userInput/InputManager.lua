local InputState = require("src.userInput.state.InputState")
local InputBindings = require("src.userInput.bindings.InputBindings")
local DefaultBindings = require("src.userInput.bindings.DefaultBindings")

-- Handlers
local StateHandlerFactory = require("src.userInput.handlers.StateHandlerFactory")
local GridHandler = require("src.userInput.handlers.GridHandler")
local UIHandler = require("src.userInput.handlers.UIHandler")
local InventoryHandler = require("src.userInput.handlers.InventoryHandler")

---@class InputManager
---@field game_state GameState Reference to the game state
---@field bindings InputBindings Keyboard and mouse bindings
---@field handlers table<string, InputHandler> Handler instances for different input types
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
  
  -- Debounce state
  self.last_mouse_press_time = 0
  self.debounce_interval = 0.05 -- Ignore clicks within 50ms of the last processed one
  
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
  -- First handle UI through UI handler
  if self.handlers.ui:handle_key_pressed(key, scancode, isrepeat) then
    return true
  end
  
  -- Then handle game state specific input
  if self.handlers.state and self.handlers.state:handle_key_pressed(key, scancode, isrepeat) then
    return true
  end
  
  -- Handle menu navigation with keyboard
  if key == "up" or key == "down" or key == "left" or key == "right" then
    -- Implement menu navigation logic here
    return true
  end
  
  -- Handle menu selection with enter/space
  if key == "return" or key == "space" then
    -- Implement menu selection logic here
    return true
  end
  
  return false
end

---Process key bindings and execute corresponding actions
---@param key string The key that was pressed
function InputManager:process_key_bindings(key)
  -- Get the action for this key
  local action = self.bindings:get_action(key)
  
  -- Execute the action if found
  if action then
    self:execute_action(action)
    return true
  end
  
  return false
end

---Executes a game action
---@param action string The action to execute
function InputManager:execute_action(action)
  -- Implement actions like movement, attack, etc.
  if action == "move_up" then
    -- Move player up
  elseif action == "move_down" then
    -- Move player down
  elseif action == "move_left" then
    -- Move player left
  elseif action == "move_right" then
    -- Move player right
  elseif action == "attack" then
    -- Attack
  end
end

---Process system key commands
---@param key string The key that was pressed
---@return boolean Whether a system key was processed
function InputManager:check_system_keys(key)
  -- Check for system-level keys like quit, toggle fullscreen, etc.
  if key == "escape" then
    -- Handle escape key (menu, back, quit)
    return true
  elseif key == "f11" then
    -- Toggle fullscreen
    love.window.setFullscreen(not love.window.getFullscreen())
    return true
  end
  
  return false
end

---Handles key release events
---@param key string The key that was released
---@param scancode string The scancode of the key
function InputManager:keyreleased(key, scancode)
  -- First handle UI through UI handler
  if self.handlers.ui:handle_key_released(key, scancode) then
    return true
  end
  
  -- Then handle game state specific input
  if self.handlers.state and self.handlers.state:handle_key_released(key, scancode) then
    return true
  end
  
  return false
end

---Handles mouse press events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param button number Mouse button that was pressed
function InputManager:mousepressed(x, y, button)
  -- Debounce check
  local current_time = love.timer.getTime()
  if current_time - self.last_mouse_press_time < self.debounce_interval then
      return false -- Ignore this click event
  end
  
  -- Record the time of this processed click
  self.last_mouse_press_time = current_time
  
  -- Process handlers in priority order
  local handled = false
  
  -- Priority 1: UI handler (buttons, windows, etc.)
  if not handled and self.handlers.ui then
      handled = self.handlers.ui:handle_mouse_pressed(x, y, button)
  end
  
  -- Priority 2: Active inventory
  if not handled and self.handlers.inventory then
      local inventory = self:get_inventory()
      if inventory and inventory.visible then
          handled = self.handlers.inventory:handle_mouse_pressed(x, y, button)
      end
  end
  
  -- Priority 3: Active grid
  if not handled and self.handlers.grid then
      local grid = self:get_grid()
      if grid and grid.visible then
          handled = self.handlers.grid:handle_mouse_pressed(x, y, button)
      end
  end
  
  -- Priority 4: Game state handler
  if not handled and self.handlers.state then
      handled = self.handlers.state:handle_mouse_pressed(x, y, button)
  end
  
  return handled
end

---Handles mouse release events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param button number Mouse button that was released
function InputManager:mousereleased(x, y, button)
  -- Process handlers in priority order
  local handled = false
  
  -- Priority 1: UI handler (buttons, windows, etc.)
  if not handled and self.handlers.ui then
      handled = self.handlers.ui:handle_mouse_released(x, y, button)
  end
  
  -- Priority 2: Active inventory
  if not handled and self.handlers.inventory then
      local inventory = self:get_inventory()
      if inventory and inventory.visible then
          handled = self.handlers.inventory:handle_mouse_released(x, y, button)
      end
  end
  
  -- Priority 3: Active grid
  if not handled and self.handlers.grid then
      local grid = self:get_grid()
      if grid and grid.visible then
          handled = self.handlers.grid:handle_mouse_released(x, y, button)
      end
  end
  
  -- Priority 4: Game state handler
  if not handled and self.handlers.state then
      handled = self.handlers.state:handle_mouse_released(x, y, button)
  end
  
  return handled
end

---Handles mouse move events
---@param x number Mouse X position
---@param y number Mouse Y position 
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
function InputManager:mousemoved(x, y, dx, dy)
  -- First handle UI through UI handler
  if self.handlers.ui:handle_mouse_moved(x, y, dx, dy) then
    return true
  end
  
  -- Then handle game state specific input
  if self.handlers.state and self.handlers.state:handle_mouse_moved(x, y, dx, dy) then
    return true
  end
  
  return false
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

---Sets key bindings
---@param bindings table Key bindings to set
function InputManager:set_bindings(bindings)
  self.bindings:set_bindings(bindings)
end

---Gets the inventory from the game state
---@return table|nil The inventory or nil if not found
function InputManager:get_inventory()
  if self.game_state and self.game_state.components and self.game_state.components.inventory then
    return self.game_state.components.inventory
  end
  return nil
end

---Gets the grid from the game state
---@return table|nil The grid or nil if not found
function InputManager:get_grid()
  if self.game_state and self.game_state.components and self.game_state.components.modular_grid then
    return self.game_state.components.modular_grid
  end
  return nil
end

return InputManager 