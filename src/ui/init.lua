local love = require("love")

local Button = require("src.ui.button")
local Title = require("src.ui.title")
local Instruction = require("src.ui.instruction")
local FPSCounter = require("src.ui.fps_counter")
local GoldCounter = require("src.ui.gold_counter")
local GridLayout = require("src.ui.grid_layout")
local Checkbox = require("src.ui.checkbox")

local UI = {
    Button = Button,
    Title = Title,
    Instruction = Instruction,
    FPSCounter = FPSCounter,
    GoldCounter = GoldCounter,
    GridLayout = GridLayout,
    Checkbox = Checkbox
}

function UI:init()
    -- Initialize default fonts
    self.fonts = {
        large = love.graphics.newFont(24),
        normal = love.graphics.newFont(16),
        small = love.graphics.newFont(12)
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