local FlashEffect = require("src.visualization.effects.flash")
local FadeEffect = require("src.visualization.effects.fade")

local CombinationEffect = {}

-- Create a combination effect (multiple effects combined)
function CombinationEffect:create(effects, x, y, duration)
    duration = duration or 0.7
    
    -- Purple for alchemy combinations
    local flashColor = {0.8, 0.3, 1.0, 0.8}
    local fadeColor = {1, 1, 0, 0.7} -- Yellow outer glow
    
    local flashEffect = FlashEffect:create(x, y, flashColor, duration, 80)
    local fadeEffect = FadeEffect:create(x, y, fadeColor, duration * 1.5, 120)
    
    effects:addEffect(flashEffect)
    effects:addEffect(fadeEffect)
end

return CombinationEffect 