local love = require("love")
local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local CombinationEffect = require("src.visualization.effects.combination")
local ElementEffect = require("src.visualization.effects.element")

-- Effects manager module
local EffectsManager = {}

-- Initialize a new effects manager
function EffectsManager:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    instance.activeEffects = {}
    return instance
end

-- Add an effect to the manager
function EffectsManager:addEffect(effect)
    table.insert(self.activeEffects, effect)
    return #self.activeEffects
end

-- Create a flash effect
function EffectsManager:createFlash(x, y, color, duration, size)
    local effect = FlashEffect:create(x, y, color, duration, size)
    return self:addEffect(effect)
end

-- Create a fade effect
function EffectsManager:createFade(x, y, color, duration, size)
    local effect = FadeEffect:create(x, y, color, duration, size)
    return self:addEffect(effect)
end

-- Create a combination effect
function EffectsManager:createCombinationEffect(x, y, duration)
    CombinationEffect:create(self, x, y, duration)
    return #self.activeEffects
end

-- Create an element effect
function EffectsManager:createElementEffect(x, y, elementType, duration)
    ElementEffect:create(self, x, y, elementType, duration)
    return #self.activeEffects
end

-- Update all effects
function EffectsManager:update(dt)
    local i = 1
    while i <= #self.activeEffects do
        local effect = self.activeEffects[i]
        
        effect.duration = effect.duration - dt
        
        if effect.duration <= 0 then
            table.remove(self.activeEffects, i)
        else
            i = i + 1
        end
    end
end

-- Draw all effects
function EffectsManager:draw()
    for _, effect in ipairs(self.activeEffects) do
        local originalColor = {love.graphics.getColor()}
        
        if effect.type == "flash" then
            FlashEffect:draw(effect)
        elseif effect.type == "fade" then
            FadeEffect:draw(effect)
        end
        
        love.graphics.setColor(originalColor)
    end
end

-- Clear all effects
function EffectsManager:clear()
    self.activeEffects = {}
end

return EffectsManager 