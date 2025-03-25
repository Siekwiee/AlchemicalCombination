local InputManager = {}
InputManager.__index = InputManager

---@class InputManager
---@field new fun(game_state: GameState): InputManager
---@field keypressed fun(self: InputManager, key: string, scancode: string, isrepeat: boolean)
---@field mousepressed fun(self: InputManager, x: number, y: number, button: number)
function InputManager:new(game_state)
  local self = setmetatable({}, self)
  self.game_state = game_state
  
  -- Key bindings
  self.key_bindings = {
    quit = "escape",
    inventory = "i",
    craft = "c",
    debug = "f3"
  }
  
  return self
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

function InputManager:mousepressed(x, y, button)
  -- Forward to UI manager first
  if self.game_state.ui_manager:handle_input(x, y, button) then
    return -- UI handled the input
  end
  
  -- Handle game world clicks
  -- Handle based on current game state
end

return InputManager