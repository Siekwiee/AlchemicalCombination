local love = require("love")
local MainMenu = require("src.modes.main-menu")
local SettingsMenu = require("src.modes.settings-menu")
local CombinationGrid = require("src.data.combination-grid")
local Visualization = require("src.visualization.init")
local UIRenderer = require("src.ui.renderer")
local InputHandler = require("src.gamestate.input_handler")

---@class GameState
---@field deltaTime number
---@field totalTime number
---@field currentState string
---@field modes table
---@field combinationGrid CombinationGrid
---@field visualization Visualization
---@field uiRenderer UIRenderer
---@field inputHandler InputHandler
---@field selectedInventoryItem string|nil
---@field gridX number
---@field gridY number
---@field inventoryX number
---@field inventoryY number
---@field inventoryWidth number
---@field inventoryHeight number
local GameState = {}

---Creates a new GameState instance
---@return GameState
function GameState:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize time tracking
    o.totalTime = 0
    o.deltaTime = 0
    
    -- Initialize modes table
    o.modes = {}
    
    -- Create game systems
    o.combinationGrid = CombinationGrid:new(3, 3)
    o.visualization = Visualization:new()
    o.uiRenderer = UIRenderer:new()
    o.inputHandler = InputHandler:new()
    
    -- UI state
    o.selectedInventoryItem = nil
    
    -- Initial game state
    o.currentState = "menu"
    
    -- Initialize immediately
    o:init()
    
    return o
end

-- Initialize the game state
function GameState:init()
    -- Create menu instances
    self.modes.menu = MainMenu:new()
    self.modes.options = SettingsMenu:new()
    
    -- Initialize all modes
    self.modes.menu:init()
    self.modes.options:init()
end

-- Ensure menu is initialized
function GameState:ensureMenuInitialized()
    if not self.modes.menu then
        self.modes.menu = MainMenu:new()
        self.modes.menu:init()
    end
end

-- Ensure options menu is initialized
function GameState:ensureOptionsInitialized()
    if not self.modes.options then
        self.modes.options = SettingsMenu:new()
        self.modes.options:init()
    end
end

-- Update game state
function GameState:update(dt)
    self.deltaTime = dt
    self.totalTime = self.totalTime + dt

    if self.currentState == "menu" then
        self:ensureMenuInitialized()
        self.modes.menu:update(dt)
    elseif self.currentState == "playing" then
        -- Update game systems
        self.combinationGrid:update(dt)
        self.visualization:update(dt)
    elseif self.currentState == "options" then
        self:ensureOptionsInitialized()
        self.modes.options:update(dt)
    end
end

-- Draw current state
function GameState:draw()
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Draw based on current state
    if self.currentState == "menu" then
        self:ensureMenuInitialized()
        self.modes.menu:draw()
    elseif self.currentState == "options" then
        self:ensureOptionsInitialized()
        self.modes.options:draw()
    elseif self.currentState == "playing" then
        -- Use UI renderer to draw the game UI
        self.uiRenderer:drawGameUI(self)
    end
end

-- Handle keyboard events
function GameState:keypressed(key, scancode, isrepeat)
    self.inputHandler:handleKeyPress(self, key, scancode, isrepeat)
end

-- Handle mouse press events
function GameState:mousepressed(x, y, button)
    self.inputHandler:handleMousePress(self, x, y, button)
end

-- Handle mouse release events
function GameState:mousereleased(x, y, button)
    self.inputHandler:handleMouseRelease(self, x, y, button)
end

-- Handle window resize
function GameState:resize(w, h)
    -- Update positioning if needed
end

-- Clean up resources
function GameState:quit()
    -- Perform any necessary cleanup
    if self.visualization then
        self.visualization:clear()
    end
end

-- Reset game state
function GameState:reset()
    self.deltaTime = 0
    self.totalTime = 0
    self.currentState = "menu"
    self.combinationGrid = CombinationGrid:new(3, 3)
    self.selectedInventoryItem = nil
    if self.visualization then
        self.visualization:clear()
    end
end

-- Get current state data
function GameState:getState()
    return {
        deltaTime = self.deltaTime,
        totalTime = self.totalTime,
        currentState = self.currentState
    }
end

return GameState 