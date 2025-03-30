local MainMenu = {}
-- Import the Button component
local Button = require("src.userInterface.components.button.init")
local Debug = require("src.core.debug.init")
-- Remove PlayState dependency to avoid circular dependency
-- local PlayState = require("src.gamestate.play_state")
local Renderer = require("src.renderer.init")
local InputManager = require("src.userInput.InputManager")

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
    { text = "Start Game", action = function() 
        -- Access the parent GameState and switch to play state
        if _G.STATE and _G.STATE.switch_state then
          _G.STATE:switch_state("play")
        else
          Debug.debug(Debug, "ERROR: Cannot switch state, _G.STATE not available")
        end
      end 
    },
    { text = "Options", action = function() Debug.debug(Debug, "Options clicked") end },
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
  end
  
  -- Debug log for buttons (move outside the loop)
  for _, ui_button in ipairs(self.ui_buttons) do
    Debug.debug(Debug, "MainMenu:ui_buttons " .. ui_button.text)
  end
  
  -- Create input manager for this state
  self.input_manager = InputManager:new(self)
  
  return self
end

function MainMenu:update(dt)
  -- Update input manager
  if self.input_manager then
    self.input_manager:update(dt)
  end
  
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
  Debug.debug(Debug, "MainMenu:mousepressed " .. x .. "," .. y .. " btn:" .. button)
  
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

-- Add input handling methods to properly integrate with InputManager
function MainMenu:keypressed(key, scancode, isrepeat)
  Debug.debug(Debug, "MainMenu:keypressed " .. key)
  -- Your menu-specific key handling logic here
  
  -- Forward to input manager if it exists
  if self.input_manager then
    self.input_manager:keypressed(key, scancode, isrepeat)
  end
end

function MainMenu:keyreleased(key, scancode)
  -- Forward to input manager if it exists
  if self.input_manager then
    self.input_manager:keyreleased(key, scancode)
  end
end

function MainMenu:mousereleased(x, y, button)
  -- Forward to input manager if it exists
  if self.input_manager then
    self.input_manager:mousereleased(x, y, button)
  end
end

function MainMenu:mousemoved(x, y, dx, dy)
  -- Forward to input manager if it exists
  if self.input_manager then
    self.input_manager:mousemoved(x, y, dx, dy)
  end
end

function MainMenu:wheelmoved(x, y)
  -- Forward to input manager if it exists
  if self.input_manager then
    self.input_manager:wheelmoved(x, y)
  end
end

return MainMenu
