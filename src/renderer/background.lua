local Renderer = require("src.renderer.init")

function Renderer:drawBackground()
    --draw the background
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end