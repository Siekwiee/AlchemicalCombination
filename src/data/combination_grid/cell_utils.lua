local love = require("love")

---@class CellUtils
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field getCellPosition fun(self: CombinationGrid, row: number, col: number): number, number Screen coordinates of a cell
local CellUtils = {}

---Apply this module to a CombinationGrid instance
---@param grid table The CombinationGrid instance
function CellUtils.applyTo(grid)
    -- Add all functions from this module to the grid
    grid.getCellPosition = CellUtils.getCellPosition
    grid.getCellAtPosition = CellUtils.getCellAtPosition
    grid.findEmptyCell = CellUtils.findEmptyCell
end

---Get screen position of a cell
---@param self CombinationGrid The CombinationGrid instance
---@param row number Grid row
---@param col number Grid column
---@return number x, number y Screen coordinates
function CellUtils.getCellPosition(self, row, col)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    local gridWidth = self.columns * self.cellSize + (self.columns - 1) * self.margin
    local gridHeight = self.rows * self.cellSize + (self.rows - 1) * self.margin
    
    local startX = (screenWidth - gridWidth) / 2
    local startY = (screenHeight - gridHeight) / 2
    
    local x = startX + (col - 1) * (self.cellSize + self.margin)
    local y = startY + (row - 1) * (self.cellSize + self.margin)
    
    return x, y
end

---Get cell coordinates at screen position
---@param self CombinationGrid The CombinationGrid instance
---@param mouseX number Mouse X position
---@param mouseY number Mouse Y position
---@return number|nil row, number|nil col Cell coordinates or nil if none
function CellUtils.getCellAtPosition(self, mouseX, mouseY)
    for i = 1, self.rows do
        for j = 1, self.columns do
            local x, y = CellUtils.getCellPosition(self, i, j)
            if mouseX >= x and mouseX <= x + self.cellSize and
               mouseY >= y and mouseY <= y + self.cellSize then
                return i, j
            end
        end
    end
    return nil, nil
end

---Find an empty cell in the grid
---@param self CombinationGrid The CombinationGrid instance
---@return number|nil row, number|nil col Cell coordinates or nil if none
function CellUtils.findEmptyCell(self)
    -- Try middle cell first
    if not self.grid[2][2] then return 2, 2 end
    
    -- Then try other cells
    for i = 1, self.rows do
        for j = 1, self.columns do
            if not self.grid[i][j] then
                return i, j
            end
        end
    end
    
    return nil, nil
end

return CellUtils 