local EffectsManager = require("src.visualization.effects.init")

---@class Visualization
---@field effects EffectsManager
---@field new fun(self: Visualization): Visualization
---@field update fun(self: Visualization, dt: number)
---@field draw fun(self: Visualization)
---@field showCombination fun(self: Visualization, x: number, y: number, elementType1: string, elementType2: string, resultType: string)
---@field showElement fun(self: Visualization, x: number, y: number, elementType: string)
---@field showSell fun(self: Visualization, x: number, y: number, amount: number)
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
function Visualization:showCombination(x, y, elementType1, elementType2, resultType)
    -- Show combination flash
    self.effects:createCombinationEffect(x, y, 0.7)
    
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
end

-- Clear all visual effects
function Visualization:clear()
    self.effects:clear()
end

return Visualization 