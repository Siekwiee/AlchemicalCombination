---@class EffectBridge
---@field visualizationComponent table Reference to the visualization component
---@field registerEventHandlers fun(self: EffectBridge, grid: CombinationGrid) Register event handlers
---@field onTransformationStart fun(self: EffectBridge, transform: Transformation) Handler for transformation start
---@field onTransformationProgress fun(self: EffectBridge, transform: Transformation, progress: number) Handler for transformation progress
---@field onTransformationComplete fun(self: EffectBridge, transform: Transformation) Handler for transformation complete
---@field onRandomDrop fun(self: EffectBridge, x: number, y: number, itemName: string) Handler for random drop
---@field createTransformationEffect fun(self: EffectBridge, x: number, y: number, transformType: string, resultElement: string) Create visual effect for transformations
local EffectBridge = {}

-- Initialize a new effect bridge
---@param visualizationComponent table The visualization component
---@return EffectBridge
function EffectBridge:new(visualizationComponent)
    local instance = {
        visualizationComponent = visualizationComponent
    }
    setmetatable(instance, { __index = self })
    return instance
end

-- Register event handlers with the combination grid
---@param grid CombinationGrid The combination grid
function EffectBridge:registerEventHandlers(grid)
    -- Store a reference to this bridge in the grid
    grid.effectBridge = self
    
    -- Hook up the transformation events
    local originalAddTransformation = grid.addTransformation or function() end
    local originalUpdateTransformation = grid.updateTransformations or function() end
    local originalCompleteTransformation = grid.completeTransformation or function() end
    
    -- Override the transformation functions
    grid.addTransformation = function(grid, transformation)
        -- Call original function
        originalAddTransformation(grid, transformation)
        
        -- Trigger visual effect
        self:onTransformationStart(transformation)
    end
    
    grid.updateTransformations = function(grid, dt)
        -- Call original function
        originalUpdateTransformation(grid, dt)
        
        -- Update visual effects for each transformation
        for _, transform in ipairs(grid.transformations or {}) do
            local progress = 1 - (transform.timeRemaining / transform.duration)
            self:onTransformationProgress(transform, progress)
        end
    end
    
    -- Also integrate with RandomDrops
    local RandomDrops = require("src.data.combination_effects.random_drops")
    local originalProcessDrops = RandomDrops.processDrops
    
    RandomDrops.processDrops = function(recipeResult, inventory, x, y)
        -- Call original function
        local droppedItems, hadLuckyDrop = originalProcessDrops(recipeResult, inventory, x, y)
        
        -- Trigger visual effects for each dropped item
        for _, itemName in ipairs(droppedItems) do
            self:onRandomDrop(x, y, itemName)
        end
        
        return droppedItems, hadLuckyDrop
    end
    
    print("EffectBridge: Registered event handlers with combination grid")
end

-- Handle transformation start
---@param transform Transformation The transformation
function EffectBridge:onTransformationStart(transform)
    -- Get cell position
    local grid = transform.grid
    local x, y = 0, 0
    
    if grid and grid.getCellPosition then
        x, y = grid:getCellPosition(transform.row, transform.col)
        x = x + grid.cellSize / 2
        y = y + grid.cellSize / 2
    end
    
    -- Create appropriate visual effect
    self:createTransformationEffect(x, y, transform.type, transform.resultElement)
end

-- Handle transformation progress
---@param transform Transformation The transformation
---@param progress number Progress from 0 to 1
function EffectBridge:onTransformationProgress(transform, progress)
    -- Visual pulses could be added here for long-running transformations
    -- For example, every 25% could trigger a small pulse effect
    if progress > 0 and math.floor(progress * 4) > math.floor((progress - 0.01) * 4) then
        local grid = transform.grid
        local x, y = 0, 0
        
        if grid and grid.getCellPosition then
            x, y = grid:getCellPosition(transform.row, transform.col)
            x = x + grid.cellSize / 2
            y = y + grid.cellSize / 2
        end
        
        -- Create a small pulse effect
        if self.visualizationComponent and self.visualizationComponent.effects then
            self.visualizationComponent.effects:createFade(
                x, y, 
                {1, 1, 1, 0.3}, -- Very subtle white
                0.5, -- Half second duration
                30 -- Small size
            )
        end
    end
end

-- Handle transformation complete
---@param transform Transformation The transformation
function EffectBridge:onTransformationComplete(transform)
    local grid = transform.grid
    local x, y = 0, 0
    
    if grid and grid.getCellPosition then
        x, y = grid:getCellPosition(transform.row, transform.col)
        x = x + grid.cellSize / 2
        y = y + grid.cellSize / 2
    end
    
    -- Create completion effect
    if self.visualizationComponent then
        self.visualizationComponent:showElement(x, y, transform.resultElement)
    end
end

-- Handle random drop
---@param x number X position
---@param y number Y position
---@param itemName string Name of the dropped item
function EffectBridge:onRandomDrop(x, y, itemName)
    if self.visualizationComponent then
        self.visualizationComponent:showItemDrop(x, y, itemName)
    end
end

-- Create a transformation visual effect
---@param x number X position
---@param y number Y position
---@param transformType string Type of transformation
---@param resultElement string Result element
function EffectBridge:createTransformationEffect(x, y, transformType, resultElement)
    if not self.visualizationComponent or not self.visualizationComponent.effects then
        return
    end
    
    local effects = self.visualizationComponent.effects
    
    if transformType == "seed_to_plant" then
        -- Green growth effect
        effects:createFade(x, y, {0, 0.8, 0.2, 0.5}, 1.0, 40)
    elseif transformType == "decay" then
        -- Brown decay effect
        effects:createFade(x, y, {0.6, 0.4, 0.2, 0.6}, 1.0, 40)
    else
        -- Generic transformation effect
        effects:createFade(x, y, {0.8, 0.8, 1.0, 0.4}, 0.8, 35)
    end
end

return EffectBridge 