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
local GameState = {}

---@return GameState
function GameState:new()
  local o = {}
  setmetatable(o, { __index = self })
  
  -- initialize time
  o.total_time = 0
  o.dt = 0
  
  o.states = {}

  -- Create game systems 
  o.debug = Debug:init(true, "DEBUG")
  --initialize gamestate
  o.current_state = MainMenu:new()

  --TODO Add UIManager
  o.renderer = Renderer:new()
  o.input_manager = InputManager:new(o)

  o:init()
  return o
end

function GameState:init()
  -- Initialize game state components
  if self.current_state and self.current_state.init then
    self.current_state:init()
  end

  self.debug:debug("GameState initialized")
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