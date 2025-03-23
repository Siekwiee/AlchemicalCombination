local love = require("love")

local GoldCounter = {}

-- Draw gold counter with coin icon
function GoldCounter:draw(gold, options)
    if not gold then return end
    
    options = options or {}
    local fontSize = options.fontSize or 20
    local x = options.x or (love.graphics.getWidth() - 90)
    local y = options.y or 25
    local iconRadius = options.iconRadius or 15
    local iconX = options.iconX or (x - 30)
    local iconY = options.iconY or y
    
    -- Create font
    local font = love.graphics.newFont(fontSize)
    
    -- Draw gold coin icon (circle with G)
    love.graphics.setColor(0.9, 0.7, 0.2) -- Gold color
    love.graphics.circle("fill", iconX, iconY, iconRadius)
    love.graphics.setColor(0.6, 0.4, 0.1) -- Darker gold for border
    love.graphics.circle("line", iconX, iconY, iconRadius)
    
    -- Draw 'G' in the coin
    love.graphics.setColor(0.6, 0.4, 0.1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("G", iconX - 5, iconY - 9)
    
    -- Draw amount with shadow
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.print(gold, x + 1, y - 9)
    love.graphics.setColor(1, 0.9, 0.2)
    love.graphics.print(gold, x, y - 10)
end

return GoldCounter 