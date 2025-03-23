local love = require("love")

local FadeEffect = {}

-- Create a new fade effect
function FadeEffect:create(x, y, color, duration, size)
    return {
        type = "fade",
        x = x,
        y = y,
        color = color or {1, 1, 1, 1},
        duration = duration or 1.0,
        maxDuration = duration or 1.0,
        size = size or 60,
        active = true
    }
end

-- Draw fade effect
function FadeEffect:draw(effect)
    local progress = effect.duration / effect.maxDuration
    local color = effect.color
    local alpha = color[4] * progress
    
    love.graphics.setColor(color[1], color[2], color[3], alpha)
    
    local size = effect.size * (2 - progress)
    love.graphics.circle("fill", effect.x, effect.y, size)
end

return FadeEffect 