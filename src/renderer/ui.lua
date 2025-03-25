local UiManager = require("src.user.interface.Manager")

local Renderer = require("src.renderer.init")

function Renderer:drawUI()
    --draw ui
    UiManager:draw()
    --draw the fps counter
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
end

return Renderer

