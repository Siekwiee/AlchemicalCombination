local love = require("love")
local json = require("src.data.json")
local Inventory = require("src.data.inventory.inventory")

---@class CombinationGrid
---@field rows number
---@field columns number
---@field grid table
---@field cellSize number
---@field margin number
---@field selectedCell table|nil
---@field elements table
---@field materialData table
---@field combinations table
---@field inventory Inventory
---@field draw fun()
---@field update fun(dt: number)
---@field handleMouseClick fun(x: number, y: number, button: number)

local CombinationGrid = {
    rows = 0,
    columns = 0,
    grid = {},
    cellSize = 120,
    margin = 10,
    selectedCell = nil,
    elements = {},
    materialData = {},
    combinations = {},
    inventory = nil
}

function CombinationGrid:new(rows, columns)
    local o = {}
    setmetatable(o, { __index = self })
    o.rows = rows or 3
    o.columns = columns or 3
    o.grid = {}
    o.cellSize = 120
    o.margin = 10
    o.selectedCell = nil
    o.materialData = {}
    o.combinations = {}
    
    -- Initialize inventory
    o.inventory = Inventory:new()
    
    -- Initialize grid
    for i = 1, o.rows do
        o.grid[i] = {}
        for j = 1, o.columns do
            o.grid[i][j] = nil
        end
    end
    
    -- Load materials from JSON
    if not o:loadMaterials() then
        error("Failed to initialize game: Could not load materials data")
    end
    
    return o
end

function CombinationGrid:loadMaterials()
    -- Check if materials file exists
    local info = love.filesystem.getInfo("src/data/materials.json")
    if not info then
        error("Error: materials.json file not found")
        return false
    end
    
    -- Load the materials data
    local contents = love.filesystem.read("src/data/materials.json")
    if not contents then
        error("Error: Could not read materials.json")
        return false
    end
    
    -- Parse JSON
    local success, jsonData = pcall(function() 
        return json.decode(contents)
    end)
    
    if not success or not jsonData then
        error("Error: Failed to parse materials.json: " .. tostring(jsonData))
        return false
    end
    
    -- Validate data structure
    if not jsonData.materials or not jsonData.combinations then
        error("Error: Invalid materials.json structure (missing materials or combinations)")
        return false
    end
    
    -- Store the data
    self.materialData = jsonData.materials
    self.combinations = jsonData.combinations
    
    -- Add starting materials to inventory
    self.inventory:addItem("fire", 3)
    self.inventory:addItem("water", 3)
    self.inventory:addItem("earth", 3)
    self.inventory:addItem("air", 3)
    
    print("Materials loaded successfully")
    return true
end

function CombinationGrid:update(dt)
    -- Update grid logic here (animations, etc.)
end

function CombinationGrid:getCellPosition(row, col)
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

function CombinationGrid:draw()
    love.graphics.setLineWidth(2)
    
    -- Draw the grid
    for i = 1, self.rows do
        for j = 1, self.columns do
            local x, y = self:getCellPosition(i, j)
            
            -- Draw cell background
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, self.cellSize, self.cellSize)
            
            -- Draw cell border
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("line", x, y, self.cellSize, self.cellSize)
            
            -- Draw element if exists
            if self.grid[i][j] and self.grid[i][j].element then
                local element = self.grid[i][j].element
                if self.elements[element] then
                    -- Draw element background
                    love.graphics.setColor(self.elements[element].color)
                    love.graphics.rectangle("fill", x + 5, y + 5, self.cellSize - 10, self.cellSize - 10)
                    
                    -- Draw element name with appropriate font size
                    love.graphics.setColor(0, 0, 0, 0.7)  -- Shadow color
                    local name = self.elements[element].name
                    local fontSize = 16
                    -- Adjust font size based on name length
                    if #name > 6 then
                        fontSize = 14
                    end
                    
                    -- Create font and draw name with shadow for better visibility
                    local font = love.graphics.newFont(fontSize)
                    love.graphics.setFont(font)
                    
                    -- Draw text shadow (offset by 1px)
                    love.graphics.printf(name, x + 11, y + self.cellSize/2 - 9, self.cellSize - 20, "center")
                    
                    -- Draw actual text in contrasting color based on background brightness
                    local r, g, b = self.elements[element].color[1], self.elements[element].color[2], self.elements[element].color[3]
                    local brightness = (r * 299 + g * 587 + b * 114) / 1000
                    if brightness > 0.5 then
                        love.graphics.setColor(0, 0, 0)  -- Dark text on bright backgrounds
                    else
                        love.graphics.setColor(1, 1, 1)  -- Light text on dark backgrounds
                    end
                    love.graphics.printf(name, x + 10, y + self.cellSize/2 - 10, self.cellSize - 20, "center")
                    
                    -- Reset to default font
                    love.graphics.setFont(love.graphics.getFont())
                end
            end
            
            -- Highlight selected cell
            if self.selectedCell and self.selectedCell.row == i and self.selectedCell.col == j then
                love.graphics.setColor(1, 1, 0, 0.3)
                love.graphics.rectangle("fill", x, y, self.cellSize, self.cellSize)
            end
        end
    end
    
    -- Draw inventory at the bottom
    self:drawInventory()
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function CombinationGrid:drawInventory()
    local screenWidth = love.graphics.getWidth()
    local itemSize = 60
    local margin = 10
    local startY = love.graphics.getHeight() - itemSize - 20
    
    -- Draw inventory background
    love.graphics.setColor(0.15, 0.15, 0.15, 0.8)
    love.graphics.rectangle("fill", 20, startY - 10, screenWidth - 40, itemSize + 20)
    
    -- Draw inventory title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Inventory", 0, startY - 35, screenWidth, "center")
    
    -- Draw inventory items
    local startX = (screenWidth - (#self:getInventoryKeys() * (itemSize + margin))) / 2
    local index = 0
    
    for elementId, count in pairs(self.inventory:getItems()) do
        if count > 0 and self.elements[elementId] then
            local x = startX + index * (itemSize + margin)
            
            -- Draw element background
            love.graphics.setColor(self.elements[elementId].color)
            love.graphics.rectangle("fill", x, startY, itemSize, itemSize)
            
            -- Draw element name (using smaller font to fit)
            local name = self.elements[elementId].name
            local fontSize = 12
            -- Adjust font size based on name length
            if #name > 6 then
                fontSize = 10
            end
            local font = love.graphics.newFont(fontSize)
            love.graphics.setFont(font)
            
            -- Draw text shadow for better visibility
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.printf(name, x + 1, startY + 11, itemSize, "center")
            
            -- Draw element name with appropriate color based on background brightness
            local r, g, b = self.elements[elementId].color[1], self.elements[elementId].color[2], self.elements[elementId].color[3]
            local brightness = (r * 299 + g * 587 + b * 114) / 1000
            if brightness > 0.5 then
                love.graphics.setColor(0, 0, 0)  -- Dark text on bright backgrounds
            else
                love.graphics.setColor(1, 1, 1)  -- Light text on dark backgrounds
            end
            love.graphics.printf(name, x, startY + 10, itemSize, "center")
            
            -- Draw count with shadow and contrasting color
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.printf(tostring(count), x + 1, startY + 36, itemSize, "center")
            love.graphics.setColor(1, 1, 1)  -- Always white for count since background is dark
            love.graphics.printf(tostring(count), x, startY + 35, itemSize, "center")
            
            index = index + 1
        end
    end
    
    -- Reset font to default
    love.graphics.setFont(love.graphics.getFont())
end

function CombinationGrid:getInventoryKeys()
    local keys = {}
    for k, v in pairs(self.inventory:getItems()) do
        if v > 0 then
            table.insert(keys, k)
        end
    end
    return keys
end

function CombinationGrid:getCellAtPosition(mouseX, mouseY)
    for i = 1, self.rows do
        for j = 1, self.columns do
            local x, y = self:getCellPosition(i, j)
            if mouseX >= x and mouseX <= x + self.cellSize and
               mouseY >= y and mouseY <= y + self.cellSize then
                return i, j
            end
        end
    end
    return nil, nil
end

function CombinationGrid:handleClick(x, y)
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
                        print("Selected element: " .. self.grid[row][col])
                    else
                        print("Clicked on empty cell")
                    end
                else
                    -- This is the second selection, try to combine
                    if self.grid[row][col] then
                        local success = self:combineElements(self.selectedCell.row, self.selectedCell.col, row, col)
                        if not success then
                            -- If combination failed, make this the new selection
                            self.selectedCell = {row = row, col = col}
                            print("Combination failed, new selection: " .. self.grid[row][col])
                        else
                            -- Reset selection after successful combination
                            self.selectedCell = nil
                        end
                    else
                        -- Clicked on empty cell, reset selection
                        self.selectedCell = nil
                        print("Selection cleared")
                    end
                end
                
                return true -- Handled click
            end
        end
    end
    
    -- If click was outside of grid, clear selection
    self.selectedCell = nil
    return false -- Click not handled by grid
end

function CombinationGrid:showInventorySelector(row, col)
    -- For now, just place the first available element from inventory
    -- In a real implementation, you would show a UI for selecting from inventory
    for elementId, count in pairs(self.inventory:getItems()) do
        if count > 0 then
            self.grid[row][col] = { element = elementId }
            self.inventory:removeItem(elementId, 1)
            break
        end
    end
end

function CombinationGrid:combineElements(row1, col1, row2, col2)
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
    
    print("Combining: " .. element1 .. " + " .. element2)
    
    -- Check combination in both possible orders
    local combinationKey1 = element1 .. "+" .. element2
    local combinationKey2 = element2 .. "+" .. element1
    
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
            self.grid[emptyRow][emptyCol] = resultElement
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

function CombinationGrid:findEmptyCell()
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

function CombinationGrid:drawGrid()
    love.graphics.setColor(1, 1, 1)
    for row = 1, self.rows do
        for col = 1, self.columns do
            -- Draw cell border
            local x = (col - 1) * (self.cellSize + self.margin) + self.margin
            local y = (row - 1) * (self.cellSize + self.margin) + self.margin
            
            -- Draw cell background
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, self.cellSize, self.cellSize)
            
            -- Draw border (highlight if cell is selected)
            if self.selectedCell and self.selectedCell.row == row and self.selectedCell.col == col then
                love.graphics.setColor(1, 1, 0) -- Yellow highlight for selected cell
                love.graphics.rectangle("line", x, y, self.cellSize, self.cellSize)
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.rectangle("line", x, y, self.cellSize, self.cellSize)
            end
            
            -- Draw element if cell is not empty
            if self.grid[row][col] then
                self:drawElement(self.grid[row][col], x, y)
            end
        end
    end
end

function CombinationGrid:drawElement(elementName, x, y)
    -- Get element data
    local elementData = self.materialData[elementName]
    if not elementData then
        print("Missing element data for: " .. elementName)
        return
    end
    
    -- Draw element background
    love.graphics.setColor(unpack(elementData.color))
    love.graphics.rectangle("fill", x + 5, y + 5, self.cellSize - 10, self.cellSize - 10)
    
    -- Calculate font size based on name length
    local fontSize = 16
    if #elementData.name > 6 then
        fontSize = 14
    end
    
    -- Create font for element name
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    -- Draw text shadow for better visibility
    love.graphics.setColor(0, 0, 0, 0.7)
    
    -- Calculate brightness of background color
    local brightness = (elementData.color[1] + elementData.color[2] + elementData.color[3]) / 3
    
    -- Draw text shadow
    love.graphics.printf(elementData.name, x + 5 + 1, y + self.cellSize/2 - fontSize/2 + 1, self.cellSize - 10, "center")
    
    -- Use light text on dark backgrounds, dark text on light backgrounds
    if brightness > 0.5 then
        love.graphics.setColor(0, 0, 0) -- Dark text
    else
        love.graphics.setColor(1, 1, 1) -- Light text
    end
    
    -- Draw the element name
    love.graphics.printf(elementData.name, x + 5, y + self.cellSize/2 - fontSize/2, self.cellSize - 10, "center")
    
    -- Reset font
    love.graphics.setFont(love.graphics.newFont(12))
end

function CombinationGrid:drawInventory(x, y, width, height)
    -- Draw inventory background
    love.graphics.setColor(0.15, 0.15, 0.15)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x, y, width, height)
    
    -- Inventory title
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.printf("Inventory", x, y + 5, width, "center")
    
    -- Calculate item size and items per row
    local itemSize = 80
    local margin = 10
    local itemsPerRow = math.floor((width - margin) / (itemSize + margin))
    
    -- Draw inventory items
    local ix = x + margin
    local iy = y + 40
    local count = 0
    
    for elementName, amount in pairs(self.inventory:getItems()) do
        -- Skip if amount is 0
        if amount <= 0 then
            goto continue
        end
        
        -- Draw element
        self:drawInventoryItem(elementName, amount, ix, iy, itemSize)
        
        -- Move to next position
        count = count + 1
        ix = ix + itemSize + margin
        
        -- Move to next row if needed
        if count % itemsPerRow == 0 then
            ix = x + margin
            iy = iy + itemSize + margin
        end
        
        ::continue::
    end
end

function CombinationGrid:drawInventoryItem(elementName, count, x, y, size)
    -- Get element data
    local elementData = self.materialData[elementName]
    if not elementData then
        print("Missing element data for inventory item: " .. elementName)
        return
    end
    
    -- Draw element background
    love.graphics.setColor(unpack(elementData.color))
    love.graphics.rectangle("fill", x, y, size, size)
    
    -- Calculate brightness of background color
    local brightness = (elementData.color[1] + elementData.color[2] + elementData.color[3]) / 3
    
    -- Calculate font size based on name length
    local fontSize = 12
    if #elementData.name > 6 then
        fontSize = 10
    end
    
    -- Create font for element name
    local font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)
    
    -- Draw name shadow
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.printf(elementData.name, x + 1, y + size/3 - fontSize/2 + 1, size, "center")
    
    -- Use light text on dark backgrounds, dark text on light backgrounds
    if brightness > 0.5 then
        love.graphics.setColor(0, 0, 0) -- Dark text
    else
        love.graphics.setColor(1, 1, 1) -- Light text
    end
    
    -- Draw the element name
    love.graphics.printf(elementData.name, x, y + size/3 - fontSize/2, size, "center")
    
    -- Draw count shadow
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.printf("x" .. count, x + 1, y + size*2/3 + 1, size, "center")
    
    -- Draw count (always white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("x" .. count, x, y + size*2/3, size, "center")
    
    -- Reset font
    love.graphics.setFont(love.graphics.newFont(12))
end

function CombinationGrid:addElementFromInventory(elementName, row, col)
    -- Check if the cell is empty
    if self.grid[row][col] then
        print("Cell is not empty")
        return false
    end
    
    -- Check if we have this element in inventory
    if not self.inventory:getItemCount(elementName) then
        print("No " .. elementName .. " in inventory")
        return false
    end
    
    -- Remove from inventory
    self.inventory:removeItem(elementName, 1)
    
    -- Add to grid
    self.grid[row][col] = elementName
    print("Added " .. elementName .. " to grid at " .. row .. "," .. col)
    
    return true
end

function CombinationGrid:handleInventoryClick(x, y, width, height)
    -- Calculate item size and items per row
    local itemSize = 80
    local margin = 10
    local itemsPerRow = math.floor((width - margin) / (itemSize + margin))
    
    -- Calculate inventory area
    local ix = margin
    local iy = 40
    local count = 0
    
    for elementName, amount in pairs(self.inventory:getItems()) do
        -- Skip if amount is 0
        if amount <= 0 then
            goto continue
        end
        
        -- Calculate item position
        local itemX = ix + (count % itemsPerRow) * (itemSize + margin)
        local itemY = iy + math.floor(count / itemsPerRow) * (itemSize + margin)
        
        -- Check if click is within this item
        if x >= itemX and x < itemX + itemSize and 
           y >= itemY and y < itemY + itemSize then
            print("Selected inventory item: " .. elementName)
            return elementName
        end
        
        -- Increment count
        count = count + 1
        
        ::continue::
    end
    
    return nil
end

return CombinationGrid