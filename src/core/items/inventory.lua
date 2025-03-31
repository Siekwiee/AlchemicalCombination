local ItemManager = require("src.core.items.manager")

local Inventory = {}
Inventory.__index = Inventory

---Creates a new inventory
---@param config table Configuration table with max_slots, etc.
---@return table New inventory instance
function Inventory:new(config)
    local self = setmetatable({}, Inventory)
    
    -- Initialize properties
    self.slots = {}
    self.max_slots = config.max_slots or 10
    self.item_manager = config.item_manager or ItemManager:new()
    
    -- Initialize empty slots
    for i = 1, self.max_slots do
        self.slots[i] = nil
    end
    
    return self
end

---Adds an item to the inventory
---@param item table The item to add
---@return boolean, number Whether the item was added successfully and the slot index where it was added
function Inventory:add_item(item)
    if not item then
        print("Inventory:add_item - Item is nil")
        return false, nil
    end
    
    print("Inventory:add_item - Adding " .. (item.name or "unnamed") .. " to inventory")
    
    -- Find the first empty slot
    for i = 1, self.max_slots do
        if not self.slots[i] then
            self.slots[i] = item
            print("Inventory:add_item - Added " .. (item.name or "unnamed") .. " to slot " .. i)
            return true, i
        end
    end
    
    print("Inventory:add_item - Failed to add item, inventory full")
    return false, nil
end

---Removes an item from a specific slot
---@param slot_index number The slot to remove from
---@return table|nil The removed item, or nil if the slot was empty
function Inventory:remove_item(slot_index)
    if slot_index < 1 or slot_index > self.max_slots then
        return nil
    end
    
    local item = self.slots[slot_index]
    if item then
        self.slots[slot_index] = nil
    end
    
    return item
end

---Gets an item from a specific slot without removing it
---@param slot_index number The slot to get from
---@return table|nil The item, or nil if the slot is empty
function Inventory:get_item(slot_index)
    if slot_index < 1 or slot_index > self.max_slots then
        return nil
    end
    
    return self.slots[slot_index]
end

---Gets all items in the inventory
---@return table A table of items indexed by slot
function Inventory:get_all_items()
    return self.slots
end

---Checks if the inventory is full
---@return boolean Whether the inventory is full
function Inventory:is_full()
    for i = 1, self.max_slots do
        if not self.slots[i] then
            return false
        end
    end
    
    return true
end

---Gets the number of items in the inventory
---@return number The number of items
function Inventory:get_item_count()
    local count = 0
    for i = 1, self.max_slots do
        if self.slots[i] then
            count = count + 1
        end
    end
    
    return count
end

---Finds the slot index of a specific item
---@param item table The item to find
---@return number|nil The slot index, or nil if not found
function Inventory:find_item(item)
    for i = 1, self.max_slots do
        if self.slots[i] and self.slots[i].id == item.id then
            return i
        end
    end
    
    return nil
end

return Inventory 