local MainMenu = {}
-- Import the Button component
local Button = require("src.userInterface.components.button.init")
local Debug = require("src.core.debug.init")
local PlayState = require("src.gamestate.play_state")
local Renderer = require("src.renderer.init")
-- Public interface
function MainMenu:new()
  local self = setmetatable({}, { __index = self })
  self.state_name = "menu"
  -- Button configuration
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()
  local button_width = 200
  local button_height = 50
  local button_spacing = 20
  local start_y = window_height / 2 - 100
  
  -- Create button instances using our Button component
  self.ui_buttons = {}
  
  -- Define button data
  self.buttons = {
    { text = "Start Game", action = function() self.current_state = PlayState:Switchto() end },
    { text = "Options", action = function() print("Options clicked") end },
    { text = "Exit", action = function() love.event.quit() end }
  }
  
  -- Create actual button instances
  for i, btn_data in ipairs(self.buttons) do
    local y_pos = start_y + (i-1) * (button_height + button_spacing)
    
    self.ui_buttons[i] = Button:new({
      buttons = self.buttons,
      x = window_width / 2 - button_width / 2,
      y = y_pos,
      width = button_width,
      height = button_height,
      text = btn_data.text,
      on_click = btn_data.action
    })
    for _, ui_button in ipairs(self.ui_buttons) do
      Debug.debug(Debug, "MainMenu:ui_buttons " .. ui_button.text)
    end
  end
  
  return self
end

function MainMenu:update(dt)
  -- Update all buttons
  
  for _, button in ipairs(self.ui_buttons) do
    button:update(dt)
  end
end

function MainMenu:draw()
  -- init Renderer with self (the instance) instead of MainMenu (the module)
  self.renderer = Renderer:new(self)
  self.renderer:draw(self.state_name, self)
end

function MainMenu:mousepressed(x, y, button)
  if button ~= 1 then return end
  
  -- Check if any button was clicked
  for _, ui_button in ipairs(self.ui_buttons) do
    if ui_button:check_click(x, y, button) then
      -- Button handles the click event via its on_click callback
      return true
    end
  end
  
  return false
end

return MainMenu
