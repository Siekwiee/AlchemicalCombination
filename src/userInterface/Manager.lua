local UIManager = {}
UIManager.__index = UIManager

---@class UIManager
---@field game_state GameState
---@field elements table<string, UIElement>
---@field new fun(game_state: GameState): UIManager
---@field update fun(self: UIManager, dt: number)
---@field draw fun(self: UIManager)
---@field handle_input fun(self: UIManager, x: number, y: number, button: number)
function UIManager:new(game_state)
  local self = setmetatable({}, self)
  self.game_state = game_state
  self.state_name = game_state.state_name
  self.elements = {}
  -- Initialize UI elements
  self:init_elements()
  
  return self
end

function UIManager:init_elements()
  -- Load UI elements
  local Button = require("src.userInterface.components.button.init")

  self.elements.menu_buttons = self.game_state.ui_buttons
  
  -- Load modular grid if it exists in game state
  if self.game_state and self.game_state.components and self.game_state.components.modular_grid then
    self.elements.modular_grid = self.game_state.components.modular_grid
  end
  
  -- Load inventory if it exists in game state
  if self.game_state and self.game_state.components and self.game_state.components.inventory then
    self.elements.inventory = self.game_state.components.inventory
  end
end

function UIManager:update(dt)
  -- Update all UI elements
  for _, element in pairs(self.elements) do
    if element.update then
      element:update(dt)
    end
  end
end

function UIManager:draw()
  -- Draw all UI elements
  if self.elements and self.elements.menu_buttons then
    for _, button in ipairs(self.elements.menu_buttons) do
      if button.draw then
        button:draw()
      end
    end
  end
  
  -- Draw modular grid
  if self.elements.modular_grid and self.elements.modular_grid.draw then
    self.elements.modular_grid:draw()
  end
  
  -- Draw inventory (on top of everything else)
  if self.elements.inventory and self.elements.inventory.draw then
    self.elements.inventory:draw()
  end
end

function UIManager:handle_mouse_pressed(x, y, button)
  print("[DEBUG][UIManager:handle_mouse_pressed] Called.") -- DEBUG
  -- Handle inventory first if it exists and is visible
  if self.elements.inventory and 
     self.elements.inventory.visible and 
     self.elements.inventory.handle_mouse_pressed then
     print("[DEBUG][UIManager:handle_mouse_pressed] Checking inventory...") -- DEBUG
     local handled_inventory = self.elements.inventory:handle_mouse_pressed(x, y, button)
     if handled_inventory then
       print("[DEBUG][UIManager:handle_mouse_pressed] Inventory handled click. Returning true.") -- DEBUG
       return true
     end
     print("[DEBUG][UIManager:handle_mouse_pressed] Inventory did not handle click.") -- DEBUG
  end
  
  -- Handle modular grid if inventory didn't handle it
  if self.elements.modular_grid and self.elements.modular_grid.handle_mouse_pressed then
    print("[DEBUG][UIManager:handle_mouse_pressed] Checking modular grid (UIModularGrid)...") -- DEBUG
    local handled_grid = self.elements.modular_grid:handle_mouse_pressed(x, y, button)
    if handled_grid then
      print("[DEBUG][UIManager:handle_mouse_pressed] Modular grid (UIModularGrid) handled click. Returning true.") -- DEBUG
      return true
    end
    print("[DEBUG][UIManager:handle_mouse_pressed] Modular grid (UIModularGrid) did not handle click.") -- DEBUG
  end
  
  -- Handle mouse input for other UI elements
  print("[DEBUG][UIManager:handle_mouse_pressed] Checking other UI elements...") -- DEBUG
  for name, element in pairs(self.elements) do
    if name ~= "modular_grid" and 
       name ~= "inventory" and 
       element.check_click then 
       print("[DEBUG][UIManager:handle_mouse_pressed] Checking element: " .. name) -- DEBUG
       local handled_other = element:check_click(x, y, button)
       if handled_other then
         print("[DEBUG][UIManager:handle_mouse_pressed] Element '" .. name .. "' handled click. Returning true.") -- DEBUG
         return true -- Input was handled by UI
       end
    end
  end
  
  print("[DEBUG][UIManager:handle_mouse_pressed] No UI element handled click. Returning false.") -- DEBUG
  return false -- Input was not handled by UI
end

function UIManager:handle_mouse_released(x, y, button)
  -- Handle modular grid first if it exists
  if self.elements.modular_grid and self.elements.modular_grid.handle_mouse_released then
    if self.elements.modular_grid:handle_mouse_released(x, y, button) then
      return true
    end
  end
  
  -- Handle mouse release for other UI elements
  for name, element in pairs(self.elements) do
    if name ~= "modular_grid" and element.handle_mouse_released and element:handle_mouse_released(x, y, button) then
      return true
    end
  end
  
  return false
end

function UIManager:handle_mouse_moved(x, y, dx, dy)
  -- Update hover state for all elements
  local handled = false
  
  for name, element in pairs(self.elements) do
    if element.handle_mouse_moved and element:handle_mouse_moved(x, y, dx, dy) then
      handled = true
    end
  end
  
  return handled
end

function UIManager:handle_wheel_moved(x, y)
  -- Handle wheel movement for all elements
  local handled = false
  
  for name, element in pairs(self.elements) do
    if element.handle_wheel_moved and element:handle_wheel_moved(x, y) then
      handled = true
    end
  end
  
  return handled
end

function UIManager:handle_input()
  -- Handle general input for all elements
  local handled = false
  
  for name, element in pairs(self.elements) do
    if element.handle_input and element:handle_input() then
      handled = true
    end
  end
  
  return handled
end

return UIManager