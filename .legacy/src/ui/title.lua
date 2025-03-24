local love = require("love")

local Title = {}

-- Draw the game title with shadow effects
function Title:draw(text, x, y, options)
    options = options or {}
    local fontSize = options.fontSize or 28
    local color = options.color or {0.9, 0.7, 0.2} -- Default golden color for alchemy theme
    local shadowColor = options.shadowColor or {0, 0, 0, 0.7}
    local offsetX = options.offsetX or 1
    local offsetY = options.offsetY or 1
    
    -- Create the font
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    -- Draw shadow
    love.graphics.setColor(shadowColor)
    love.graphics.print(text, x + offsetX, y + offsetY)
    
    -- Draw title with color
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

return Title 