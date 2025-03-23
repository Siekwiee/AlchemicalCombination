local love = require("love")
local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local CombinationEffect = require("src.visualization.effects.combination")
local ElementEffect = require("src.visualization.effects.element")
local TextEffect = require("src.visualization.effects.text")

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
function EffectsManager:createCombinationEffect(x, y, duration, isLucky, luckyItemName)
    CombinationEffect:create(self, x, y, duration, isLucky, luckyItemName)
    return #self.activeEffects
end

-- Create an element effect
function EffectsManager:createElementEffect(x, y, elementType, duration)
    ElementEffect:create(self, x, y, elementType, duration)
    return #self.activeEffects
end

-- Create a text effect
function EffectsManager:createTextEffect(x, y, text, color, duration)
    local effect = TextEffect:create(x, y, text, color, duration)
    return self:addEffect(effect)
end

-- Update all effects
function EffectsManager:update(dt)
    local i = 1
    while i <= #self.activeEffects do
        local effect = self.activeEffects[i]
        
        if effect.update then
            -- Some effects have their own update method
            effect:update(dt)
            if effect.isComplete and effect:isComplete() then
                table.remove(self.activeEffects, i)
            else
                i = i + 1
            end
        else
            -- Simple duration-based effects
            effect.duration = effect.duration - dt
            
            if effect.duration <= 0 then
                table.remove(self.activeEffects, i)
            else
                i = i + 1
            end
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
        elseif effect.draw and not (effect.type == "flash" or effect.type == "fade") then
            -- Handle effects with their own draw method (like TextEffect)
            -- but don't double-draw flash or fade effects
            effect:draw()
        end
        
        love.graphics.setColor(originalColor)
    end
end

-- Clear all effects
function EffectsManager:clear()
    self.activeEffects = {}
end

return EffectsManager 