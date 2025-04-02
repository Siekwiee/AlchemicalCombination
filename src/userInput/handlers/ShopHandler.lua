-- Shop Handler for the shop UI
local InputHandler = require("src.userInput.handlers.InputHandler")

---@class ShopHandler: InputHandler
---@field game_state GameState Game state reference
local ShopHandler = setmetatable({}, { __index = InputHandler })
ShopHandler.__index = ShopHandler

---Creates a new shop handler
---@param game_state GameState Game state reference
---@return ShopHandler
function ShopHandler:new(game_state)
    local self = setmetatable(InputHandler:new(game_state), self)
    return self
end

---Gets the shop component from the game state
---@return table|nil The shop component or nil if not found
function ShopHandler:get_shop()
    if self.game_state.components and self.game_state.components.shop then
        return self.game_state.components.shop
    end
    return nil
end

---Handles mouse press events for the shop
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function ShopHandler:handle_mouse_pressed(x, y, button)
    local shop = self:get_shop()
    if not shop or not shop.drawing then
        return false
    end

    -- Check if shop button was clicked
    local button_bounds = shop.drawing:drawShopButton()
    if self:is_point_in_bounds(x, y, button_bounds) then
        shop.drawing:toggleShop()
        return true
    end

    -- If shop is open, handle panel interactions
    if shop.drawing.isOpen then
        -- Check if close button was clicked
        local close_x = shop.drawing.position.x + shop.drawing.size.width - 30
        local close_y = shop.drawing.position.y + 10
        if self:is_point_in_bounds(x, y, {x = close_x, y = close_y, width = 20, height = 20}) then
            shop.drawing:toggleShop()
            return true
        end

        -- Handle panel dragging
        if self:is_point_in_bounds(x, y, {
            x = shop.drawing.position.x,
            y = shop.drawing.position.y,
            width = shop.drawing.size.width,
            height = 40
        }) then
            shop.drawing.isDraggingPanel = true
            shop.drawing.dragOffsetX = x - shop.drawing.position.x
            shop.drawing.dragOffsetY = y - shop.drawing.position.y
            return true
        end

        -- Handle shop button dragging
        if self:is_point_in_bounds(x, y, button_bounds) then
            shop.drawing.isDraggingButton = true
            shop.drawing.dragOffsetX = x - shop.drawing.buttonPosition.x
            shop.drawing.dragOffsetY = y - shop.drawing.buttonPosition.y
            return true
        end

        -- Handle tab clicks
        local tab_y = shop.drawing.position.y + 70
        local tab_width = (shop.drawing.size.width - 20) / 2
        local buy_tab_x = shop.drawing.position.x + 10
        local sell_tab_x = buy_tab_x + tab_width

        -- Buy tab
        if self:is_point_in_bounds(x, y, {
            x = buy_tab_x,
            y = tab_y,
            width = tab_width - 2,
            height = 30
        }) then
            shop.drawing.activeTab = "buy"
            return true
        end

        -- Sell tab
        if self:is_point_in_bounds(x, y, {
            x = sell_tab_x,
            y = tab_y,
            width = tab_width - 2,
            height = 30
        }) then
            shop.drawing.activeTab = "sell"
            return true
        end

        -- Handle category tab clicks in buy mode
        if shop.drawing.activeTab == "buy" then
            local category_y = shop.drawing.position.y + 110
            local categories = shop.core:getAvailableCategories()
            local category_width = (shop.drawing.size.width - 20) / #categories

            for i, category in ipairs(categories) do
                local category_x = shop.drawing.position.x + 10 + (i-1) * category_width
                if self:is_point_in_bounds(x, y, {
                    x = category_x,
                    y = category_y,
                    width = category_width - 2,
                    height = 30
                }) then
                    shop.drawing.selectedCategory = category
                    return true
                end
            end
        end

        -- Handle item clicks
        if shop.drawing.activeTab == "buy" and shop.drawing.selectedCategory then
            local items = shop.core:getCategoryItems(shop.drawing.selectedCategory)
            local item_height = 80
            local visible_items = math.floor((shop.drawing.size.height - 190) / item_height)
            local start_y = shop.drawing.position.y + 150

            for i = 1, visible_items do
                local item_index = i + shop.drawing.scrollOffset
                if item_index <= #items then
                    local item_y = start_y + (i-1) * item_height
                    if self:is_point_in_bounds(x, y, {
                        x = shop.drawing.position.x + 10,
                        y = item_y,
                        width = shop.drawing.size.width - 20,
                        height = item_height - 5
                    }) then
                        -- Handle item purchase
                        local item_id = items[item_index]
                        local success, message = shop.handlers:purchaseItem(shop.drawing.selectedCategory, item_id)
                        if success then
                            print("Purchase successful: " .. message)
                        else
                            print("Purchase failed: " .. message)
                        end
                        return true
                    end
                end
            end
        elseif shop.drawing.activeTab == "sell" then
            local items = shop.inventory:getAllItems()
            local item_height = 80
            local visible_items = math.floor((shop.drawing.size.height - 150) / item_height)
            local start_y = shop.drawing.position.y + 110

            for i = 1, visible_items do
                local item_index = i + shop.drawing.sellScrollOffset
                if item_index <= #items then
                    local item_y = start_y + (i-1) * item_height
                    if self:is_point_in_bounds(x, y, {
                        x = shop.drawing.position.x + 10,
                        y = item_y,
                        width = shop.drawing.size.width - 20,
                        height = item_height - 5
                    }) then
                        -- Handle item sale
                        local item_id = items[item_index]
                        local success, message = shop.handlers:sellItem(item_id)
                        if success then
                            print("Sale successful: " .. message)
                        else
                            print("Sale failed: " .. message)
                        end
                        return true
                    end
                end
            end
        end
    end

    return false
end

---Handles mouse release events for the shop
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function ShopHandler:handle_mouse_released(x, y, button)
    local shop = self:get_shop()
    if not shop or not shop.drawing then
        return false
    end

    -- Stop dragging if we were dragging
    if shop.drawing.isDraggingPanel or shop.drawing.isDraggingButton then
        shop.drawing.isDraggingPanel = false
        shop.drawing.isDraggingButton = false
        return true
    end

    return false
end

---Handles mouse move events for the shop
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
---@return boolean Whether the input was handled
function ShopHandler:handle_mouse_moved(x, y, dx, dy)
    local shop = self:get_shop()
    if not shop or not shop.drawing then
        return false
    end

    -- Handle panel dragging
    if shop.drawing.isDraggingPanel then
        shop.drawing.position.x = x - shop.drawing.dragOffsetX
        shop.drawing.position.y = y - shop.drawing.dragOffsetY
        return true
    end

    -- Handle shop button dragging
    if shop.drawing.isDraggingButton then
        shop.drawing.buttonPosition.x = x - shop.drawing.dragOffsetX
        shop.drawing.buttonPosition.y = y - shop.drawing.dragOffsetY
        return true
    end

    return false
end

---Handles mouse wheel events for the shop
---@param x number Mouse X position
---@param y number Mouse Y position
---@param wheel number Wheel position
---@return boolean Whether the input was handled    
function ShopHandler:handle_mouse_wheel(x, y, wheel)
    local shop = self:get_shop()
    if not shop or not shop.drawing then
        return false
    end

    -- Only handle wheel events when shop is open
    if not shop.drawing.isOpen then
        return false
    end

    -- Handle scrolling in buy tab
    if shop.drawing.activeTab == "buy" and shop.drawing.selectedCategory then
        local items = shop.core:getCategoryItems(shop.drawing.selectedCategory)
        local item_height = 80
        local visible_items = math.floor((shop.drawing.size.height - 190) / item_height)
        local max_scroll = math.max(0, #items - visible_items)
        
        shop.drawing.scrollOffset = math.max(0, math.min(shop.drawing.scrollOffset - wheel, max_scroll))
        return true
    end

    -- Handle scrolling in sell tab
    if shop.drawing.activeTab == "sell" then
        local items = shop.inventory:getAllItems()
        local item_height = 80
        local visible_items = math.floor((shop.drawing.size.height - 150) / item_height)
        local max_scroll = math.max(0, #items - visible_items)
        
        shop.drawing.sellScrollOffset = math.max(0, math.min(shop.drawing.sellScrollOffset - wheel, max_scroll))
        return true
    end

    return false
end

---Checks if a point is within given bounds
---@param x number Point X position
---@param y number Point Y position
---@param bounds table Bounds to check against
---@return boolean Whether the point is within the bounds
function ShopHandler:is_point_in_bounds(x, y, bounds)
    return x >= bounds.x and x <= bounds.x + bounds.width and
           y >= bounds.y and y <= bounds.y + bounds.height
end

return ShopHandler