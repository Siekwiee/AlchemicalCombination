local love = require("love")
local UI = require("src.user_interface.init")

---@class UIRenderer
---@field new fun(self: UIRenderer): UIRenderer
---@field drawGameUI fun(self: UIRenderer, gameState: GameState)
-- UI Renderer module for handling all drawing operations
local Renderer = {}

-- Initialize a new UI renderer
function Renderer:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    return instance
end

-- Draw the full game UI
function Renderer:drawGameUI(gameState)
    -- Draw title and instructions
    UI.Title:draw("Alchemy Factory", 40, 10)
    UI.Instruction:draw("Click on an element and then another to combine them", 40, 45)
    
    -- Draw gold counter if available
    if gameState.combinationGrid and gameState.combinationGrid.inventory then
        UI.GoldCounter:draw(gameState.combinationGrid.inventory:getGold())
    end
    
    -- Calculate positions
    local gridPosition = UI.GridLayout:calculatePosition(
        gameState.combinationGrid.rows,
        gameState.combinationGrid.columns,
        gameState.combinationGrid.cellSize,
        gameState.combinationGrid.margin
    )
    
    -- Save positions for interaction handling
    gameState.gridX = gridPosition.x
    gameState.gridY = gridPosition.y
    
    -- Draw the combination grid
    love.graphics.push()
    love.graphics.translate(gridPosition.x, gridPosition.y)
    gameState.combinationGrid:drawGrid()
    love.graphics.pop()
    
    -- Calculate and save inventory position
    local inventoryPosition = UI.GridLayout:calculateInventoryPosition()
    gameState.inventoryX = inventoryPosition.x
    gameState.inventoryY = inventoryPosition.y
    gameState.inventoryWidth = inventoryPosition.width
    gameState.inventoryHeight = inventoryPosition.height
    
    -- Draw the inventory
    gameState.combinationGrid:drawInventory(
        inventoryPosition.x,
        inventoryPosition.y,
        inventoryPosition.width,
        inventoryPosition.height
    )
    
    -- Draw visualization effects (only once)
    if gameState.visualization then
        gameState.visualization:draw()
    end
    
    -- Draw shop UI
    if gameState.shop then
        gameState.shop:draw()
    end
    
    -- Draw FPS counter
    UI.FPSCounter:draw(10, 10)
end

return Renderer 