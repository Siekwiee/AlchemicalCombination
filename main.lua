-- Main entry point for Alchemical Combinations game

-- Import required modules
local GameState = require("src.gamestate.init")
local MainMenu = require("src.gamestate.main_menu")
local PlayState = require("src.gamestate.play_state")
local SettingsState = require("src.gamestate.settings")
local Debug = require("src.core.debug.init")
-- Use local variables for better performance and scoping
local state
-- Make state available globally for menu transitions
_G.STATE = nil
local game_states = {}
local should_close = false


function love.load()
  -- Set default filter for crisp pixel art
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Initialize game states
  state = GameState:new()
  -- Make state available globally
  _G.STATE = state
  Debug.clear()
  -- Initialize random seed
  math.randomseed(os.time())
end

function love.update(dt)
  -- Cap delta time to avoid physics/logic issues on lag spikes
  local capped_dt = math.min(dt, 0.1)
  
  -- Update background effects
  local Background = require("src.renderer.background")
  Background:update(capped_dt)
  
  -- Update current game state
  if state and state.update then
    state:update(capped_dt)
  end
end

function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.1)
  
  -- Draw current game state
  if state and state.draw then
    state:draw()
  end
  
  -- Debug overlay if enabled
  if state and state.components and 
     state.components.debug and
     state.components.debug.is_enabled then
    state.components.debug:draw()
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- Global keyboard shortcuts
  if key == "escape" then
    if state and state.state_name == "menu" then
      should_close = true
      love.event.quit()
    else
      -- Return to main menu from other states
      state = GameState:new()
    end
  end
  
  -- Forward to current state
  if state and state.keypressed then
    state:keypressed(key, scancode, isrepeat)
  end
end

function love.mousepressed(x, y, button)
  -- Forward to current state
  if state and state.mousepressed then
    state:mousepressed(x, y, button)
  end
end

function love.mousereleased(x, y, button)
  -- Forward to current state
  if state and state.mousereleased then
    state:mousereleased(x, y, button)
  end
end

function love.quit()
  -- Allow current state to handle cleanup
  if state and state.quit then
    state:quit()
  end
  
  return should_close
end