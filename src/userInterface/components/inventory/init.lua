local Inventory = require("src.core.items.inventory")
local love = require("love")

---@class UIInventory
---@field visible boolean Whether the inventory is visible
---@field x number X position of the inventory
---@field y number Y position of the inventory
---@field width number Width of the inventory
---@field height number Height of the inventory
---@field slots table Table of inventory slots
---@field selected_slot number|nil Currently selected slot or nil
---@field max_slots number Maximum number of slots
---@field item_manager ItemManager Reference to the item manager
---@field toggle fun(): boolean Toggle inventory visibility
local UIInventory = {}
UIInventory.__index = UIInventory

---Creates a new inventory UI component
---@param config table Configuration table
---@return UIInventory
function UIInventory:new(config)
    local self = setmetatable({}, self)
    
    -- Core inventory
    self.inventory = config.inventory or Inventory:new({
        max_slots = config.max_slots or 10,
        item_manager = config.item_manager
    })
    
    -- UI properties
    self.visible = config.visible ~= false -- Default to visible
    self.enabled = config.enabled or true
    self.x = config.x or 50
    self.y = config.y or 50
    self.title = config.title or "Inventory"
    
    -- Slot styling (different from modular grid to distinguish)
    self.slot_width = config.slot_width or 60
    self.slot_height = config.slot_height or 60
    self.spacing = config.spacing or 10
    self.rows = config.rows or 2
    self.cols = math.ceil(self.inventory.max_slots / self.rows)
    
    -- Calculate total dimensions
    self.width = self.cols * self.slot_width + (self.cols + 1) * self.spacing
    self.height = self.rows * self.slot_height + (self.rows + 1) * self.spacing + 30 -- extra height for title
    
    -- Store reference to input manager
    self.input_manager = config.input_manager
    
    -- Track selected slot
    self.selected_slot = nil
    
    return self
end

---Updates the inventory UI
---@param dt number Delta time
function UIInventory:update(dt)
    if not self.visible or not self.enabled then
        return
    end
end

---Draws the inventory UI
function UIInventory:draw()
    if not self.visible then
        return
    end
    
    -- Draw background
    love.graphics.setColor(0.2, 0.2, 0.25, 0.9)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 10, 10)
    
    -- Draw border
    love.graphics.setColor(0.4, 0.4, 0.45, 1.0)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 10, 10)
    
    -- Draw title
    love.graphics.setColor(0.9, 0.9, 0.9, 1.0)
    local font = love.graphics.getFont()
    love.graphics.print(self.title, self.x + self.width/2 - font:getWidth(self.title)/2, self.y + 10)
    
    -- Draw slots
    for i = 1, self.inventory.max_slots do
        local row = math.ceil(i / self.cols)
        local col = (i - 1) % self.cols + 1
        
        local slot_x = self.x + col * self.spacing + (col - 1) * self.slot_width
        local slot_y = self.y + row * self.spacing + (row - 1) * self.slot_height + 30 -- offset for title
        
        -- Draw slot background
        if self.selected_slot == i then
            love.graphics.setColor(0.4, 0.4, 0.6, 1.0)
        else
            love.graphics.setColor(0.3, 0.3, 0.35, 1.0)
        end
        love.graphics.rectangle("fill", slot_x, slot_y, self.slot_width, self.slot_height, 5, 5)
        
        -- Draw slot border
        love.graphics.setColor(0.5, 0.5, 0.55, 1.0)
        love.graphics.rectangle("line", slot_x, slot_y, self.slot_width, self.slot_height, 5, 5)
        
        -- Draw item if present
        local item = self.inventory:get_item(i)
        if item then
            -- Draw item visual
            love.graphics.setColor(item.color or {1, 1, 1, 1})
            love.graphics.rectangle("fill", 
                slot_x + self.slot_width*0.2, 
                slot_y + self.slot_height*0.2, 
                self.slot_width*0.6, 
                self.slot_height*0.6,
                3, 3)
            
            -- Draw item name
            love.graphics.setColor(0.9, 0.9, 0.9, 1.0)
            local text = item.name or "???"
            local text_width = font:getWidth(text)
            if text_width > self.slot_width - 10 then
                text = text:sub(1, 5) .. ".."
                text_width = font:getWidth(text)
            end
            love.graphics.print(text, 
                slot_x + self.slot_width/2 - text_width/2, 
                slot_y + self.slot_height - 20)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

---Toggles inventory visibility
function UIInventory:toggle()
    self.visible = not self.visible
    return self.visible
end

---Sets inventory visibility
---@param visible boolean Whether the inventory should be visible
function UIInventory:set_visible(visible)
    self.visible = visible
end

---Sets inventory enabled state
---@param enabled boolean Whether the inventory should be enabled
function UIInventory:set_enabled(enabled)
    self.enabled = enabled
end

---Handles mouse pressed events - DEPRECATED, use InputManager InventoryHandler instead
---@deprecated Use InputManager with InventoryHandler instead
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function UIInventory:handle_mouse_pressed(x, y, button)
    -- This method is deprecated and should not be called directly
    -- Input should be handled by the InputManager and InventoryHandler
    return false
end

---Handles mouse released events - DEPRECATED, use InputManager InventoryHandler instead
---@deprecated Use InputManager with InventoryHandler instead
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function UIInventory:handle_mouse_released(x, y, button)
    -- This method is deprecated and should not be called directly
    -- Input should be handled by the InputManager and InventoryHandler
    return false
end

---Gets the item in the currently selected slot (if any)
---@return table|nil The item, or nil if no item selected
function UIInventory:get_selected_item()
    if not self.selected_slot then
        return nil
    end
    
    return self.inventory:get_item(self.selected_slot)
end

---Removes the item from the currently selected slot
---@return table|nil The removed item, or nil if no item was selected
function UIInventory:remove_selected_item()
    if not self.selected_slot then
        return nil
    end
    
    local item = self.inventory:remove_item(self.selected_slot)
    self.selected_slot = nil
    return item
end

---Adds an item to the inventory
---@param item table The item to add
---@return boolean Whether the item was added successfully
function UIInventory:add_item(item)
    -- Use the underlying inventory to add the item
    local success, slot = self.inventory:add_item(item)
    if success then
        -- If successful, return true
        return true
    end
    return false
end

return UIInventory 