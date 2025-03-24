local love = require("love")

local GridLayout = {}

-- Calculate grid position and dimensions
function GridLayout:calculatePosition(rows, columns, cellSize, margin, options)
    options = options or {}
    
    local gridWidth = columns * (cellSize + margin) + margin
    local gridHeight = rows * (cellSize + margin) + margin
    local gridX = options.x or (love.graphics.getWidth() - gridWidth) / 2
    local gridY = options.y or 80
    
    return {
        x = gridX,
        y = gridY,
        width = gridWidth,
        height = gridHeight
    }
end

-- Calculate inventory position relative to grid or screen
function GridLayout:calculateInventoryPosition(options)
    options = options or {}
    local gridPosition = options.gridPosition
    
    local inventoryHeight = options.height or 200
    local inventoryY = love.graphics.getHeight() - inventoryHeight - 20
    local inventoryX = options.x or 10
    local inventoryWidth = options.width or (love.graphics.getWidth() - 20)
    
    return {
        x = inventoryX,
        y = inventoryY,
        width = inventoryWidth,
        height = inventoryHeight
    }
end

return GridLayout 