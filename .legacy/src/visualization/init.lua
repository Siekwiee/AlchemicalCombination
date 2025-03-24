local Effects = require("src.visualization.effects.init")
local EffectBridge = require("src.data.effect_bridge")

---@class Visualization
---@field effects EffectsManager Effects manager instance
---@field effectBridge EffectBridge Bridge between gameplay effects and visual effects
---@field new fun(self: Visualization): Visualization Create a new visualization instance
---@field update fun(self: Visualization, dt: number) Update visualization state
---@field draw fun(self: Visualization) Draw visualization elements
---@field showCombination fun(self: Visualization, x: number, y: number, elementType1: string, elementType2: string, resultType: string, isLucky: boolean, luckyItemName: string|nil) Show combination effect
---@field showElement fun(self: Visualization, x: number, y: number, elementType: string) Show element effect
---@field showSell fun(self: Visualization, x: number, y: number, amount: number) Show sell effect with gold animation
---@field showItemDrop fun(self: Visualization, x: number, y: number, itemName: string) Show item drop effect with text
---@field connectToGrid fun(self: Visualization, grid: table) Connect to a combination grid
---@field clear fun(self: Visualization) Clear all active effects
-- Visualization module
local Visualization = {}

-- Initialize a new visualization instance
function Visualization:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    
    -- Create effects manager
    instance.effects = Effects.createManager()
    
    -- Create effect bridge
    instance.effectBridge = EffectBridge:new(instance)
    
    return instance
end

-- Connect to a combination grid to enable effect integration
---@param grid table The combination grid to connect to
function Visualization:connectToGrid(grid)
    if not grid then
        print("Warning: Cannot connect visualization to nil grid")
        return
    end
    
    -- Register the grid to receive visualization effects
    grid.visualization = self
    
    -- Set up the effect bridge
    if self.effectBridge then
        self.effectBridge:registerEventHandlers(grid)
    end
    
    print("Visualization connected to grid")
end

-- Update visualization
function Visualization:update(dt)
    self.effects:update(dt)
end

-- Draw visualization elements
function Visualization:draw()
    self.effects:draw()
end

-- Create a combination effect
function Visualization:showCombination(x, y, elementType1, elementType2, resultType, isLucky, luckyItemName)
    -- First show the normal combination effect
    self.effects:createElementEffect(x, y, resultType, 0.5)
    
    -- If it's a lucky combination, show the lucky effect on top
    if isLucky then
        -- Create a golden flash effect
        self.effects:createFlash(x, y, {1, 0.84, 0, 0.7}, 0.5, 40)
        
        -- Show the lucky item text if provided
        if luckyItemName then
            self.effects:createTextEffect(
                x,
                y - 20,
                "+" .. luckyItemName,
                {1, 0.84, 0, 0.9},
                1.0
            )
        end
    end
end

-- Create element specific visual effect
function Visualization:showElement(x, y, elementType)
    self.effects:createElementEffect(x, y, elementType, 0.3)
end

-- Show sell effect
function Visualization:showSell(x, y, amount)
    -- Show gold effect
    self.effects:createFlash(x, y, {1, 0.84, 0, 0.7}, 0.5, 40)
    
    -- Show amount text
    if amount and amount > 0 then
        self.effects:createTextEffect(
            x,
            y - 20,
            "+" .. amount .. " gold",
            {1, 0.84, 0, 0.9},
            1.0
        )
    end
end

-- Show item drop effect
function Visualization:showItemDrop(x, y, itemName)
    if not itemName then return end
    
    -- Format item name for display
    local displayName = itemName
    if type(itemName) == "string" then
        displayName = itemName:gsub("^%l", string.upper)
    end
    
    -- Create item drop effect
    self.effects:createTextEffect(
        x,
        y - 30,
        "+" .. displayName,
        {0.2, 0.9, 0.2, 0.9},
        1.0
    )
    
    -- Create a green flash
    self.effects:createFlash(x, y, {0.2, 0.9, 0.2, 0.7}, 0.5, 40)
end

-- Clear all effects
function Visualization:clear()
    self.effects:clear()
end

return Visualization 