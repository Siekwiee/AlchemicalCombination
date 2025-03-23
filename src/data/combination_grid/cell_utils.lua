local love = require("love")

---@class CellUtils
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field getCellPosition fun(self: CombinationGrid, row: number, col: number): number, number Screen coordinates of a cell
---@field getCellAtPosition fun(self: CombinationGrid, mouseX: number, mouseY: number): number|nil, number|nil Cell coordinates or nil if none
---@field findEmptyCell fun(self: CombinationGrid): number|nil, number|nil Find coordinates of an empty cell or nil if grid is full
local CellUtils = {}

---Apply this module to a CombinationGrid instance
---@param grid CombinationGrid The CombinationGrid instance
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
    ---@type number, number
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    
    ---@type number, number
    local gridWidth = self.columns * self.cellSize + (self.columns - 1) * self.margin
    local gridHeight = self.rows * self.cellSize + (self.rows - 1) * self.margin
    
    ---@type number, number
    local startX = (screenWidth - gridWidth) / 2
    local startY = (screenHeight - gridHeight) / 2
    
    ---@type number, number
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
            ---@type number, number
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
    -- Strategy: Try to find cells in priority order for better gameplay experience
    
    -- First priority: Try center cell for better visual placement
    if self.rows >= 3 and self.columns >= 3 and not self.grid[2][2] then 
        return 2, 2 
    end
    
    -- Second priority: Try corner cells
    ---@type {row: number, col: number}[]
    local corners = {
        {row = 1, col = 1},
        {row = 1, col = self.columns},
        {row = self.rows, col = 1},
        {row = self.rows, col = self.columns}
    }
    
    for _, corner in ipairs(corners) do
        if not self.grid[corner.row][corner.col] then
            return corner.row, corner.col
        end
    end
    
    -- Last priority: Scan through all cells
    for i = 1, self.rows do
        for j = 1, self.columns do
            if not self.grid[i][j] then
                return i, j
            end
        end
    end
    
    -- No empty cells found
    return nil, nil
end

return CellUtils 