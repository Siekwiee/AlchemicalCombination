local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local TextEffect = require("src.visualization.effects.text")

---@class CombinationEffect
local CombinationEffect = {}

-- Create a unified combination effect
---@param effects table The effects manager
---@param x number X position of the effect
---@param y number Y position of the effect
---@param duration number Duration of the effect
---@param isLucky boolean Optional flag to indicate if this was a lucky combination
---@param luckyItemName string|nil Optional name of the lucky item that dropped
function CombinationEffect:create(effects, x, y, duration, isLucky, luckyItemName)
    duration = duration or 0.7
    
    -- Define effect properties based on combination type
    local effectColor, effectSize, effectDuration
    
    if isLucky then
        -- Bright green for lucky combinations
        effectColor = {0.2, 0.9, 0.2, 0.9}
        effectSize = 100
        effectDuration = duration * 1.2
    else
        -- Gold for normal combinations
        effectColor = {1, 0.84, 0, 0.8}
        effectSize = 80
        effectDuration = duration
    end
    
    -- Create a flash effect for the combination
    local flash = FlashEffect:create(x, y, effectColor, effectDuration, effectSize)
    effects:addEffect(flash)
    
    -- For lucky combinations, add a secondary fade effect to enhance the visual
    if isLucky then
        -- Add a larger, more subtle green glow behind the flash
        local fade = FadeEffect:create(x, y, {0.2, 0.9, 0.2, 0.4}, effectDuration * 1.2, effectSize * 1.5)
        effects:addEffect(fade)
    end
    
    -- Add text effect if this is a lucky combination
    if isLucky and luckyItemName then
        -- Format item name for display
        local displayName = luckyItemName
        if type(luckyItemName) == "string" then
            displayName = displayName:gsub("^%l", string.upper)
        end
        
        -- Add text effect showing what was dropped
        effects:createTextEffect(
            x,             -- Center horizontally
            y - 40,        -- Position above the combination
            "Lucky! +" .. displayName,
            effectColor,
            effectDuration
        )
    end
end

return CombinationEffect 