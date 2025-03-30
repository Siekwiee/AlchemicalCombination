-- Import core systems
local InputManager = require("src.userInput.Manager")
local Renderer = require("src.renderer.init")
--TODO Add UiManager
local Debug = require("src.core.debug.init")
local MainMenu = require("src.gamestate.main_menu")

---@class GameState
---@field total_time number
---@field dt number
---@field states table<string, GameState>
---@field debug Debug
---@field renderer Renderer
---@field input_manager InputManager
---@field current_state GameState
---@field switch_state fun(self: GameState, state_name: string): boolean
local GameState = {}

-- Define available state types
GameState.STATE_TYPES = {
  MENU = "menu",
  PLAY = "play",
  SETTINGS = "settings"
}

---@return GameState
function GameState:new()
  local instance = {}
  setmetatable(instance, { __index = GameState })
  
  -- initialize time
  instance.total_time = 0
  instance.dt = 0
  
  instance.states = {}

  -- Create game systems 
  instance.debug = Debug
  -- Create input manager first so it can be provided to states
  instance.input_manager = InputManager:new(instance)

  -- Initialize renderer
  instance.renderer = Renderer:new()

  -- Create initial state (main menu)
  instance.current_state = MainMenu:new()

  instance:init()
  return instance
end

function GameState:init()
  -- Initialize game state components
  if self.current_state and self.current_state.init then
    self.current_state:init()
  end

  Debug.debug(Debug, "GameState initialized")
end

---Switch to a different game state
---@param state_name string The name of the state to switch to
---@return boolean Whether the state switch was successful
function GameState:switch_state(state_name)
  Debug.debug(Debug, "Switching to state: " .. state_name)
  
  -- Reset UI state
  if self.ui_manager then
    self.ui_manager = nil
  end
  
  -- Store current input manager to reuse
  local input_manager = self.input_manager
  
  -- Handle different state types
  if state_name == GameState.STATE_TYPES.MENU then
    -- We don't require MainMenu here since it would create a circular dependency
    self.current_state = MainMenu:new()
    return true
  elseif state_name == GameState.STATE_TYPES.PLAY then
    -- Lazy load the PlayState to avoid circular dependencies
    local PlayState = require("src.gamestate.play_state")
    self.current_state = PlayState:new()
    -- Set the global input manager on the new state
    if not self.current_state.input_manager and input_manager then
      self.current_state.input_manager = input_manager
    end
    return true
  elseif state_name == GameState.STATE_TYPES.SETTINGS then
    -- Lazy load the SettingsState to avoid circular dependencies
    local SettingsState = require("src.gamestate.settings")
    self.current_state = SettingsState:new()
    return true
  end
  
  Debug.debug(Debug, "Unknown state: " .. state_name)
  return false
end

function GameState:update(dt)
  self.total_time = self.total_time + dt
  self.dt = dt
  if self.current_state and self.current_state.update then
    self.current_state:update(dt)
  end
end

function GameState:draw()
  -- Clear screen
  love.graphics.clear(0.1, 0.1, 0.15)
  if self.current_state and self.current_state.draw then
    self.current_state:draw()
  end
end

function GameState:keypressed(key, scancode, isrepeat)
  -- Forward keypressed to input manager
  Debug.debug(Debug, "GameState:keypressed - Key: " .. tostring(key))
  
  if self.input_manager then
    self.input_manager:keypressed(key, scancode, isrepeat)
  end
  
  -- Also forward to current state if it has a keypressed method
  if self.current_state and self.current_state.keypressed then
    self.current_state:keypressed(key, scancode, isrepeat)
  end
end

function GameState:mousepressed(x, y, button)
  self.input_manager:mousepressed(x, y, button)
end

function GameState:mousereleased(x, y, button)
  self.input_manager:mousereleased(x, y, button)
end

function GameState:mousemoved(x, y, dx, dy)
  self.input_manager:mousemoved(x, y, dx, dy)
end

return GameState