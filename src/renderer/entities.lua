local Renderer = require("src.renderer.init")

function Renderer:drawEntities()
    --draw entities
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 100, 100)
end
