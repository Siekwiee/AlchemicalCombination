local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")
local TextEffect = require("src.visualization.effects.text")

local CombinationEffect = {}

-- Create a unified combination effect
-- @param effects The effects manager
-- @param x X position of the effect
-- @param y Y position of the effect
-- @param duration Duration of the effect
-- @param isLucky Optional flag to indicate if this was a lucky combination
-- @param luckyItemName Optional name of the lucky item that dropped
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
    
    -- Create a single main flash effect
    local flash = FlashEffect:create(x, y, effectColor, effectDuration, effectSize)
    effects:addEffect(flash)
    
    -- Add text effect if this is a lucky combination
    if isLucky and luckyItemName then
        -- Format item name for display
        local displayName = luckyItemName
        if type(luckyItemName) == "string" then
            displayName = luckyItemName:gsub("^%l", string.upper)
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