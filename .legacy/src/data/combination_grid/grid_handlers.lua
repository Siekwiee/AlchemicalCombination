---@class GridHandlers
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field handleClick fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Whether a combination occurred, result element, centerX, centerY
---@field handleInventoryClick fun(self: CombinationGrid, x: number, y: number, width: number, height: number): string|nil Selected element or nil
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Whether the element was added
---@field removeElementToInventory fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Whether element was removed, element name, centerX, centerY
local GridHandlers = {}

---Apply this module to a CombinationGrid instance
---@param grid CombinationGrid The CombinationGrid instance
function GridHandlers.applyTo(grid)
    -- Add all functions from this module to the grid
    grid.handleClick = GridHandlers.handleClick
    grid.handleInventoryClick = GridHandlers.handleInventoryClick
    grid.removeElementToInventory = GridHandlers.removeElementToInventory
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
                
                -- Calculate cell center for return values
                ---@type number, number
                local centerX, centerY = cellX + self.cellSize/2, cellY + self.cellSize/2
                
                -- STEP 1: Handle first selection (select an element)
                if not self.selectedCell then
                    -- Only select cells with elements
                    if self.grid[row][col] then
                        ---@type {row: number, col: number}
                        self.selectedCell = {row = row, col = col}
                        print("Selected cell " .. row .. "," .. col .. " with element " .. tostring(self.grid[row][col].element))
                    end
                    
                    -- Return false as no combination occurred
                    return false, nil, centerX, centerY
                else
                    -- STEP 2: Handle second selection (combine elements)
                    ---@type number, number
                    local selectedRow, selectedCol = self.selectedCell.row, self.selectedCell.col
                    
                    -- Can't combine with itself
                    if selectedRow == row and selectedCol == col then
                        self.selectedCell = nil
                        return false, nil, centerX, centerY
                    end
                    
                    -- STEP 3: Ensure both cells have elements
                    ---@type GridCell|nil
                    local firstCell = self.grid[selectedRow][selectedCol]
                    ---@type GridCell|nil
                    local secondCell = self.grid[row][col]
                    
                    if not firstCell or not secondCell then
                        if not secondCell then
                            -- If second cell is empty, move the element there
                            self.grid[row][col] = self.grid[selectedRow][selectedCol]
                            self.grid[selectedRow][selectedCol] = nil
                        end
                        
                        self.selectedCell = nil
                        return false, nil, centerX, centerY
                    end
                    
                    -- STEP 4: Try to combine the elements
                    ---@type string|nil
                    local element1 = firstCell.element
                    ---@type string|nil
                    local element2 = secondCell.element
                    
                    if not element1 or not element2 then
                        print("Element data is incomplete")
                        self.selectedCell = nil
                        return false, nil, centerX, centerY
                    end
                    
                    -- STEP 5: Use the combination logic function to handle the combination
                    local success = false
                    local resultElement = nil
                    
                    -- Try using combineElements which handles special combinations
                    if self.combineElements then
                        success = self:combineElements(selectedRow, selectedCol, row, col)
                        
                        if success then
                            -- If a special combination was successful, find out what the result was
                            if self.grid[row][col] and self.grid[row][col].element then
                                resultElement = self.grid[row][col].element
                            end
                            
                            print("Combination successful: " .. element1 .. " + " .. element2)
                        end
                    else
                        -- Fallback to direct recipe matching if combineElements isn't available
                        -- Create a set of elements for recipe matching
                        ---@type {[string]: number}
                        local elementSet = {}
                        elementSet[element1] = 1
                        elementSet[element2] = 1
                        
                        -- Try to find a matching recipe
                        resultElement = self:findRecipeMatch(elementSet)
                        
                        if resultElement then
                            -- Success! Replace the elements with the result
                            ---@type GridCell
                            self.grid[row][col] = {element = resultElement}
                            self.grid[selectedRow][selectedCol] = nil
                            success = true
                            
                            print("Combined " .. element1 .. " + " .. element2 .. " = " .. resultElement)
                        end
                    end
                    
                    -- Clear selection
                    self.selectedCell = nil
                    
                    if success then
                        -- Return true as a combination occurred
                        return true, resultElement, centerX, centerY
                    else
                        -- Invalid combination, just clear selection
                        print("Cannot combine " .. element1 .. " + " .. element2 .. " - no matching recipe")
                        return false, nil, centerX, centerY
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
    ---@type number, number
    local itemSize, margin = 60, 10
    
    -- Get inventory items with counts > 0
    ---@type string[]
    local inventoryKeys = self:getInventoryKeys()
    ---@type number
    local startX = (width - (#inventoryKeys * (itemSize + margin))) / 2
    
    -- Debug
    print("Inventory click at local: (" .. x .. "," .. y .. "), items start at x=" .. startX)
    
    -- Check each inventory item
    ---@type number
    local index = 0
    ---@type {[string]: number}
    local items = self.inventory:getItems()
    
    for elementId, count in pairs(items) do
        if count > 0 then
            ---@type number
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
    ---@type number
    local itemCount = self.inventory:getItemCount(elementName)
    if itemCount <= 0 then
        print("Cannot place element - not in inventory")
        return false
    end
    
    -- Place the element
    ---@type GridCell
    self.grid[row][col] = {element = elementName}
    
    -- Remove from inventory
    self.inventory:removeItem(elementName, 1)
    
    print("Placed " .. elementName .. " from inventory to grid at " .. row .. "," .. col)
    return true
end

---Remove an element from the grid and add it to inventory
---@param self CombinationGrid The CombinationGrid instance
---@param x number Click X position
---@param y number Click Y position
---@return boolean success Whether an element was removed
---@return string|nil elementName The removed element name or nil
---@return number centerX The center X of the clicked cell
---@return number centerY The center Y of the clicked cell
function GridHandlers.removeElementToInventory(self, x, y)
    -- Calculate which grid cell was clicked
    for row = 1, self.rows do
        for col = 1, self.columns do
            ---@type number, number
            local cellX = (col - 1) * (self.cellSize + self.margin) + self.margin
            local cellY = (row - 1) * (self.cellSize + self.margin) + self.margin
            
            -- Calculate cell center for return values
            ---@type number, number
            local centerX, centerY = cellX + self.cellSize/2, cellY + self.cellSize/2
            
            -- Check if click is within this cell
            if x >= cellX and x < cellX + self.cellSize and 
               y >= cellY and y < cellY + self.cellSize then
                
                -- Check if there's an element in this cell
                ---@type GridCell|nil
                local cellData = self.grid[row][col]
                if cellData and cellData.element then
                    -- Add the element to inventory
                    self.inventory:addItem(cellData.element, 1)
                    
                    -- Get element name before removing it
                    ---@type string
                    local elementName = cellData.element
                    
                    -- Remove the element from the grid
                    self.grid[row][col] = nil
                    
                    -- Clear selection if this was the selected cell
                    if self.selectedCell and self.selectedCell.row == row and self.selectedCell.col == col then
                        self.selectedCell = nil
                    end
                    
                    print("Moved " .. elementName .. " from grid to inventory")
                    return true, elementName, centerX, centerY
                end
                
                -- Return cell center position even if no element was found
                return false, nil, centerX, centerY
            end
        end
    end
    
    -- No cell was clicked or no element was found
    return false, nil, x, y
end

return GridHandlers 