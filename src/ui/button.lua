local love = require("love")

local Button = {
    text = "",
    action = nil,
    x = 0,
    y = 0,
    width = 200,
    height = 50,
    colors = {
        normal = {0.2, 0.2, 0.6},
        hover = {0.4, 0.4, 0.8},
        text = {1, 1, 1}
    }
}

function Button:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Button:draw(isSelected)
    -- Draw button background
    if isSelected then
        local color = self.colors.hover
        love.graphics.setColor(color[1], color[2], color[3])
    else
        local color = self.colors.normal
        love.graphics.setColor(color[1], color[2], color[3])
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw button text
    local textColor = self.colors.text
    love.graphics.setColor(textColor[1], textColor[2], textColor[3])
    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text)
    local textHeight = font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    love.graphics.print(self.text, textX, textY)
end

return Button 