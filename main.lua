-- Main entry point for Alchemical Combinations game
-- Uses gamestate pattern for managing different game states

-- Import required modules
local GameState = require("src.gamestate")
local MainMenu = require("src.gamestate.main_menu")
local PlayingState = require("src.gamestate.playing")
local SettingsState = require("src.gamestate.settings")

-- Global state variables
local current_state = nil
local game_states = {}
local should_close = false

-- LÖVE2D callbacks

function love.load()
  -- Initialize game states
  game_states = {
    main_menu = MainMenu:new()
  }
  
  -- Start with main menu
  current_state = game_states.main_menu
  
  -- Initialize random seed
  math.randomseed(os.time())
  
  -- Setup global event listeners
  love.keyboard.setKeyRepeat(false)
end

function love.update(dt)
  -- Cap delta time to avoid physics/logic issues on lag spikes
  local capped_dt = math.min(dt, 0.1)
  
  -- Update current game state
  if current_state and current_state.update then
    current_state:update(capped_dt)
  end
end

function love.draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.1)
  
  -- Draw current game state
  if current_state and current_state.draw then
    current_state:draw()
  end
  
  -- Debug overlay if enabled
  if game_states.playing and game_states.playing.components and 
     game_states.playing.components.debug and
     game_states.playing.components.debug.is_enabled then
    game_states.playing.components.debug:draw()
  end
end

function love.keypressed(key, scancode, isrepeat)
  -- Global keyboard shortcuts
  if key == "escape" then
    if current_state == game_states.main_menu then
      should_close = true
      love.event.quit()
    else
      -- Return to main menu from other states
      current_state = game_states.main_menu
    end
  end
  
  -- Forward to current state
  if current_state and current_state.keypressed then
    current_state:keypressed(key, scancode, isrepeat)
  end
end

function love.mousepressed(x, y, button)
  -- Forward to current state
  if current_state and current_state.mousepressed then
    current_state:mousepressed(x, y, button)
  end
end

function love.mousereleased(x, y, button)
  -- Forward to current state
  if current_state and current_state.mousereleased then
    current_state:mousereleased(x, y, button)
  end
end

function love.quit()
  -- Allow current state to handle cleanup
  if current_state and current_state.quit then
    current_state:quit()
  end
  
  return should_close
end