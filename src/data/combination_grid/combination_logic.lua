---@class CombinationLogic
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field combineElements fun(self: CombinationGrid, row1: number, col1: number, row2: number, col2: number): boolean Whether combination was successful
---@field getCombinationResult fun(self: CombinationGrid, element1: string, element2: string): string|nil The result element ID or nil if no result
---@field findRecipeMatch fun(self: CombinationGrid, elements: table): string|nil Find a material that matches the provided recipe elements
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Whether addition was successful
local CombinationLogic = {}

---Apply this module to a CombinationGrid instance
---@param grid table The CombinationGrid instance
function CombinationLogic.applyTo(grid)
    -- Add all functions from this module to the grid
    grid.combineElements = CombinationLogic.combineElements
    grid.getCombinationResult = CombinationLogic.getCombinationResult
    grid.findRecipeMatch = CombinationLogic.findRecipeMatch
    grid.addElementFromInventory = CombinationLogic.addElementFromInventory
end

---Find a material that matches the provided recipe elements
---@param self CombinationGrid The CombinationGrid instance
---@param elements table Map of element IDs to counts
---@return string|nil resultElement The matching material ID or nil if no match
function CombinationLogic.findRecipeMatch(self, elements)
    -- Convert elements table to sorted array for consistent comparison
    local elementPairs = {}
    local elementCount = 0
    
    for element, count in pairs(elements) do
        table.insert(elementPairs, {element = element, count = count})
        elementCount = elementCount + count
    end
    
    -- Look for matching recipes in materials
    for materialId, materialData in pairs(self.materialData) do
        -- Skip materials without recipes
        if materialData.recipe then
            -- Check if recipe matches our current elements
            local matches = true
            local recipeElementCount = 0
            
            -- Count recipe elements
            for recipeElement, recipeCount in pairs(materialData.recipe) do
                recipeElementCount = recipeElementCount + recipeCount
                local found = false
                
                -- Look for this recipe element in our element set
                for _, pair in ipairs(elementPairs) do
                    if pair.element == recipeElement and pair.count >= recipeCount then
                        found = true
                        break
                    end
                end
                
                if not found then
                    matches = false
                    break
                end
            end
            
            -- If this is an exact match (same number of elements), return it
            if matches and recipeElementCount == elementCount then
                return materialId
            end
        end
    end
    
    return nil
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
    
    -- Create a table of elements for recipe matching
    local elementSet = {}
    elementSet[elementId1] = 1
    elementSet[elementId2] = 1
    
    -- Find a material that has a recipe matching these elements
    local resultElement = self:findRecipeMatch(elementSet)
    
    if resultElement then
        print("Found matching recipe! Result: " .. resultElement)
        
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
        print("No matching recipe found for: " .. elementId1 .. " + " .. elementId2)
        return false
    end
end

---Get the result of combining two elements
---@param self CombinationGrid The CombinationGrid instance
---@param element1 string First element ID
---@param element2 string Second element ID
---@return string|nil resultElement The result element ID or nil if no result
function CombinationLogic.getCombinationResult(self, element1, element2)
    -- Create a table of elements for recipe matching
    local elementSet = {}
    elementSet[element1] = 1
    elementSet[element2] = 1
    
    -- Find a material that has a recipe matching these elements
    return self:findRecipeMatch(elementSet)
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