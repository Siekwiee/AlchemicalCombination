local love = require("love")

local FPSCounter = {}

-- Draw FPS counter
function FPSCounter:draw(x, y, options)
    options = options or {}
    local fontSize = options.fontSize or 12
    local color = options.color or {1, 1, 1}
    local format = options.format or "FPS: %d"
    
    -- Create font if specified
    if fontSize then
        love.graphics.setFont(love.graphics.newFont(fontSize))
    end
    
    -- Draw FPS
    love.graphics.setColor(color)
    love.graphics.print(string.format(format, love.timer.getFPS()), x, y)
end

return FPSCounter 