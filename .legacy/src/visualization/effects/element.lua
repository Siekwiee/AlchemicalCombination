local FlashEffect = require("src.visualization.effects.flash")
local ElementColors = require("src.visualization.effects.element_colors")

local ElementEffect = {}

-- Create an element-specific effect
---@param effects table The effects manager
---@param x number X position
---@param y number Y position 
---@param elementType string Element type
---@param duration number Duration in seconds
function ElementEffect:create(effects, x, y, elementType, duration)
    duration = duration or 0.3
    
    -- Get color based on element type
    local color = ElementColors:getColor(elementType)
    
    -- Create a flash effect
    local flashEffect = FlashEffect:create(x, y, color, duration, 60)
    effects:addEffect(flashEffect)
end

return ElementEffect 