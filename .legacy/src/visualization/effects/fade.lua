local love = require("love")
local BaseEffect = require("src.visualization.effects.base_effect")

---@class FadeEffect : BaseEffect
---@field color table RGBA color values
---@field size number Size of the fade circle
local FadeEffect = {}
setmetatable(FadeEffect, { __index = BaseEffect })

-- Create a new fade effect
---@param x number X position
---@param y number Y position
---@param color table RGBA color values
---@param duration number Duration in seconds
---@param size number Size of the fade circle
---@return FadeEffect
function FadeEffect:create(x, y, color, duration, size)
    local params = {
        type = "fade",
        x = x,
        y = y,
        duration = duration or 1.0
    }
    
    local effect = BaseEffect.create(self, params)
    effect.color = color or {1, 1, 1, 1}
    effect.size = size or 60
    
    return effect
end

-- Draw fade effect
function FadeEffect:draw()
    if self.complete then
        return
    end
    
    local progress = self.timeRemaining / self.duration
    local color = self.color
    local alpha = color[4] * progress
    
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    
    local size = self.size * (2 - progress)
    love.graphics.circle("fill", self.x, self.y, size)
end

return FadeEffect 