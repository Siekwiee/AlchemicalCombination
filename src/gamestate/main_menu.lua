local MainMenu = {}
-- Import the Button component
local Button = require("src.userInterface.components.button.init")

-- Public interface
function MainMenu:new()
  local menu = setmetatable({}, { __index = MainMenu })
  menu.state_name = "menu"
  -- Button configuration
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()
  local button_width = 200
  local button_height = 50
  local button_spacing = 20
  local start_y = window_height / 2 - 100
  
  -- Create button instances using our Button component
  menu.ui_buttons = {}
  
  -- Define button data
  menu.buttons = {
    { text = "Start Game", action = function() print("Start game clicked") end },
    { text = "Options", action = function() print("Options clicked") end },
    { text = "Exit", action = function() love.event.quit() end }
  }
  
  -- Create actual button instances
  for i, btn_data in ipairs(menu.buttons) do
    local y_pos = start_y + (i-1) * (button_height + button_spacing)
    
    menu.ui_buttons[i] = Button:new({
      x = window_width / 2 - button_width / 2,
      y = y_pos,
      width = button_width,
      height = button_height,
      text = btn_data.text,
      on_click = btn_data.action
    })
  end
  
  return menu
end

function MainMenu:update(dt)
  -- Update all buttons
  for _, button in ipairs(self.ui_buttons) do
    button:update(dt)
  end
end

function MainMenu:draw()
  -- Get window dimensions for centering
  local window_width = love.graphics.getWidth()
  local window_height = love.graphics.getHeight()
  
  -- Draw title
  love.graphics.setColor(1, 1, 1, 1)
  local title = "Main Menu"
  local font = love.graphics.getFont()
  local title_width = font:getWidth(title) * 2  -- Assuming we want the title larger
  love.graphics.print(title, window_width / 2 - title_width / 2, window_height / 4, 0, 2, 2)
  
  -- Draw all buttons
  for _, button in ipairs(self.ui_buttons) do
    button:draw()
  end
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
