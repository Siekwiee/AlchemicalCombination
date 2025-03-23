local love = require("love")

local FlashEffect = {}

-- Create a new flash effect
function FlashEffect:create(x, y, color, duration, size)
    return {
        type = "flash",
        x = x,
        y = y,
        color = color or {1, 1, 1, 1},
        duration = duration or 0.5,
        maxDuration = duration or 0.5,
        size = size or 50,
        active = true
    }
end

-- Draw flash effect
function FlashEffect:draw(effect)
    local progress = effect.duration / effect.maxDuration
    local color = effect.color
    local alpha = color[4] * progress
    
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    love.graphics.circle("fill", effect.x, effect.y, effect.size * (1 - progress * 0.5))
    love.graphics.circle("line", effect.x, effect.y, effect.size * (1 - progress * 0.3))
end

return FlashEffect 