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
  self.elements = {}
  
  -- Initialize UI elements
  self:init_elements()
  
  return self
end

function UIManager:init_elements()
  -- Load UI elements
  local Button = require("src.userInterface.components.button.init")
  
  self.elements.craft_button = Button:new({
    x = 50,
    y = 350,
    width = 120,
    height = 40,
    text = "Craft",
    on_click = function() 
      self.game_state.components.crafting:attempt_craft()
    end
  })
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
  for _, element in pairs(self.elements) do
    if element.draw then
      element:draw()
    end
  end
end

function UIManager:handle_input(x, y, button)
  -- Handle mouse input for UI elements
  for _, element in pairs(self.elements) do
    if element.check_click and element:check_click(x, y, button) then
      return true -- Input was handled by UI
    end
  end
  return false -- Input was not handled by UI
end

return UIManager