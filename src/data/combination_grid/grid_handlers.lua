---@class GridHandlers
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field handleClick fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Whether a combination occurred, result element, centerX, centerY
---@field handleInventoryClick fun(self: CombinationGrid, x: number, y: number, width: number, height: number): string|nil Selected element or nil
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Whether the element was added
local GridHandlers = {}

---Apply this module to a CombinationGrid instance
---@param grid table The CombinationGrid instance
function GridHandlers.applyTo(grid)
    -- Add all functions from this module to the grid
    grid.handleClick = GridHandlers.handleClick
    grid.handleInventoryClick = GridHandlers.handleInventoryClick
end

---Handle a click on the grid
---@param self CombinationGrid The CombinationGrid instance
---@param x number Click X position
---@param y number Click Y position
---@return boolean combinationOccurred Whether a combination occurred
---@return string|nil resultElement The result element or nil
---@return number centerX The center X of the clicked cell
---@return number centerY The center Y of the clicked cell
function GridHandlers.handleClick(self, x, y)
    -- Calculate which grid cell was clicked
    for row = 1, self.rows do
        for col = 1, self.columns do
            local cellX = (col - 1) * (self.cellSize + self.margin) + self.margin
            local cellY = (row - 1) * (self.cellSize + self.margin) + self.margin
            
            -- Check if click is within this cell
            if x >= cellX and x < cellX + self.cellSize and 
               y >= cellY and y < cellY + self.cellSize then
                
                -- Check if this is the first selection
                if not self.selectedCell then
                    -- Only select cells with elements
                    if self.grid[row][col] then
                        self.selectedCell = {row = row, col = col}
                        print("Selected cell " .. row .. "," .. col .. " with element " .. tostring(self.grid[row][col]))
                    end
                    
                    -- Return false as no combination occurred
                    return false, nil, cellX + self.cellSize/2, cellY + self.cellSize/2
                else
                    -- This is the second selection, try to combine
                    local selectedRow = self.selectedCell.row
                    local selectedCol = self.selectedCell.col
                    
                    -- Can't combine with itself
                    if selectedRow == row and selectedCol == col then
                        self.selectedCell = nil
                        return false, nil, cellX + self.cellSize/2, cellY + self.cellSize/2
                    end
                    
                    -- Ensure both cells have elements
                    if not self.grid[selectedRow][selectedCol] or not self.grid[row][col] then
                        if not self.grid[row][col] then
                            -- If second cell is empty, move the element there
                            self.grid[row][col] = self.grid[selectedRow][selectedCol]
                            self.grid[selectedRow][selectedCol] = nil
                        end
                        
                        self.selectedCell = nil
                        return false, nil, cellX + self.cellSize/2, cellY + self.cellSize/2
                    end
                    
                    -- Try to combine the elements
                    local element1 = self.grid[selectedRow][selectedCol].element
                    local element2 = self.grid[row][col].element
                    
                    if not element1 or not element2 then
                        print("Element data is incomplete")
                        self.selectedCell = nil
                        return false, nil, cellX + self.cellSize/2, cellY + self.cellSize/2
                    end
                    
                    -- Try both ordering (element1 + element2 and element2 + element1)
                    local resultElement = self:getCombinationResult(element1, element2)
                    
                    if resultElement then
                        -- Success! Replace the elements with the result
                        self.grid[row][col] = {element = resultElement}
                        self.grid[selectedRow][selectedCol] = nil
                        
                        print("Combined " .. element1 .. " + " .. element2 .. " = " .. resultElement)
                        
                        -- Clear selection
                        self.selectedCell = nil
                        
                        -- Return true as a combination occurred, with the result element and cell center position
                        return true, resultElement, cellX + self.cellSize/2, cellY + self.cellSize/2
                    else
                        -- Invalid combination, just clear selection
                        print("Cannot combine " .. element1 .. " + " .. element2)
                        self.selectedCell = nil
                        
                        -- Return false as no combination occurred
                        return false, nil, cellX + self.cellSize/2, cellY + self.cellSize/2
                    end
                end
            end
        end
    end
    
    -- No cell was clicked
    return false, nil, x, y
end

---Handle a click on the inventory
---@param self CombinationGrid The CombinationGrid instance
---@param x number Click X position (local to inventory area)
---@param y number Click Y position (local to inventory area)
---@param width number Inventory width
---@param height number Inventory height
---@return string|nil elementName Selected element or nil
function GridHandlers.handleInventoryClick(self, x, y, width, height)
    -- Check if click is in the inventory area
    if x < 0 or x >= width or y < 0 or y >= height then
        print("Click outside inventory area")
        return nil
    end
    
    -- Rendering parameters
    local itemSize = 60
    local margin = 10
    
    -- Get inventory items with counts > 0
    local inventoryKeys = self:getInventoryKeys()
    local startX = (width - (#inventoryKeys * (itemSize + margin))) / 2
    
    -- Debug
    print("Inventory click at local: (" .. x .. "," .. y .. "), items start at x=" .. startX)
    
    local index = 0
    for elementId, count in pairs(self.inventory:getItems()) do
        if count > 0 then
            local itemX = startX + index * (itemSize + margin)
            
            -- Check if click is within this item's area
            if x >= itemX and x <= itemX + itemSize and 
               y >= 0 and y <= itemSize then
                print("Inventory click on element: " .. elementId)
                return elementId
            end
            
            index = index + 1
        end
    end
    
    print("No inventory item found at this position")
    return nil
end

---Add an element from inventory to the grid
---@param self CombinationGrid The CombinationGrid instance
---@param elementName string The element name
---@param row number The target grid row
---@param col number The target grid column
---@return boolean success Whether the element was added
function GridHandlers.addElementFromInventory(self, elementName, row, col)
    -- Check if the cell is empty
    if self.grid[row][col] then
        print("Cannot place element - cell is occupied")
        return false
    end
    
    -- Check if we have this element in inventory
    if self.inventory:getItemCount(elementName) <= 0 then
        print("Cannot place element - not in inventory")
        return false
    end
    
    -- Place the element
    self.grid[row][col] = {element = elementName}
    
    -- Remove from inventory
    self.inventory:removeItem(elementName, 1)
    
    print("Placed " .. elementName .. " from inventory to grid at " .. row .. "," .. col)
    return true
end

return GridHandlers 