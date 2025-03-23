local love = require("love")
local MainMenu = require("src.modes.main-menu")
local SettingsMenu = require("src.modes.settings-menu")
local CombinationGrid = require("src.data.combination-grid")

---@class MainMenu
---@class SettingsMenu

---@class GameState
---@field deltaTime number
---@field totalTime number
---@field currentState string
---@field modes table
---@field modes.menu MainMenu
---@field modes.options SettingsMenu
---@field combinationGrid CombinationGrid
local GameState = {}

function GameState:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize time tracking
    o.totalTime = 0
    o.deltaTime = 0
    
    -- Create combination grid
    o.combinationGrid = CombinationGrid:new(3, 3)
    
    -- UI state
    o.selectedInventoryItem = nil
    
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
        -- Update combination grid
        if self.combinationGrid then
            self.combinationGrid:update(dt)
        end
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
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.15)
    
    -- Draw title with shadow
    love.graphics.setNewFont(28)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print("Alchemy Factory", 41, 11)
    love.graphics.setColor(0.9, 0.7, 0.2) -- Gold color for alchemy theme
    love.graphics.print("Alchemy Factory", 40, 10)
    
    -- Draw instructions
    love.graphics.setNewFont(16)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("Click on an element and then another to combine them", 40, 45)
    
    -- Calculate grid position (centered)
    local gridWidth = self.combinationGrid.columns * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin
    local gridHeight = self.combinationGrid.rows * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin
    local gridX = (love.graphics.getWidth() - gridWidth) / 2
    local gridY = 80
    
    -- Save grid position for mouse interactions
    self.gridX = gridX
    self.gridY = gridY
    
    -- Draw combination grid
    love.graphics.push()
    love.graphics.translate(gridX, gridY)
    self.combinationGrid:drawGrid()
    love.graphics.pop()
    
    -- Draw inventory (below grid)
    local inventoryX = 10
    local inventoryY = gridY + gridHeight + 20
    local inventoryWidth = love.graphics.getWidth() - 20
    local inventoryHeight = 200
    
    -- Save inventory position for mouse interactions
    self.inventoryX = inventoryX
    self.inventoryY = inventoryY
    self.inventoryWidth = inventoryWidth
    self.inventoryHeight = inventoryHeight
    
    self.combinationGrid:drawInventory(inventoryX, inventoryY, inventoryWidth, inventoryHeight)
    
    -- Draw FPS in top left
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
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

-- Handle mouse click events
function GameState:handleMouseClick(x, y, button)
    if self.currentState == "playing" and self.combinationGrid then
        self.combinationGrid:handleMouseClick(x, y, button)
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

function GameState:mousepressed(x, y, button)
    -- Check if click is in grid area
    if x >= self.gridX and x < self.gridX + (self.combinationGrid.columns * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin) and
       y >= self.gridY and y < self.gridY + (self.combinationGrid.rows * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin) then
        
        -- Convert to grid coordinates
        local gridX = x - self.gridX
        local gridY = y - self.gridY
        
        -- Handle grid click
        if button == 1 then -- Left click
            -- If we have a selected inventory item, place it
            if self.selectedInventoryItem then
                -- Calculate which cell was clicked
                for row = 1, self.combinationGrid.rows do
                    for col = 1, self.combinationGrid.columns do
                        local cellX = (col - 1) * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin
                        local cellY = (row - 1) * (self.combinationGrid.cellSize + self.combinationGrid.margin) + self.combinationGrid.margin
                        
                        if gridX >= cellX and gridX < cellX + self.combinationGrid.cellSize and
                           gridY >= cellY and gridY < cellY + self.combinationGrid.cellSize then
                            
                            -- Try to place the selected item
                            if self.combinationGrid:addElementFromInventory(self.selectedInventoryItem, row, col) then
                                self.selectedInventoryItem = nil
                            end
                            
                            return
                        end
                    end
                end
            else
                -- Try normal grid handling
                self.combinationGrid:handleClick(gridX, gridY)
            end
        elseif button == 2 then -- Right click
            -- Clear selections
            self.combinationGrid.selectedCell = nil
            self.selectedInventoryItem = nil
        end
    
    -- Check if click is in inventory area
    elseif x >= self.inventoryX and x < self.inventoryX + self.inventoryWidth and
           y >= self.inventoryY and y < self.inventoryY + self.inventoryHeight then
        
        -- Convert to inventory coordinates
        local inventoryX = x - self.inventoryX
        local inventoryY = y - self.inventoryY
        
        -- Handle inventory click
        if button == 1 then -- Left click
            local elementName = self.combinationGrid:handleInventoryClick(inventoryX, inventoryY, self.inventoryWidth, self.inventoryHeight)
            if elementName then
                self.selectedInventoryItem = elementName
            end
        elseif button == 2 then -- Right click
            -- Clear selection
            self.selectedInventoryItem = nil
        end
    else
        -- Clear selections
        self.combinationGrid.selectedCell = nil
        self.selectedInventoryItem = nil
    end
end

function GameState:mousereleased(x, y, button)
    -- Handle mouse release events
end

function GameState:keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return GameState 