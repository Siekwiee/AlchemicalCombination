local love = require("love")

local Button = require("src.ui.button")

local UI = {
    Button = Button
}

function UI:init()
    -- Initialize default fonts
    self.fonts = {
        large = love.graphics.newFont(24),
        normal = love.graphics.newFont(16)
    }
end

-- Helper function to center text
function UI:centerText(text, y, font)
    font = font or love.graphics.getFont()
    local windowWidth = love.graphics.getWidth()
    local textWidth = font:getWidth(text)
    return (windowWidth - textWidth) / 2, y
end

return UI 