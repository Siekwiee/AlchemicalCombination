local Entities = {}

---@class Entities
---@field drawEntities fun(self: Entities)
function Entities:drawEntities()
    --draw entities
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 100, 100)
end

return Entities
