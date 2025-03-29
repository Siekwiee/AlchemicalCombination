local Debug = require("src.core.debug.init")

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
  -- Initialize UI elemselfents
  Debug.debug(Debug, "UIManager:new - Creating new instance")
  self:init_elements()
  
  return self
end

function UIManager:init_elements()
  -- Load UI elements
  local Button = require("src.userInterface.components.button.init")
  Debug.debug(Debug, "UIManager:init_elements - Before setting menu_buttons")
  if self.game_state then
    Debug.debug(Debug, "UIManager:init_elements - game_state exists")
    if self.game_state.ui_buttons then
      Debug.debug(Debug, "UIManager:init_elements - Found " .. #self.game_state.ui_buttons .. " buttons")
    else
      Debug.debug(Debug, "UIManager:init_elements - No ui_buttons in game_state")
    end
  else
    Debug.debug(Debug, "UIManager:init_elements - No game_state")
  end
  self.elements.menu_buttons = self.game_state.ui_buttons
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
  Debug.debug(Debug, "UIManager:draw - Starting draw")
  if self.elements and self.elements.menu_buttons then
    Debug.debug(Debug, "UIManager:draw - Found menu_buttons, count: " .. #self.elements.menu_buttons)
    for _, button in ipairs(self.elements.menu_buttons) do
      if button.draw then
        Debug.debug(Debug, "UIManager:draw - Drawing button: " .. (button.text or "unnamed"))
        button:draw()
      else
        Debug.debug(Debug, "UIManager:draw - Button has no draw method")
      end
    end
  else
    Debug.debug(Debug, "UIManager:draw - No menu_buttons to draw")
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