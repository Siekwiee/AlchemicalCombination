local love = require("love")

local Checkbox = {
    text = "",
    x = 0,
    y = 0,
    width = 200,
    height = 30,
    isChecked = false,
    colors = {
        box = {0.2, 0.2, 0.6},
        boxHover = {0.4, 0.4, 0.8},
        check = {0.8, 0.8, 1},
        text = {1, 1, 1}
    }
}

function Checkbox:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Checkbox:draw(isSelected)
    -- Draw checkbox text
    local textColor = self.colors.text
    love.graphics.setColor(textColor[1], textColor[2], textColor[3])
    love.graphics.print(self.text, self.x, self.y + (self.height - love.graphics.getFont():getHeight()) / 2)
    
    -- Calculate checkbox position (right-aligned)
    local boxSize = self.height - 6
    local boxX = self.x + self.width - boxSize - 5
    local boxY = self.y + 3
    
    -- Draw checkbox background
    if isSelected then
        love.graphics.setColor(self.colors.boxHover[1], self.colors.boxHover[2], self.colors.boxHover[3])
    else
        love.graphics.setColor(self.colors.box[1], self.colors.box[2], self.colors.box[3])
    end
    love.graphics.rectangle("fill", boxX, boxY, boxSize, boxSize)
    
    -- Draw checkbox border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.rectangle("line", boxX, boxY, boxSize, boxSize)
    
    -- Draw check mark if checked
    if self.isChecked then
        love.graphics.setColor(self.colors.check[1], self.colors.check[2], self.colors.check[3])
        -- Draw checkmark
        local padding = boxSize * 0.2
        love.graphics.setLineWidth(2)
        love.graphics.line(
            boxX + padding, boxY + boxSize/2,
            boxX + boxSize/2, boxY + boxSize - padding,
            boxX + boxSize - padding, boxY + padding
        )
        love.graphics.setLineWidth(1)
    end
end

function Checkbox:toggle()
    self.isChecked = not self.isChecked
    return self.isChecked
end

function Checkbox:isPointInside(x, y)
    return x >= self.x and x < self.x + self.width and
           y >= self.y and y < self.y + self.height
end

return Checkbox 