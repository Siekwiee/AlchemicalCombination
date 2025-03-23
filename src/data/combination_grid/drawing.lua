local love = require("love")

-- Use the global unpack function (for Lua 5.1)
---@diagnostic disable-next-line: deprecated
local unpack = unpack

---@class Drawing
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field draw fun(self: CombinationGrid) Draw the entire combination grid
---@field drawGrid fun(self: CombinationGrid) Draw the grid structure
---@field drawElement fun(self: CombinationGrid, elementName: string, x: number, y: number) Draw a single element
---@field drawInventory fun(self: CombinationGrid, x: number, y: number, width: number, height: number) Draw the inventory interface
---@field drawInventoryItem fun(self: CombinationGrid, elementName: string, count: number, x: number, y: number, size: number) Draw a single inventory item
local Drawing = {}

---Apply this module to a CombinationGrid instance
---@param grid table The CombinationGrid instance
function Drawing.applyTo(grid)
    -- Add all drawing functions from this module to the grid
    grid.draw = Drawing.draw
    grid.drawGrid = Drawing.drawGrid
    grid.drawElement = Drawing.drawElement
    grid.drawInventory = Drawing.drawInventory
    grid.drawInventoryItem = Drawing.drawInventoryItem
end

---Draw the entire combination grid with elements and inventory
---@param self CombinationGrid The CombinationGrid instance
function Drawing.draw(self)
    -- First draw the grid
    self:drawGrid()
    
    -- Then draw the inventory (this is called separately by the renderer)
    -- Removed inventory drawing from here since it's handled separately
end

---Draw the grid structure
---@param self CombinationGrid The CombinationGrid instance
function Drawing.drawGrid(self)
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
                self:drawElement(self.grid[row][col].element, x, y)
            end
        end
    end
end

---Draw a single element
---@param self CombinationGrid The CombinationGrid instance
---@param elementName string Element ID
---@param x number X position
---@param y number Y position
function Drawing.drawElement(self, elementName, x, y)
    -- Get element data (either from elements or directly from materialData)
    local elementData
    
    if self.elements[elementName] then
        elementData = {
            name = self.elements[elementName].name,
            color = self.elements[elementName].color
        }
    elseif self.materialData[elementName] then
        elementData = self.materialData[elementName]
    else
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

---Draw the inventory interface
---@param self CombinationGrid The CombinationGrid instance
---@param x number X position
---@param y number Y position
---@param width number Width
---@param height number Height
function Drawing.drawInventory(self, x, y, width, height)
    -- Set default values if not provided
    x = x or 0
    y = y or 0
    width = width or love.graphics.getWidth()
    height = height or 60
    
    -- Draw inventory background
    love.graphics.setColor(0.15, 0.15, 0.15, 0.8)
    love.graphics.rectangle("fill", x, y, width, height)
    
    -- Draw inventory title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Inventory", x, y - 25, width, "center")
    
    -- Draw inventory items
    local itemSize = 60
    local margin = 10
    local inventoryKeys = self:getInventoryKeys()
    local startX = x + (width - (#inventoryKeys * (itemSize + margin))) / 2
    local index = 0
    
    for elementId, count in pairs(self.inventory:getItems()) do
        if count > 0 then
            local itemX = startX + index * (itemSize + margin)
            
            -- Get element data (from either source)
            local elementColor, elementName
            if self.elements[elementId] then
                elementColor = self.elements[elementId].color
                elementName = self.elements[elementId].name
            elseif self.materialData[elementId] then
                elementColor = self.materialData[elementId].color
                elementName = self.materialData[elementId].name
            else
                -- Skip if no data is available
                goto continue
            end
            
            -- Draw element background
            love.graphics.setColor(unpack(elementColor))
            love.graphics.rectangle("fill", itemX, y, itemSize, itemSize)
            
            -- Draw element name (using smaller font to fit)
            local fontSize = 12
            -- Adjust font size based on name length
            if #elementName > 6 then
                fontSize = 10
            end
            local font = love.graphics.newFont(fontSize)
            love.graphics.setFont(font)
            
            -- Draw text shadow for better visibility
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.printf(elementName, itemX + 1, y + 11, itemSize, "center")
            
            -- Draw element name with appropriate color based on background brightness
            local r, g, b = elementColor[1], elementColor[2], elementColor[3]
            local brightness = (r * 299 + g * 587 + b * 114) / 1000
            if brightness > 0.5 then
                love.graphics.setColor(0, 0, 0)  -- Dark text on bright backgrounds
            else
                love.graphics.setColor(1, 1, 1)  -- Light text on dark backgrounds
            end
            love.graphics.printf(elementName, itemX, y + 10, itemSize, "center")
            
            -- Draw count with shadow and contrasting color
            love.graphics.setColor(0, 0, 0, 0.7)
            love.graphics.printf(tostring(count), itemX + 1, y + 36, itemSize, "center")
            love.graphics.setColor(1, 1, 1)  -- Always white for count since background is dark
            love.graphics.printf(tostring(count), itemX, y + 35, itemSize, "center")
            
            index = index + 1
            
            ::continue::
        end
    end
    
    -- Reset font to default
    love.graphics.setFont(love.graphics.getFont())
end

---Draw a single inventory item
---@param self CombinationGrid The CombinationGrid instance
---@param elementName string Element ID
---@param count number Item count
---@param x number X position
---@param y number Y position
---@param size number Item size
function Drawing.drawInventoryItem(self, elementName, count, x, y, size)
    -- Get element data (either from elements or directly from materialData)
    local elementData
    
    if self.elements[elementName] then
        elementData = {
            name = self.elements[elementName].name,
            color = self.elements[elementName].color
        }
    elseif self.materialData[elementName] then
        elementData = self.materialData[elementName]
    else
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

return Drawing 