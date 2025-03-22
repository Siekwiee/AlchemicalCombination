local love = require("love")
local MainMenu = require("src.modes.main-menu")
local SettingsMenu = require("src.modes.settings-menu")

---@class MainMenu
---@class SettingsMenu

---@class GameState
---@field deltaTime number
---@field totalTime number
---@field currentState string
---@field modes table
---@field modes.menu MainMenu
---@field modes.options SettingsMenu
local GameState = {
    -- State variables
    deltaTime = 0,
    totalTime = 0,
    currentState = "menu", -- menu, playing, options
    modes = {
        menu = nil,
        options = nil,
        -- Add other modes here as they're created
    }
}

-- Initialize the game state
function GameState:init()
    -- Create menu instances
    self.modes.menu = MainMenu:new()
    self.modes.options = SettingsMenu:new()
    
    -- Initialize all modes
    self.modes.menu:init()
    self.modes.options:init()
end

-- Update game state
function GameState:update(dt)
    self.deltaTime = dt
    self.totalTime = self.totalTime + dt

    if self.currentState == "menu" then
        if not self.modes.menu then
            self.modes.menu = MainMenu:new()
            self.modes.menu:init()
        end
        self.modes.menu:update(dt)
    elseif self.currentState == "playing" then
        -- Update game logic here
    elseif self.currentState == "options" then
        if not self.modes.options then
            self.modes.options = SettingsMenu:new()
            self.modes.options:init()
        end
        self.modes.options:update(dt)
    end
end

-- Draw current state
function GameState:draw()
    if self.currentState == "menu" then
        if not self.modes.menu then
            self.modes.menu = MainMenu:new()
            self.modes.menu:init()
        end
        self.modes.menu:draw()
    elseif self.currentState == "playing" then
        -- Draw game here
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Game Running...", 10, 10)
    elseif self.currentState == "options" then
        if not self.modes.options then
            self.modes.options = SettingsMenu:new()
            self.modes.options:init()
        end
        self.modes.options:draw()
    end
end

-- Handle key events
function GameState:handleKeyPress(key)
    if self.currentState == "menu" then
        if not self.modes.menu then
            self.modes.menu = MainMenu:new()
            self.modes.menu:init()
        end
        
        local action = self.modes.menu:handleKeyPress(key)
        if action then
            self:handleMenuAction(action)
        end
    elseif self.currentState == "options" then
        if not self.modes.options then
            self.modes.options = SettingsMenu:new()
            self.modes.options:init()
        end
        
        local action = self.modes.options:handleKeyPress(key)
        if action and action == "back_to_menu" then
            self.currentState = "menu"
        end
    elseif key == "escape" then
        if self.currentState == "playing" then
            self.currentState = "menu"
        end
    end
end

-- Handle menu actions
function GameState:handleMenuAction(action)
    if action == "start_game" then
        self.currentState = "playing"
    elseif action == "options" then
        self.currentState = "options"
    elseif action == "exit" then
        love.event.quit()
    end
end

-- Reset game state
function GameState:reset()
    self.deltaTime = 0
    self.totalTime = 0
    self.currentState = "menu"
end

-- Get current state
function GameState:getState()
    return {
        deltaTime = self.deltaTime,
        totalTime = self.totalTime,
        currentState = self.currentState
    }
end

return GameState 