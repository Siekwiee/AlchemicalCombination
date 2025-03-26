-- Main entry point for Alchemical Combinations game

-- Import required modules
local GameState = require("src.gamestate")
local MainMenu = require("src.gamestate.main_menu")
local PlayingState = require("src.gamestate.playing")
local SettingsState = require("src.gamestate.settings")
local Debug = require("src.core.debug.init")
-- Use local variables for better performance and scoping
local gamestate
local game_states = {}
local should_close = false


function love.load()
  -- Set default filter for crisp pixel art
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Initialize game states
  gamestate = GameState:new()
  
  -- Initialize random seed
  math.randomseed(os.time())
end

function love.update(dt)
  -- Cap delta time to avoid physics/logic issues on lag spikes
  local capped_dt = math.min(dt, 0.1)
  
  -- Update current game state
  if gamestate and gamestate.update then
    gamestate:update(capped_dt)
  end
end

function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.1)
  
  -- Draw current game state
  if gamestate and gamestate.draw then
    gamestate:draw()
  end
  
  -- Debug overlay if enabled
  if gamestate and gamestate.components and 
     gamestate.components.debug and
     gamestate.components.debug.is_enabled then
    gamestate.components.debug:draw()
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- Global keyboard shortcuts
  if key == "escape" then
    if gamestate == MainMenu then
      should_close = true
      love.event.quit()
    else
      -- Return to main menu from other states
      gamestate = MainMenu
    end
  end
  
  -- Forward to current state
  if gamestate and gamestate.keypressed then
    gamestate:keypressed(key, scancode, isrepeat)
  end
end

function love.mousepressed(x, y, button)
  -- Forward to current state
  if gamestate and gamestate.mousepressed then
    gamestate:mousepressed(x, y, button)
  end
end

function love.mousereleased(x, y, button)
  -- Forward to current state
  if gamestate and gamestate.mousereleased then
    gamestate:mousereleased(x, y, button)
  end
end

function love.quit()
  -- Allow current state to handle cleanup
  if gamestate and gamestate.quit then
    gamestate:quit()
  end
  
  return should_close
end