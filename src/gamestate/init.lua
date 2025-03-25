local GameState = {}
GameState.__index = GameState

-- Import core systems
local InputManager = require("src.userInput.Manager")
local Renderer = require("src.renderer.init")
local UIManager = require("src.userInterface.Manager")

---@class GameState
---@field new fun(): GameState
---@field update fun(self: GameState, dt: number)
---@field draw fun(self: GameState)
---@field keypressed fun(self: GameState, key: string, scancode: string, isrepeat: boolean)
---@field quit fun(self: GameState)
function GameState:new()
  local self = setmetatable({}, self)
  
  -- Initialize core systems
  self.input_manager = InputManager:new(self)
  self.renderer = Renderer:new(self)
  self.ui_manager = UIManager:new(self)
  
  -- Game state variables
  self.entities = {}
  self.components = {}
  
  -- Load initial game components
  self:load_components()
  
  return self
end

function GameState:load_components()
  -- Load core gameplay components
  self.components.debug = require("src.core.debug"):new()
  -- Add more components as needed
end

function GameState:update(dt)
  -- Update all core components
  for _, component in pairs(self.components) do
    if component.update then
      component:update(dt)
    end
  end
  
  -- Update UI
  self.ui_manager:update(dt)
end

function GameState:draw()
  -- Let the renderer handle all drawing
  self.renderer:draw()
end

function GameState:keypressed(key, scancode, isrepeat)
  -- Forward to input manager
  self.input_manager:keypressed(key, scancode, isrepeat)
end

function GameState:quit()
  -- Cleanup
  for _, component in pairs(self.components) do
    if component.cleanup then
      component:cleanup()
    end
  end
end

return GameState