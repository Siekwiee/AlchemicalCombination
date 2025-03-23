local love = require("love")

local Instruction = {}

-- Draw instruction text
function Instruction:draw(text, x, y, options)
    options = options or {}
    local fontSize = options.fontSize or 16
    local color = options.color or {0.8, 0.8, 0.8}
    
    -- Create font
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    -- Draw text
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

return Instruction 