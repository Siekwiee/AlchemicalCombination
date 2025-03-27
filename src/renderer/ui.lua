local UiManager = require("src.userInterface.Manager")

local UI = {}

---@class UI
---@field drawUI fun(self: UI)
function UI:drawUI()
    --draw ui
    UiManager:draw()
    --draw the fps counter
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
end

return UI

