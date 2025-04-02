local love = require("love")

-- Add type definition for love.Font
---@class love.Font
---@field getHeight fun():number

---@class ShopDrawing
---@field core ShopCore Reference to the shop core
---@field handlers ShopHandlers Reference to the shop handlers
---@field inventory Inventory Reference to the player's inventory
---@field isOpen boolean Whether the shop panel is open
---@field position table Position of the shop panel
---@field size table Size of the shop panel
---@field buttonSize table Size of shop buttons
---@field colors table UI color scheme
---@field font love.Font Font for shop text
---@field smallFont love.Font Smaller font for descriptions
---@field selectedCategory string Currently selected shop category
---@field scrollOffset number Vertical scroll offset for item list
---@field activeTab string Currently active tab (buy or sell)
---@field sellScrollOffset number Vertical scroll offset for sell item list
---@field isDraggingPanel boolean Whether the panel is being dragged
---@field isDraggingButton boolean Whether the shop button is being dragged
---@field dragOffsetX number X offset for dragging
---@field dragOffsetY number Y offset for dragging
---@field buttonPosition table Position of the shop button
local ShopDrawing = {}

---Creates a new ShopDrawing instance
---@param shopCore ShopCore The shop core instance
---@param shopHandlers ShopHandlers The shop handlers instance
---@param inventory Inventory The player's inventory
---@return ShopDrawing
function ShopDrawing:new(shopCore, shopHandlers, inventory)
    local o = {}
    setmetatable(o, { __index = self })
    
    o.core = shopCore
    o.handlers = shopHandlers
    o.inventory = inventory
    
    -- UI state
    o.isOpen = false
    o.position = { x = love.graphics.getWidth() - 320, y = 10 }
    o.size = { width = 300, height = 500 }
    o.buttonSize = { width = 80, height = 30 }
    o.colors = {
        background = { 0.2, 0.2, 0.2, 0.9 },
        button = { 0.3, 0.3, 0.3, 1 },
        buttonHover = { 0.4, 0.4, 0.4, 1 },
        buttonDisabled = { 0.2, 0.2, 0.2, 1 },
        text = { 1, 1, 1, 1 },
        gold = { 1, 0.84, 0, 1 },
        header = { 0.8, 0.8, 0.8, 1 },
        border = { 0.5, 0.5, 0.5, 1 },
        categoryTab = { 0.3, 0.3, 0.3, 1 },
        categoryTabSelected = { 0.4, 0.4, 0.4, 1 },
        tabButton = { 0.25, 0.25, 0.25, 1 },
        tabButtonSelected = { 0.35, 0.35, 0.35, 1 },
        sellHighlight = { 0.3, 0.5, 0.3, 1 }
    }
    
    o.font = love.graphics.getFont()
    o.smallFont = o.font
    if o.font:getHeight() > 14 then
        o.smallFont = love.graphics.newFont(12)
    end
    
    o.selectedCategory = nil
    o.scrollOffset = 0
    o.sellScrollOffset = 0
    o.activeTab = "buy" -- Default tab is buy
    
    -- Dragging state
    o.isDraggingPanel = false
    o.isDraggingButton = false
    o.dragOffsetX = 0
    o.dragOffsetY = 0
    o.buttonPosition = { x = love.graphics.getWidth() - 200, y = 10 }
    
    return o
end

---Toggles the shop panel visibility
function ShopDrawing:toggleShop()
    self.isOpen = not self.isOpen
    if self.isOpen and not self.selectedCategory then
        local categories = self.core:getAvailableCategories()
        if #categories > 0 then
            self.selectedCategory = categories[1]
        end
    end
end

---Draws the shop toggle button in the top-right corner
function ShopDrawing:drawShopButton()
    -- Use the stored button position instead of hard-coded values
    local buttonX = self.buttonPosition.x
    local buttonY = self.buttonPosition.y
    local buttonWidth = 50
    local buttonHeight = 30
    
    -- Draw button background
    love.graphics.setColor(self.colors.button)
    love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
    
    -- Draw button border
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", buttonX, buttonY, buttonWidth, buttonHeight, 5, 5)
    
    -- Draw button text
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Shop", buttonX, buttonY + 7, buttonWidth, "center")
    
    return {
        x = buttonX,
        y = buttonY,
        width = buttonWidth,
        height = buttonHeight
    }
end

---Draws the shop panel when open
function ShopDrawing:drawShopPanel()
    if not self.isOpen then
        return
    end
    
    local x, y = self.position.x, self.position.y
    local width, height = self.size.width, self.size.height
    
    -- Draw panel background
    love.graphics.setColor(self.colors.background)
    love.graphics.rectangle("fill", x, y, width, height, 5, 5)
    
    -- Draw panel border
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", x, y, width, height, 5, 5)
    
    -- Draw panel header
    love.graphics.setColor(self.colors.header)
    love.graphics.printf("Alchemy Shop", x, y + 10, width, "center")
    
    -- Draw gold amount
    love.graphics.setColor(self.colors.gold)
    love.graphics.printf("Gold: " .. self.inventory.inventory:getFormattedGold(), x + 10, y + 40, width - 20, "left")
    
    -- Draw tabs for buy/sell
    self:drawShopTabs(x + 10, y + 70, width - 20)
    
    -- Draw content based on active tab
    if self.activeTab == "buy" then
        -- Draw category tabs (only in buy mode)
        self:drawCategoryTabs(x + 10, y + 110, width - 20)
        
        -- Draw item listings
        if self.selectedCategory then
            self:drawItemListings(x + 10, y + 150, width - 20, height - 190)
        end
    else -- sell tab
        self:drawSellItemsPanel(x + 10, y + 110, width - 20, height - 150)
    end
    
    -- Draw close button
    local closeX = x + width - 30
    local closeY = y + 10
    love.graphics.setColor(self.colors.button)
    love.graphics.rectangle("fill", closeX, closeY, 20, 20, 3, 3)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("X", closeX, closeY + 2, 20, "center")
end

---Draws tabs for buying and selling
---@param x number X position
---@param y number Y position
---@param width number Width of tab area
function ShopDrawing:drawShopTabs(x, y, width)
    local tabWidth = width / 2
    
    -- Buy tab
    if self.activeTab == "buy" then
        love.graphics.setColor(self.colors.tabButtonSelected)
    else
        love.graphics.setColor(self.colors.tabButton)
    end
    love.graphics.rectangle("fill", x, y, tabWidth - 2, 30, 3, 3)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Buy Items", x, y + 7, tabWidth - 2, "center")
    
    -- Sell tab
    if self.activeTab == "sell" then
        love.graphics.setColor(self.colors.tabButtonSelected)
    else
        love.graphics.setColor(self.colors.tabButton)
    end
    love.graphics.rectangle("fill", x + tabWidth, y, tabWidth - 2, 30, 3, 3)
    love.graphics.setColor(self.colors.text)
    love.graphics.printf("Sell Items", x + tabWidth, y + 7, tabWidth - 2, "center")
end

---Draws the category tabs for the shop
---@param x number X position
---@param y number Y position
---@param width number Width of tab area
function ShopDrawing:drawCategoryTabs(x, y, width)
    local categories = self.core:getAvailableCategories()
    local tabWidth = width / #categories
    
    for i, category in ipairs(categories) do
        local tabX = x + (i-1) * tabWidth
        
        -- Draw tab background
        if category == self.selectedCategory then
            love.graphics.setColor(self.colors.categoryTabSelected)
        else
            love.graphics.setColor(self.colors.categoryTab)
        end
        love.graphics.rectangle("fill", tabX, y, tabWidth - 2, 30, 3, 3)
        
        -- Draw tab text
        love.graphics.setColor(self.colors.text)
        love.graphics.printf(category, tabX, y + 7, tabWidth - 2, "center")
    end
end

---Draws the item listings for the selected category
---@param x number X position
---@param y number Y position
---@param width number Width of listing area
---@param height number Height of listing area
function ShopDrawing:drawItemListings(x, y, width, height)
    local items = self.core:getCategoryItems(self.selectedCategory)
    local itemHeight = 80
    local visibleItems = math.floor(height / itemHeight)
    local maxScroll = math.max(0, #items - visibleItems)
    
    -- Clamp scroll offset
    self.scrollOffset = math.max(0, math.min(self.scrollOffset, maxScroll))
    
    -- Draw item listings
    for i = 1, visibleItems do
        local itemIndex = i + self.scrollOffset
        if itemIndex <= #items then
            local itemId = items[itemIndex]
            local itemY = y + (i-1) * itemHeight
            
            -- Draw item background
            love.graphics.setColor(0.25, 0.25, 0.25, 0.8)
            love.graphics.rectangle("fill", x, itemY, width, itemHeight - 5, 3, 3)
            
            -- Draw item name
            love.graphics.setColor(self.colors.text)
            love.graphics.printf(itemId, x + 10, itemY + 10, width - 20, "left")
            
            -- Draw item description
            love.graphics.setFont(self.smallFont)
            love.graphics.setColor(0.8, 0.8, 0.8, 1)
            local description = self.core:getItemDescription(self.selectedCategory, itemId)
            love.graphics.printf(description, x + 10, itemY + 30, width - 100, "left")
            love.graphics.setFont(self.font)
            
            -- Draw price
            local price = self.core:getItemPrice(self.selectedCategory, itemId)
            love.graphics.setColor(self.colors.gold)
            love.graphics.printf(price .. " gold", x + width - 80, itemY + 10, 70, "right")
            
            -- Draw buy button
            local canBuy, message = self.handlers:canPurchaseItem(self.selectedCategory, itemId, 1)
            local buttonX = x + width - 90
            local buttonY = itemY + itemHeight - 35
            local buttonWidth = 80
            local buttonHeight = 25
            
            if canBuy then
                love.graphics.setColor(self.colors.button)
            else
                love.graphics.setColor(self.colors.buttonDisabled)
            end
            love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
            
            love.graphics.setColor(self.colors.text)
            love.graphics.printf("Buy", buttonX, buttonY + 5, buttonWidth, "center")
        end
    end
    
    -- Draw scroll indicators if needed
    if maxScroll > 0 then
        if self.scrollOffset > 0 then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
            love.graphics.polygon("fill", 
                x + width/2 - 10, y - 15,
                x + width/2 + 10, y - 15,
                x + width/2, y - 25
            )
        end
        
        if self.scrollOffset < maxScroll then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
            love.graphics.polygon("fill", 
                x + width/2 - 10, y + height + 15,
                x + width/2 + 10, y + height + 15,
                x + width/2, y + height + 25
            )
        end
    end
end

---Draws the selling interface
---@param x number X position
---@param y number Y position
---@param width number Width of the sell panel
---@param height number Height of the sell panel
function ShopDrawing:drawSellItemsPanel(x, y, width, height)
    -- Get the player's inventory items that can be sold
    local inventoryItems = self.inventory:get_all_items()
    local sellableItems = {}
    
    -- Filter for sellable items and get their values
    for itemId, count in pairs(inventoryItems) do
        local value = self.core:getSellableItemValue(itemId)
        if value > 0 and count > 0 then
            table.insert(sellableItems, {
                id = itemId,
                count = count,
                value = value
            })
        end
    end
    
    -- If no sellable items
    if #sellableItems == 0 then
        love.graphics.setColor(self.colors.text)
        love.graphics.printf("No items to sell", x, y + 50, width, "center")
        return
    end
    
    -- Draw sell items header
    love.graphics.setColor(self.colors.header)
    love.graphics.printf("Your Sellable Items", x, y, width, "center")
    
    -- Draw items list
    local itemHeight = 80
    local visibleItems = math.floor(height / itemHeight)
    local maxScroll = math.max(0, #sellableItems - visibleItems)
    
    -- Clamp sell scroll offset
    self.sellScrollOffset = math.max(0, math.min(self.sellScrollOffset, maxScroll))
    
    -- Draw item listings
    for i = 1, visibleItems do
        local itemIndex = i + self.sellScrollOffset
        if itemIndex <= #sellableItems then
            local item = sellableItems[itemIndex]
            local itemY = y + 30 + (i-1) * itemHeight
            
            -- Draw item background
            love.graphics.setColor(0.25, 0.25, 0.25, 0.8)
            love.graphics.rectangle("fill", x, itemY, width, itemHeight - 5, 3, 3)
            
            -- Draw item name
            love.graphics.setColor(self.colors.text)
            love.graphics.printf(item.id, x + 10, itemY + 10, width - 20, "left")
            
            -- Draw item count
            love.graphics.setFont(self.smallFont)
            love.graphics.printf("Quantity: " .. item.count, x + 10, itemY + 30, width - 100, "left")
            
            -- Draw sell value
            love.graphics.setColor(self.colors.gold)
            love.graphics.printf("Value: " .. item.value .. " gold each", x + 10, itemY + 50, width - 100, "left")
            love.graphics.setFont(self.font)
            
            -- Draw sell button
            local canSell, message = self.handlers:canSellItem(item.id, 1)
            local buttonX = x + width - 90
            local buttonY = itemY + itemHeight - 35
            local buttonWidth = 80
            local buttonHeight = 25
            
            if canSell then
                love.graphics.setColor(self.colors.button)
            else
                love.graphics.setColor(self.colors.buttonDisabled)
            end
            love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 3, 3)
            
            love.graphics.setColor(self.colors.text)
            love.graphics.printf("Sell", buttonX, buttonY + 5, buttonWidth, "center")
        end
    end
    
    -- Draw scroll indicators if needed
    if maxScroll > 0 then
        if self.sellScrollOffset > 0 then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
            love.graphics.polygon("fill", 
                x + width/2 - 10, y + 25,
                x + width/2 + 10, y + 25,
                x + width/2, y + 15
            )
        end
        
        if self.sellScrollOffset < maxScroll then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
            love.graphics.polygon("fill", 
                x + width/2 - 10, y + height - 5,
                x + width/2 + 10, y + height - 5,
                x + width/2, y + height + 5
            )
        end
    end
end

---Handles mouse press on the shop UI
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number Mouse button pressed
---@return boolean handled Whether the input was handled
function ShopDrawing:mousepressed(x, y, button)
    -- Check shop toggle button
    local shopButton = self:drawShopButton()
    if x >= shopButton.x and x <= shopButton.x + shopButton.width and
       y >= shopButton.y and y <= shopButton.y + shopButton.height then
        -- Start dragging if right-click, toggle shop if left-click
        if button == 2 then  -- Right-click
            self.isDraggingButton = true
            self.dragOffsetX = x - shopButton.x
            self.dragOffsetY = y - shopButton.y
            return true
        elseif button == 1 then  -- Left-click
            self:toggleShop()
            return true
        end
    end
    
    if not self.isOpen then return false end
    
    -- Check if clicking on the shop panel header (for dragging)
    local headerHeight = 40
    if x >= self.position.x and x <= self.position.x + self.size.width and
       y >= self.position.y and y <= self.position.y + headerHeight then
        -- Handle close button first
        local closeX = self.position.x + self.size.width - 30
        local closeY = self.position.y + 10
        if x >= closeX and x <= closeX + 20 and
           y >= closeY and y <= closeY + 20 and button == 1 then
            self.isOpen = false
            return true
        end
        
        -- Start dragging panel with left-click
        if button == 1 then
            self.isDraggingPanel = true
            self.dragOffsetX = x - self.position.x
            self.dragOffsetY = y - self.position.y
            return true
        end
    end
    
    -- Only process UI interactions for left-click
    if button ~= 1 then return false end
    
    -- Check shop tabs
    local tabX = self.position.x + 10
    local tabY = self.position.y + 70
    local tabWidth = (self.size.width - 20) / 2
    
    -- Buy tab
    if x >= tabX and x <= tabX + tabWidth - 2 and
       y >= tabY and y <= tabY + 30 then
        self.activeTab = "buy"
        return true
    end
    
    -- Sell tab
    if x >= tabX + tabWidth and x <= tabX + tabWidth * 2 - 2 and
       y >= tabY and y <= tabY + 30 then
        self.activeTab = "sell"
        return true
    end
    
    -- Handle tab-specific interactions
    if self.activeTab == "buy" then
        -- Check category tabs
        local categoryTabY = self.position.y + 110
        local categoryTabWidth = (self.size.width - 20) / #self.core:getAvailableCategories()
        
        for i, category in ipairs(self.core:getAvailableCategories()) do
            local catTabX = tabX + (i-1) * categoryTabWidth
            if x >= catTabX and x <= catTabX + categoryTabWidth - 2 and
               y >= categoryTabY and y <= categoryTabY + 30 then
                self.selectedCategory = category
                self.scrollOffset = 0
                return true
            end
        end
        
        -- Check item buy buttons
        if self.selectedCategory then
            local listX = self.position.x + 10
            local listY = self.position.y + 150
            local listWidth = self.size.width - 20
            local itemHeight = 80
            
            local items = self.core:getCategoryItems(self.selectedCategory)
            local visibleItems = math.floor((self.size.height - 190) / itemHeight)
            
            for i = 1, visibleItems do
                local itemIndex = i + self.scrollOffset
                if itemIndex <= #items then
                    local itemId = items[itemIndex]
                    local itemY = listY + (i-1) * itemHeight
                    
                    local buttonX = listX + listWidth - 90
                    local buttonY = itemY + itemHeight - 35
                    local buttonWidth = 80
                    local buttonHeight = 25
                    
                    if x >= buttonX and x <= buttonX + buttonWidth and
                       y >= buttonY and y <= buttonY + buttonHeight then
                        local success, message = self.handlers:purchaseItem(self.selectedCategory, itemId, 1)
                        -- Show result message here if needed
                        return true
                    end
                end
            end
            
            -- Check buy scroll indicators
            local maxScroll = math.max(0, #items - visibleItems)
            if maxScroll > 0 then
                -- Up scroll
                if self.scrollOffset > 0 and
                   x >= listX + listWidth/2 - 10 and x <= listX + listWidth/2 + 10 and
                   y >= listY - 25 and y <= listY - 15 then
                    self.scrollOffset = math.max(0, self.scrollOffset - 1)
                    return true
                end
                
                -- Down scroll
                local scrollBottom = listY + (self.size.height - 190)
                if self.scrollOffset < maxScroll and
                   x >= listX + listWidth/2 - 10 and x <= listX + listWidth/2 + 10 and
                   y >= scrollBottom + 15 and y <= scrollBottom + 25 then
                    self.scrollOffset = math.min(maxScroll, self.scrollOffset + 1)
                    return true
                end
            end
        end
    elseif self.activeTab == "sell" then
        -- Check sell buttons
        local sellX = self.position.x + 10
        local sellY = self.position.y + 110
        local sellWidth = self.size.width - 20
        local itemHeight = 80
        
        local inventoryItems = self.inventory:getItems()
        local sellableItems = {}
        
        -- Filter for sellable items
        for itemId, count in pairs(inventoryItems) do
            local value = self.core:getSellableItemValue(itemId)
            if value > 0 and count > 0 then
                table.insert(sellableItems, {
                    id = itemId,
                    count = count,
                    value = value
                })
            end
        end
        
        local visibleItems = math.floor((self.size.height - 150) / itemHeight)
        
        for i = 1, visibleItems do
            local itemIndex = i + self.sellScrollOffset
            if itemIndex <= #sellableItems then
                local item = sellableItems[itemIndex]
                local itemY = sellY + 30 + (i-1) * itemHeight
                
                local buttonX = sellX + sellWidth - 90
                local buttonY = itemY + itemHeight - 35
                local buttonWidth = 80
                local buttonHeight = 25
                
                if x >= buttonX and x <= buttonX + buttonWidth and
                   y >= buttonY and y <= buttonY + buttonHeight then
                    local success, message = self.handlers:sellItem(item.id, 1)
                    -- Show result message here if needed
                    return true
                end
            end
        end
        
        -- Check sell scroll indicators
        local maxScroll = math.max(0, #sellableItems - visibleItems)
        if maxScroll > 0 then
            -- Up scroll
            if self.sellScrollOffset > 0 and
               x >= sellX + sellWidth/2 - 10 and x <= sellX + sellWidth/2 + 10 and
               y >= sellY + 25 and y <= sellY + 35 then
                self.sellScrollOffset = math.max(0, self.sellScrollOffset - 1)
                return true
            end
            
            -- Down scroll
            if self.sellScrollOffset < maxScroll and
               x >= sellX + sellWidth/2 - 10 and x <= sellX + sellWidth/2 + 10 and
               y >= sellY + (self.size.height - 150) - 5 and y <= sellY + (self.size.height - 150) + 5 then
                self.sellScrollOffset = math.min(maxScroll, self.sellScrollOffset + 1)
                return true
            end
        end
    end
    
    return false
end

---Handles mouse wheel movement for scrolling
---@param x number Mouse x position
---@param y number Mouse y position
---@param dx number Horizontal scroll amount
---@param dy number Vertical scroll amount
---@return boolean handled Whether the input was handled
function ShopDrawing:wheelmoved(x, y, dx, dy)
    if not self.isOpen then return false end
    
    -- Check if mouse is over item listings
    local listX = self.position.x + 10
    
    if self.activeTab == "buy" and self.selectedCategory then
        local listY = self.position.y + 150
        local listWidth = self.size.width - 20
        local listHeight = self.size.height - 190
        
        if x >= listX and x <= listX + listWidth and
           y >= listY and y <= listY + listHeight then
            
            local items = self.core:getCategoryItems(self.selectedCategory)
            local itemHeight = 80
            local visibleItems = math.floor(listHeight / itemHeight)
            local maxScroll = math.max(0, #items - visibleItems)
            
            -- Scroll up or down
            if dy > 0 then
                self.scrollOffset = math.max(0, self.scrollOffset - 1)
            elseif dy < 0 then
                self.scrollOffset = math.min(maxScroll, self.scrollOffset + 1)
            end
            
            return true
        end
    elseif self.activeTab == "sell" then
        local sellY = self.position.y + 110
        local sellWidth = self.size.width - 20
        local sellHeight = self.size.height - 150
        
        if x >= listX and x <= listX + sellWidth and
           y >= sellY and y <= sellY + sellHeight then
            
            local inventoryItems = self.inventory:getItems()
            local sellableItems = {}
            
            -- Filter for sellable items
            for itemId, count in pairs(inventoryItems) do
                local value = self.core:getSellableItemValue(itemId)
                if value > 0 and count > 0 then
                    table.insert(sellableItems, {
                        id = itemId,
                        count = count,
                        value = value
                    })
                end
            end
            
            local itemHeight = 80
            local visibleItems = math.floor(sellHeight / itemHeight)
            local maxScroll = math.max(0, #sellableItems - visibleItems)
            
            -- Scroll up or down
            if dy > 0 then
                self.sellScrollOffset = math.max(0, self.sellScrollOffset - 1)
            elseif dy < 0 then
                self.sellScrollOffset = math.min(maxScroll, self.sellScrollOffset + 1)
            end
            
            return true
        end
    end
    
    return false
end

---Handles mouse drag movement
---@param x number Mouse x position
---@param y number Mouse y position
---@param dx number X movement delta
---@param dy number Y movement delta
---@return boolean handled Whether the input was handled
function ShopDrawing:mousemoved(x, y, dx, dy)
    -- Handle panel dragging
    if self.isDraggingPanel then
        self.position.x = x - self.dragOffsetX
        self.position.y = y - self.dragOffsetY
        
        -- Keep panel within screen bounds
        local screenWidth, screenHeight = love.graphics.getDimensions()
        self.position.x = math.max(0, math.min(self.position.x, screenWidth - self.size.width))
        self.position.y = math.max(0, math.min(self.position.y, screenHeight - self.size.height))
        return true
    end
    
    -- Handle button dragging
    if self.isDraggingButton then
        self.buttonPosition.x = x - self.dragOffsetX
        self.buttonPosition.y = y - self.dragOffsetY
        
        -- Keep button within screen bounds
        local screenWidth, screenHeight = love.graphics.getDimensions()
        self.buttonPosition.x = math.max(0, math.min(self.buttonPosition.x, screenWidth - 50)) -- 50 is button width
        self.buttonPosition.y = math.max(0, math.min(self.buttonPosition.y, screenHeight - 30)) -- 30 is button height
        return true
    end
    
    return false
end

---Handles mouse release
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number Mouse button released
---@return boolean handled Whether the input was handled
function ShopDrawing:mousereleased(x, y, button)
    local handled = false
    
    -- Stop dragging when mouse is released
    if self.isDraggingPanel then
        self.isDraggingPanel = false
        handled = true
    end
    
    if self.isDraggingButton then
        self.isDraggingButton = false
        handled = true
    end
    
    return handled
end

---Updates the shop drawing
---@param dt number Time delta
function ShopDrawing:update(dt)
    -- Update any animations or timers here
end

---Draws the entire shop UI
function ShopDrawing:draw()
    -- Draw shop button (always visible)
    self:drawShopButton()
    
    -- Draw shop panel if open
    if self.isOpen then
        self:drawShopPanel()
    end
end

return ShopDrawing
