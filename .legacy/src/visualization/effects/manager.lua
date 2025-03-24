local love = require("love")
local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local CombinationEffect = require("src.visualization.effects.combination")
local ElementEffect = require("src.visualization.effects.element")
local TextEffect = require("src.visualization.effects.text")

---@class EffectsManager
---@field activeEffects table[] Array of active effects
local EffectsManager = {}

-- Initialize a new effects manager
---@return EffectsManager
function EffectsManager:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    instance.activeEffects = {}
    return instance
end

-- Add an effect to the manager
---@param effect table The effect to add
---@return number Index of the added effect
function EffectsManager:addEffect(effect)
    table.insert(self.activeEffects, effect)
    return #self.activeEffects
end

-- Create a flash effect
---@param x number X position
---@param y number Y position
---@param color table RGBA color values
---@param duration number Duration in seconds
---@param size number Size of the flash
---@return number Index of the added effect
function EffectsManager:createFlash(x, y, color, duration, size)
    local effect = FlashEffect:create(x, y, color, duration, size)
    return self:addEffect(effect)
end

-- Create a fade effect
---@param x number X position
---@param y number Y position
---@param color table RGBA color values
---@param duration number Duration in seconds
---@param size number Size of the fade
---@return number Index of the added effect
function EffectsManager:createFade(x, y, color, duration, size)
    local effect = FadeEffect:create(x, y, color, duration, size)
    return self:addEffect(effect)
end

-- Create a combination effect
---@param x number X position
---@param y number Y position
---@param duration number Duration in seconds
---@param isLucky boolean Whether this is a lucky combination
---@param luckyItemName string|nil Name of the lucky item if applicable
---@return number Index of the added effect
function EffectsManager:createCombinationEffect(x, y, duration, isLucky, luckyItemName)
    CombinationEffect:create(self, x, y, duration, isLucky, luckyItemName)
    return #self.activeEffects
end

-- Create an element effect
---@param x number X position
---@param y number Y position
---@param elementType string Type of element
---@param duration number Duration in seconds
---@return number Index of the added effect
function EffectsManager:createElementEffect(x, y, elementType, duration)
    ElementEffect:create(self, x, y, elementType, duration)
    return #self.activeEffects
end

-- Create a text effect
---@param x number X position
---@param y number Y position
---@param text string Text to display
---@param color table RGBA color values
---@param duration number Duration in seconds
---@return number Index of the added effect
function EffectsManager:createTextEffect(x, y, text, color, duration)
    local effect = TextEffect:create(x, y, text, color, duration)
    return self:addEffect(effect)
end

-- Update all effects
---@param dt number Delta time
function EffectsManager:update(dt)
    local i = 1
    while i <= #self.activeEffects do
        local effect = self.activeEffects[i]
        
        -- All effects now have their own update method
        effect:update(dt)
        
        if effect:isComplete() then
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
        
        -- All effects now have their own draw method
        effect:draw()
        
        love.graphics.setColor(originalColor)
    end
end

-- Clear all effects
function EffectsManager:clear()
    self.activeEffects = {}
end

return EffectsManager 