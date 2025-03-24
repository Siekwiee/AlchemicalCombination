local love = require("love")
local BaseEffect = require("src.visualization.effects.base_effect")

---@class TextEffect : BaseEffect
---@field text string Text to display
---@field color table RGBA color values
---@field alpha number Current alpha value
---@field scale number Current scale value
---@field offsetY number Current Y offset for movement
local TextEffect = {}
setmetatable(TextEffect, { __index = BaseEffect })

-- Create a new text effect
---@param x number X position
---@param y number Y position
---@param text string Text to display
---@param color table RGBA color values
---@param duration number Duration in seconds
---@return TextEffect
function TextEffect:create(x, y, text, color, duration)
    local params = {
        type = "text",
        x = x,
        y = y,
        duration = duration or 1.0
    }
    
    local effect = BaseEffect.create(self, params)
    effect.text = text
    effect.color = color or {1, 1, 1, 1}
    effect.alpha = 1.0
    effect.scale = 1.0
    effect.offsetY = 0
    
    return effect
end

-- Update the text effect
---@param dt number Delta time
function TextEffect:update(dt)
    -- Call the base update method first
    BaseEffect.update(self, dt)
    
    if self.complete then
        return
    end
    
    -- Calculate progress (0 to 1)
    local progress = 1 - (self.timeRemaining / self.duration)
    
    -- Fade out in the last 40% of the duration
    if progress > 0.6 then
        self.alpha = 1.0 - ((progress - 0.6) / 0.4)
    end
    
    -- Move upward
    self.offsetY = -30 * progress
    
    -- Scale effect
    if progress < 0.2 then
        -- Scale up at the start
        self.scale = 0.5 + (2.5 * progress)
    elseif progress > 0.8 then
        -- Scale down at the end
        self.scale = 1.0 - ((progress - 0.8) / 0.2) * 0.5
    else
        -- Maintain scale in the middle
        self.scale = 1.0
    end
end

-- Draw the text effect
function TextEffect:draw()
    if self.complete then
        return
    end
    
    -- Save current color
    local r, g, b, a = love.graphics.getColor()
    
    -- Set text color with current alpha
    love.graphics.setColor(
        self.color[1],
        self.color[2],
        self.color[3],
        self.color[4] * self.alpha
    )
    
    -- Store current font
    local currentFont = love.graphics.getFont()
    
    -- Set a larger font
    local fontSize = 16 * self.scale
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    -- Draw text centered at the position
    love.graphics.printf(
        self.text,
        self.x - 100,
        self.y + self.offsetY,
        200,
        "center"
    )
    
    -- Restore previous font
    love.graphics.setFont(currentFont)
    
    -- Restore previous color
    love.graphics.setColor(r, g, b, a)
end

return TextEffect 