---@class CombinationLogic
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field combineElements fun(self: CombinationGrid, row1: number, col1: number, row2: number, col2: number): boolean Whether combination was successful
---@field getCombinationResult fun(self: CombinationGrid, element1: string, element2: string): string|nil The result element ID or nil if no result
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Whether addition was successful
local CombinationLogic = {}

---Apply this module to a CombinationGrid instance
---@param grid table The CombinationGrid instance
function CombinationLogic.applyTo(grid)
    -- Add all functions from this module to the grid
    grid.combineElements = CombinationLogic.combineElements
    grid.getCombinationResult = CombinationLogic.getCombinationResult
    grid.addElementFromInventory = CombinationLogic.addElementFromInventory
end

---Combine two elements on the grid
---@param self CombinationGrid The CombinationGrid instance
---@param row1 number First element's row
---@param col1 number First element's column
---@param row2 number Second element's row
---@param col2 number Second element's column
---@return boolean success Whether combination was successful
function CombinationLogic.combineElements(self, row1, col1, row2, col2)
    print("Attempting to combine elements")
    
    if row1 == row2 and col1 == col2 then
        print("Cannot combine with the same cell")
        return false
    end
    
    -- Get the elements being combined
    local element1 = self.grid[row1][col1]
    local element2 = self.grid[row2][col2]
    
    if not element1 or not element2 then
        print("One of the elements is nil", element1, element2)
        return false
    end
    
    -- Get the element IDs (not the objects)
    local elementId1 = element1.element
    local elementId2 = element2.element
    
    if not elementId1 or not elementId2 then
        print("One of the element IDs is missing")
        return false
    end
    
    print("Combining: " .. elementId1 .. " + " .. elementId2)
    
    -- Check combination in both possible orders
    local combinationKey1 = elementId1 .. "+" .. elementId2
    local combinationKey2 = elementId2 .. "+" .. elementId1
    
    local resultElement = self.combinations[combinationKey1] or self.combinations[combinationKey2]
    
    if resultElement then
        print("Found combination! Result: " .. resultElement)
        
        -- Remove the original elements from the grid
        self.grid[row1][col1] = nil
        self.grid[row2][col2] = nil
        
        -- Find an empty cell for the new element
        local emptyRow, emptyCol = self:findEmptyCell()
        if emptyRow and emptyCol then
            -- Place the new element in the empty cell
            self.grid[emptyRow][emptyCol] = { element = resultElement }
            print("Placed " .. resultElement .. " at cell: " .. emptyRow .. "," .. emptyCol)
            
            -- Also add to inventory
            self.inventory:addItem(resultElement, 1)
            return true
        else
            print("No empty cell found for the new element")
            -- If no empty cell, add to inventory only
            self.inventory:addItem(resultElement, 1)
            return true
        end
    else
        print("No combination found for: " .. combinationKey1 .. " or " .. combinationKey2)
        -- Debug: print available combinations
        print("Available combinations:")
        for k, v in pairs(self.combinations) do
            print(k .. " -> " .. v)
        end
        return false
    end
end

---Get the result of combining two elements
---@param self CombinationGrid The CombinationGrid instance
---@param element1 string First element ID
---@param element2 string Second element ID
---@return string|nil resultElement The result element ID or nil if no result
function CombinationLogic.getCombinationResult(self, element1, element2)
    -- Check combination in both possible orders
    local combinationKey1 = element1 .. "+" .. element2
    local combinationKey2 = element2 .. "+" .. element1
    
    local resultElement = self.combinations[combinationKey1] or self.combinations[combinationKey2]
    return resultElement
end

---Add an element from inventory to the grid
---@param self CombinationGrid The CombinationGrid instance
---@param elementName string Element ID to add
---@param row number Grid row
---@param col number Grid column
---@return boolean success Whether addition was successful
function CombinationLogic.addElementFromInventory(self, elementName, row, col)
    -- Check if the cell is empty
    if self.grid[row][col] then
        print("Cell is not empty")
        return false
    end
    
    -- Check if we have this element in inventory
    if self.inventory:getItemCount(elementName) <= 0 then
        print("No " .. elementName .. " in inventory")
        return false
    end
    
    -- Remove from inventory
    self.inventory:removeItem(elementName, 1)
    
    -- Add to grid with proper structure
    self.grid[row][col] = { element = elementName }
    print("Added " .. elementName .. " to grid at " .. row .. "," .. col)
    
    return true
end

return CombinationLogic 