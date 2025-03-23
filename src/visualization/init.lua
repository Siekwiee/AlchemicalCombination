local EffectsManager = require("src.visualization.effects.init")

---@class Visualization
---@field effects EffectsManager
---@field new fun(self: Visualization): Visualization
---@field update fun(self: Visualization, dt: number)
---@field draw fun(self: Visualization)
---@field showCombination fun(self: Visualization, x: number, y: number, elementType1: string, elementType2: string, resultType: string, isLucky: boolean, luckyItemName: string|nil)
---@field showElement fun(self: Visualization, x: number, y: number, elementType: string)
---@field showSell fun(self: Visualization, x: number, y: number, amount: number)
---@field showItemDrop fun(self: Visualization, x: number, y: number, itemName: string)
---@field clear fun(self: Visualization)
-- Visualization module
local Visualization = {}

-- Initialize a new visualization instance
function Visualization:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    
    -- Create effects manager
    instance.effects = EffectsManager:new()
    
    return instance
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
    -- Show combination flash
    self.effects:createCombinationEffect(x, y, 0.7, isLucky, luckyItemName)
    
    -- Show result element effect
    if resultType then
        self.effects:createElementEffect(x, y, resultType, 0.5)
    end
end

-- Create element specific visual effect
function Visualization:showElement(x, y, elementType)
    self.effects:createElementEffect(x, y, elementType, 0.3)
end

-- Show sell effect
function Visualization:showSell(x, y, amount)
    -- Gold/coin effect
    self.effects:createFlash(x, y, {0.9, 0.7, 0.1, 0.8}, 0.4, 40) -- Gold color
    self.effects:createFade(x, y, {1, 0.9, 0.2, 0.6}, 0.6, 60)    -- Yellow fade
    
    -- Add text effect showing amount gained
    if amount and amount > 0 then
        local formattedAmount = "+" .. math.floor(amount)
        self.effects:createTextEffect(x, y - 30, formattedAmount, {1, 0.9, 0.2, 1}, 0.8)
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
    
    -- Create a green flash effect for items
    self.effects:createFlash(x, y, {0.2, 0.9, 0.2, 0.9}, 0.5, 50)
    
    -- Add text effect showing what was dropped
    self.effects:createTextEffect(
        x,           -- Center horizontally
        y - 40,      -- Position above the item
        "+" .. displayName,
        {0.2, 0.9, 0.2, 1},
        0.8
    )
end

-- Clear all visual effects
function Visualization:clear()
    self.effects:clear()
end

return Visualization 