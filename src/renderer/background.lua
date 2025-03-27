local Background = {}

---@class Background
---@field drawBackground fun(self: Background)
function Background:drawBackground()
    --draw the background
    if self.game_state and self.game_state.state_name == "menu" then
        MenuBackground(self.game_state)
    end
end

function MenuBackground(game_state)
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
  for _, button in ipairs(game_state.ui_buttons) do
    button:draw()
  end
end

return Background
