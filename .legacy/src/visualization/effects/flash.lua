local love = require("love")
local BaseEffect = require("src.visualization.effects.base_effect")

---@class FlashEffect : BaseEffect
---@field color table RGBA color values
---@field size number Size of the flash circle
local FlashEffect = {}
setmetatable(FlashEffect, { __index = BaseEffect })

-- Create a new flash effect
---@param x number X position
---@param y number Y position
---@param color table RGBA color values
---@param duration number Duration in seconds
---@param size number Size of the flash circle
---@return FlashEffect
function FlashEffect:create(x, y, color, duration, size)
    local params = {
        type = "flash",
        x = x,
        y = y,
        duration = duration or 0.5
    }
    
    local effect = BaseEffect.create(self, params)
    effect.color = color or {1, 1, 1, 1}
    effect.size = size or 50
    
    return effect
end

-- Draw flash effect
function FlashEffect:draw()
    if self.complete then
        return
    end
    
    local progress = self.timeRemaining / self.duration
    local color = self.color
    local alpha = color[4] * progress
    
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    love.graphics.circle("fill", self.x, self.y, self.size * (1 - (1 - progress) * 0.5))
    love.graphics.circle("line", self.x, self.y, self.size * (1 - (1 - progress) * 0.3))
end

return FlashEffect 