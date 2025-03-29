local Debug = require("src.core.debug.init")
-- Remove direct import of MainMenu to break circular dependency
-- local MainMenu = require("src.gamestate.main_menu")

local InputManager = {}
InputManager.__index = InputManager


---@class InputManager
---@field new fun(game_state: GameState)
---@field keypressed fun(self: InputManager, key: string, scancode: string, isrepeat: boolean)
---@field mousepressed fun(self: InputManager, x: number, y: number, button: number)
---@field mousereleased fun(self: InputManager, x: number, y: number, button: number)
---@field mousemoved fun(self: InputManager, x: number, y: number, dx: number, dy: number)
---@field wheelmoved fun(self: InputManager, x: number, y: number)
function InputManager:new(game_state)
  local self = setmetatable({}, self)
  self.game_state = game_state

  -- Initialize mouse state
  self.mouse = {
    x = 0,
    y = 0,
    buttons = {
      pressed = {},
      released = {},
      down = {}
    },
    wheel = {
      x = 0,
      y = 0
    }
  }
  
  -- Key bindings
  self.key_bindings = {
    quit = "escape",
    inventory = "i",
    craft = "c",
    debug = "f3"
  }
  return self
end

function InputManager:update(dt)
  -- Reset one-frame input states
  self.mouse.buttons.pressed = {}
  self.mouse.buttons.released = {}
  self.mouse.wheel.x = 0
  self.mouse.wheel.y = 0
  
  -- Update mouse position
  self.mouse.x, self.mouse.y = love.mouse.getPosition()
end

function InputManager:mousepressed(x, y, button)
  -- Update mouse state
  self.mouse.buttons.pressed[button] = true
  self.mouse.buttons.down[button] = true
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_pressed(x, y, button) then
    return -- UI handled the input
  end
  
  -- Otherwise, forward to appropriate state handler
  self:handle_mouse_pressed(x, y, button)
end

function InputManager:mousereleased(x, y, button)
  -- Update mouse state
  self.mouse.buttons.released[button] = true
  self.mouse.buttons.down[button] = false
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_released(x, y, button) then
    return -- UI handled the input
  end
  
  -- Handle state-specific release
  if self.game_state.current_state then
    if self.game_state.current_state.state_name == "playing" then
      self:handle_mouse_released_playing(x, y, button)
    elseif self.game_state.current_state.state_name == "menu" then
      self:handle_mouse_released_main_menu(x, y, button)
    end
  end
end

function InputManager:mousemoved(x, y, dx, dy)
  -- Update mouse position
  self.mouse.x = x
  self.mouse.y = y
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_moved(x, y, dx, dy) then
    return -- UI handled the input
  end
  
  -- Handle state-specific movement
  if self.game_state.current_state then
    if self.game_state.current_state.state_name == "playing" then
      self:handle_mouse_moved_playing(x, y, dx, dy)
    end
  end
end

function InputManager:wheelmoved(x, y)
  -- Update mouse wheel state
  self.mouse.wheel.x = x
  self.mouse.wheel.y = y
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_wheel_moved(x, y) then
    return -- UI handled the input
  end
end

function InputManager:keypressed(key, scancode, isrepeat)
  -- Check for game control keys first
  if key == self.key_bindings.quit then
    love.event.quit()
    return
  end
  
  if key == self.key_bindings.debug then
    if self.game_state.components.debug then
      self.game_state.components.debug:toggle()
    end
    return
  end
  
  -- Forward to UI manager first
  if self.game_state.ui_manager:handle_input() then
    return -- UI handled the input
  end
  
  -- Handle other gameplay keys
  if key == self.key_bindings.inventory then
    -- Toggle inventory
    if self.game_state.components.inventory then
      self.game_state.components.inventory:toggle()
    end
  elseif key == self.key_bindings.craft then
    -- Open crafting menu
    if self.game_state.components.crafting then
      self.game_state.components.crafting:open_menu()
    end
  end
end

function InputManager:handle_mouse_pressed(x, y, button)
  -- Forward to UI manager first
  self.game_state.debug:debug("handle_mouse_pressed")

  if self.game_state.current_state and self.game_state.current_state.state_name == "menu" then
    self:handle_mouse_pressed_main_menu(x, y, button)
  end
end

function InputManager:handle_mouse_pressed_playing(x, y, button)
  self.game_state.debug:debug("handle_mouse_pressed_playing ")
end

function InputManager:handle_mouse_pressed_main_menu(x, y, button)
    -- Only handle left mouse button
    if button ~= 1 then return nil end
    local ui_buttons = self.game_state.current_state.ui_buttons
    -- Check if any button was clicked
    for _, ui_button in ipairs(self.game_state.current_state.ui_buttons) do
      if ui_button:check_click(x, y, button) then
        ui_button.on_click()
      end
    end
end

function InputManager:handle_mouse_released_playing(x, y, button)
  self.game_state.debug:debug("handle_mouse_released_playing")
end

function InputManager:handle_mouse_released_main_menu(x, y, button)
  self.game_state.debug:debug("handle_mouse_released_main_menu")
end

function InputManager:handle_mouse_moved_playing(x, y, dx, dy)
  self.game_state.debug:debug("handle_mouse_moved_playing")
end

return InputManager