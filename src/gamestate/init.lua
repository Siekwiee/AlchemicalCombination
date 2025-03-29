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
  setmetatable({}, { __index = GameState })
  
  -- initialize time
  self.total_time = 0
  self.dt = 0
  
  self.states = {}

  -- Create game systems 
  self.debug = Debug:init(true, "DEBUG")
  --initialize gamestate
  self.current_state = MainMenu:new()

  --TODO Add UIManager
  self.renderer = Renderer:new()
  self.input_manager = InputManager:new(self)

  self:init()
  return self
end

function GameState:init()
  -- Initialize game state components
  if self.current_state and self.current_state.init then
    self.current_state:init()
  end

  self.debug:debug("GameState initialized")
end

---Switch to a different game state
---@param state_name string The name of the state to switch to
---@return boolean Whether the state switch was successful
function GameState:switch_state(state_name)
  self.debug:debug("Switching to state: " .. state_name)
  
  -- Reset UI state
  if self.ui_manager then
    self.ui_manager = nil
  end
  
  -- Handle different state types
  if state_name == GameState.STATE_TYPES.MENU then
    -- We don't require MainMenu here since it would create a circular dependency
    self.current_state = MainMenu:new()
    return true
  elseif state_name == GameState.STATE_TYPES.PLAY then
    -- Lazy load the PlayState to avoid circular dependencies
    local PlayState = require("src.gamestate.play_state")
    self.current_state = PlayState:new()
    return true
  elseif state_name == GameState.STATE_TYPES.SETTINGS then
    -- Lazy load the SettingsState to avoid circular dependencies
    local SettingsState = require("src.gamestate.settings")
    self.current_state = SettingsState:new()
    return true
  end
  
  self.debug:debug("Unknown state: " .. state_name)
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
  self.input_manager:keypressed(key, scancode, isrepeat)
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