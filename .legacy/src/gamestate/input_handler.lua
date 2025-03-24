---@class InputHandler
---@field new fun(self: InputHandler): InputHandler
---@field handleKeyPress fun(self: InputHandler, gameState: GameState, key: string, scancode: string, isrepeat: boolean): boolean
---@field handleMousePress fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleMouseRelease fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleMenuMousePress fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleOptionsMousePress fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handlePlayingStateMousePress fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleGridClick fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleInventoryClick fun(self: InputHandler, gameState: GameState, x: number, y: number, button: number): boolean
---@field handleMenuAction fun(self: InputHandler, gameState: GameState, action: string): nil
---@field isPointInGrid fun(self: InputHandler, gameState: GameState, x: number, y: number): boolean
---@field isPointInInventory fun(self: InputHandler, gameState: GameState, x: number, y: number): boolean
---@field getCellBounds fun(self: InputHandler, gameState: GameState, row: number, col: number): number, number, number, number
---@field getCellCenterPosition fun(self: InputHandler, gameState: GameState, row: number, col: number): number, number
---@field debugValue fun(self: InputHandler, gameState: GameState, name: string, value: any): nil
-- Input handler module to handle all user input
local InputHandler = {}
local Config = require("src.gamestate.config")

-- Initialize a new input handler
---@return InputHandler
function InputHandler:new()
    local instance = {}
    setmetatable(instance, {__index = self})
    return instance
end

-- Debug value helper function to log values through the debug system
---@param gameState GameState The current game state
---@param name string Name of the value to log
---@param value any Value to log
function InputHandler:debugValue(gameState, name, value)
    if gameState.debug then
        gameState.debug:debug("InputHandler", name, value)
    end
end

-- Handle keyboard input
---@param gameState GameState The current game state
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
---@return boolean Whether the input was handled
function InputHandler:handleKeyPress(gameState, key, scancode, isrepeat)
    -- Log the key press
    self:debugValue(gameState, "Key pressed", {key = key, scancode = scancode, isrepeat = isrepeat})
    
    -- Toggle debug mode with F12
    if key == "f12" then
        if gameState.debug then
            local currentState = gameState.debug.enabled
            gameState.debug:setEnabled(not currentState)
            self:debugValue(gameState, "Debug mode toggled", not currentState)
            return true
        end
    end
    
    -- Cycle debug log levels with F11
    if key == "f11" and gameState.debug and gameState.debug.enabled then
        local levels = {"debug", "info", "warn", "error"}
        local currentLevel = gameState.debug.logLevel
        local currentIndex = 1
        
        -- Find current level index
        for i, level in ipairs(levels) do
            if level == currentLevel then
                currentIndex = i
                break
            end
        end
        
        -- Cycle to next level
        local nextIndex = (currentIndex % #levels) + 1
        local nextLevel = levels[nextIndex]
        
        -- Set new level
        gameState.debug:setLogLevel(nextLevel)
        Config:set("debugLogLevel", nextLevel)
        
        -- Log the change
        self:debugValue(gameState, "Debug log level changed", {
            from = currentLevel,
            to = nextLevel,
            available = levels
        })
        
        return true
    end
    
    if key == "escape" then
        if gameState.currentState == "playing" then
            gameState.currentState = "menu"
            return true
        else
            love.event.quit()
            return true
        end
    end
    
    -- Handle state-specific key presses
    if gameState.currentState == "menu" then
        if gameState.modes.menu then
            local action = gameState.modes.menu:handleKeyPress(key)
            if action then
                self:handleMenuAction(gameState, action)
                return true
            end
        end
    elseif gameState.currentState == "options" then
        if gameState.modes.options then
            local action = gameState.modes.options:handleKeyPress(key)
            if action and action == "back_to_menu" then
                gameState.currentState = "menu"
                return true
            end
        end
    end
    
    return false
end

-- Handle mouse press
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handleMousePress(gameState, x, y, button)
    -- Log the mouse press
    self:debugValue(gameState, "Mouse pressed", {x = x, y = y, button = button})
    
    -- Handle based on current state
    if gameState.currentState == "menu" then
        return self:handleMenuMousePress(gameState, x, y, button)
    elseif gameState.currentState == "options" then
        return self:handleOptionsMousePress(gameState, x, y, button)
    elseif gameState.currentState == "playing" then
        return self:handlePlayingStateMousePress(gameState, x, y, button)
    end
    
    return false
end

-- Handle menu state mouse press
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handleMenuMousePress(gameState, x, y, button)
    if gameState.modes.menu then
        local action = gameState.modes.menu:handleMousePress(x, y, button)
        if action then
            self:handleMenuAction(gameState, action)
            return true
        end
    end
    return false
end

-- Handle options state mouse press
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handleOptionsMousePress(gameState, x, y, button)
    if gameState.modes.options then
        local action = gameState.modes.options:handleMousePress(x, y, button)
        if action and action == "back_to_menu" then
            gameState.currentState = "menu"
            return true
        end
    end
    return false
end

-- Handle mouse press during playing state
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handlePlayingStateMousePress(gameState, x, y, button)
    -- Check if click is in grid area
    if self:isPointInGrid(gameState, x, y) then
        return self:handleGridClick(gameState, x, y, button)
    -- Check if click is in inventory area    
    elseif self:isPointInInventory(gameState, x, y) then
        return self:handleInventoryClick(gameState, x, y, button)
    else
        -- Clear selections when clicking elsewhere
        gameState.combinationGrid.selectedCell = nil
        gameState.selectedInventoryItem = nil
        return false
    end
end

-- Handle grid click
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handleGridClick(gameState, x, y, button)
    -- Convert to local grid coordinates
    local localX = x - gameState.gridX
    local localY = y - gameState.gridY
    
    -- Log the grid click
    self:debugValue(gameState, "Grid click converted", {
        screenPos = {x = x, y = y}, 
        gridPos = {x = localX, y = localY},
        button = button
    })
    
    -- Get drag controls setting
    local classicControls = Config:get("classicDragControls")
    
    -- Handle grid click
    if (not classicControls and button == 1) or (classicControls and button == 1) then -- Left click
        -- If there's a selected inventory item, try to place it on the grid
        if gameState.selectedInventoryItem then
            -- Find the cell that was clicked
            for row = 1, gameState.combinationGrid.rows do
                for col = 1, gameState.combinationGrid.columns do
                    local cellX, cellY, cellWidth, cellHeight = self:getCellBounds(gameState, row, col)
                    
                    if localX >= cellX and localX < cellX + cellWidth and
                       localY >= cellY and localY < cellY + cellHeight then
                        
                        -- Try to place the selected inventory item
                        if gameState.combinationGrid:addElementFromInventory(gameState.selectedInventoryItem, row, col) then
                            -- Show element visualization effect - use absolute screen coordinates
                            local screenX = gameState.gridX + cellX + cellWidth/2
                            local screenY = gameState.gridY + cellY + cellHeight/2
                            gameState.visualization:showElement(screenX, screenY, gameState.selectedInventoryItem)
                            gameState.selectedInventoryItem = nil
                            return true
                        end
                    end
                end
            end
        end
        
        -- If no item was placed or no item was selected, proceed with normal grid click handling
        
        -- Save selected element information before handleClick clears it
        local selectedElement = nil
        local selectedCell = gameState.combinationGrid.selectedCell
        if selectedCell then
            local selectedCellData = gameState.combinationGrid.grid[selectedCell.row][selectedCell.col]
            if selectedCellData then
                selectedElement = selectedCellData.element
            end
        end
        
        -- Handle the click
        local combinationOccurred, resultElement, centerX, centerY = gameState.combinationGrid:handleClick(localX, localY)
        
        -- Show visualization effects if a combination happened
        if combinationOccurred and resultElement and selectedElement then
            -- Find the cell containing the result element
            local targetRow, targetCol = nil, nil
            
            -- Find the cell containing the result element
            for row = 1, gameState.combinationGrid.rows do
                for col = 1, gameState.combinationGrid.columns do
                    if gameState.combinationGrid.grid[row][col] and 
                       gameState.combinationGrid.grid[row][col].element == resultElement then
                        targetRow, targetCol = row, col
                        break
                    end
                end
                if targetRow then break end
            end
            
            -- Get the exact center position of the target cell
            local screenX, screenY
            if targetRow and targetCol then
                local cellX, cellY, cellWidth, cellHeight = self:getCellBounds(gameState, targetRow, targetCol)
                -- Convert to absolute screen coordinates
                screenX = gameState.gridX + cellX + cellWidth/2
                screenY = gameState.gridY + cellY + cellHeight/2
            else
                -- Fallback to the original calculation if we can't find the target cell
                screenX = gameState.gridX + centerX
                screenY = gameState.gridY + centerY
            end

            -- Log the combination that occurred with detailed information
            self:debugValue(gameState, "Combination created", {
                firstElement = selectedElement,
                resultElement = resultElement,
                position = {
                    screen = {x = screenX, y = screenY},
                    grid = targetRow and targetCol and {
                        row = targetRow,
                        col = targetCol
                    } or nil
                }
            })

            -- Show combination visualization with absolute screen coordinates
            gameState.visualization:showCombination(screenX, screenY, selectedElement, resultElement, resultElement, false, nil)
        end
    elseif (not classicControls and button == 2) or (classicControls and button == 2) then -- Right click
        -- Use the CombinationGrid's removeElementToInventory function
        local removed, elementName, centerX, centerY = gameState.combinationGrid:removeElementToInventory(localX, localY)
        
        -- If an element was removed, show visualization
        if removed and elementName and gameState.visualization then
            -- Convert local coordinates to screen coordinates
            local screenX = gameState.gridX + centerX
            local screenY = gameState.gridY + centerY
            
            -- Show element visualization effect
            gameState.visualization:showElement(screenX, screenY, elementName)
        end
        
        -- Clear selected inventory item
        gameState.selectedInventoryItem = nil
    end
    return true
end

-- Handle inventory click
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InputHandler:handleInventoryClick(gameState, x, y, button)
    -- Get drag controls setting
    local classicControls = Config:get("classicDragControls")
    
    if (not classicControls and button == 1) or (classicControls and button == 1) then -- Left click
        -- Calculate the local inventory coordinates
        local localX = x - gameState.inventoryX
        local localY = y - gameState.inventoryY
        
        -- Log the inventory click with detailed information
        self:debugValue(gameState, "Inventory click", {
            screenPos = {x = x, y = y},
            inventoryPos = {x = localX, y = localY},
            button = button,
            inventoryBounds = {
                x = gameState.inventoryX,
                y = gameState.inventoryY,
                width = gameState.inventoryWidth,
                height = gameState.inventoryHeight
            }
        })
        
        -- Call handleInventoryClick with gameState and local coordinates
        local elementName = gameState.combinationGrid:handleInventoryClick(
            localX, 
            localY, 
            gameState.inventoryWidth, 
            gameState.inventoryHeight
        )
        
        if elementName then
            gameState.selectedInventoryItem = elementName
            
            -- Log the selected element with more details
            self:debugValue(gameState, "Selected inventory item", {
                element = elementName,
                position = {x = x, y = y},
                inventoryState = {
                    previouslySelected = gameState.selectedInventoryItem ~= elementName and 
                                         gameState.selectedInventoryItem or nil
                }
            })
            
            -- Show selection effect
            gameState.visualization:showElement(x, y, elementName)
        end
    elseif (not classicControls and button == 2) or (classicControls and button == 2) then -- Right click
        -- Log right click on inventory
        if gameState.selectedInventoryItem then
            self:debugValue(gameState, "Clearing inventory selection", {
                previousSelection = gameState.selectedInventoryItem,
                position = {x = x, y = y}
            })
        end
        
        -- Clear selection
        gameState.selectedInventoryItem = nil
    end
    return true
end

-- Handle mouse release
---@param gameState GameState The current game state
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function InputHandler:handleMouseRelease(gameState, x, y, button)
    -- Log the mouse release
    self:debugValue(gameState, "Mouse released", {x = x, y = y, button = button})

    -- Handle based on current state
    if gameState.currentState == "menu" then
        if gameState.modes.menu then
            local action = gameState.modes.menu:handleMouseRelease(x, y, button)
            if action then
                self:handleMenuAction(gameState, action)
                return true
            end
        end
    elseif gameState.currentState == "options" then
        if gameState.modes.options then
            local action = gameState.modes.options:handleMouseRelease(x, y, button)
            if action and action == "back_to_menu" then
                gameState.currentState = "menu"
                return true
            end
        end
    end
    return false
end

-- Handle menu actions
---@param gameState GameState The current game state
---@param action string Action to perform
function InputHandler:handleMenuAction(gameState, action)
    if action == "start_game" then
        gameState.currentState = "playing"
    elseif action == "options" then
        gameState.currentState = "options"
    elseif action == "exit" then
        love.event.quit()
    end
end

-- Check if a point is inside the grid
---@param gameState GameState The current game state
---@param x number Point X position
---@param y number Point Y position
---@return boolean Whether the point is inside the grid
function InputHandler:isPointInGrid(gameState, x, y)
    local gridWidth = gameState.combinationGrid.columns * 
                     (gameState.combinationGrid.cellSize + gameState.combinationGrid.margin) + 
                     gameState.combinationGrid.margin
                     
    local gridHeight = gameState.combinationGrid.rows * 
                      (gameState.combinationGrid.cellSize + gameState.combinationGrid.margin) + 
                      gameState.combinationGrid.margin
    
    return x >= gameState.gridX and 
           x < gameState.gridX + gridWidth and
           y >= gameState.gridY and 
           y < gameState.gridY + gridHeight
end

-- Check if a point is inside the inventory
---@param gameState GameState The current game state
---@param x number Point X position
---@param y number Point Y position
---@return boolean Whether the point is inside the inventory
function InputHandler:isPointInInventory(gameState, x, y)
    return x >= gameState.inventoryX and 
           x < gameState.inventoryX + gameState.inventoryWidth and
           y >= gameState.inventoryY and 
           y < gameState.inventoryY + gameState.inventoryHeight
end

-- Get the bounds of a cell
---@param gameState GameState The current game state
---@param row number Grid row
---@param col number Grid column
---@return number cellX, number cellY, number cellWidth, number cellHeight Cell bounds
function InputHandler:getCellBounds(gameState, row, col)
    local cellX = (col - 1) * (gameState.combinationGrid.cellSize + gameState.combinationGrid.margin) + 
                  gameState.combinationGrid.margin
                          
    local cellY = (row - 1) * (gameState.combinationGrid.cellSize + gameState.combinationGrid.margin) + 
                  gameState.combinationGrid.margin
                  
    return cellX, cellY, gameState.combinationGrid.cellSize, gameState.combinationGrid.cellSize
end

-- Get cell center position
---@param gameState GameState The current game state
---@param row number Grid row
---@param col number Grid column
---@return number centerX, number centerY Cell center position
function InputHandler:getCellCenterPosition(gameState, row, col)
    local cellX, cellY, cellWidth, cellHeight = self:getCellBounds(gameState, row, col)
    return cellX + cellWidth/2, cellY + cellHeight/2
end

-- Handle shop mouse press
function InputHandler:handleShopMousePress(gameState, x, y, button)
    if gameState.shop then
        -- Switch left and right click behavior based on classic control setting
        local classicControls = Config:get("classicDragControls")
        local actualButton = button
        
        -- If using classic controls, swap mouse buttons for shop interactions
        if classicControls then
            if button == 1 then actualButton = 2
            elseif button == 2 then actualButton = 1
            end
        end
        
        return gameState.shop:mousepressed(x, y, actualButton)
    end
    return false
end

-- Handle shop mouse movement
function InputHandler:handleShopMouseMove(gameState, x, y, dx, dy)
    if gameState.shop then
        return gameState.shop:mousemoved(x, y, dx, dy)
    end
    return false
end

-- Handle shop mouse release
function InputHandler:handleShopMouseRelease(gameState, x, y, button)
    if gameState.shop then
        -- Switch left and right click behavior based on classic control setting
        local classicControls = Config:get("classicDragControls")
        local actualButton = button
        
        -- If using classic controls, swap mouse buttons for shop interactions
        if classicControls then
            if button == 1 then actualButton = 2
            elseif button == 2 then actualButton = 1
            end
        end
        
        return gameState.shop:mousereleased(x, y, actualButton)
    end
    return false
end

return InputHandler 