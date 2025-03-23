---@class InventoryItemManager
local InventoryItemManager = {}

---Adds item to inventory
---@param inventory table The inventory instance
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function InventoryItemManager:addItem(inventory, itemId, amount)
    if not itemId then
        error("Cannot add nil item to inventory")
        return
    end
    
    amount = amount or 1
    
    if not inventory.materials[itemId] then
        inventory.materials[itemId] = amount
    else
        inventory.materials[itemId] = inventory.materials[itemId] + amount
    end
end

---Removes item from inventory
---@param inventory table The inventory instance
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success
function InventoryItemManager:removeItem(inventory, itemId, amount)
    if not itemId then
        error("Cannot remove nil item from inventory")
        return false
    end
    
    amount = amount or 1
    
    if not inventory.materials[itemId] or inventory.materials[itemId] < amount then
        return false
    end
    
    inventory.materials[itemId] = inventory.materials[itemId] - amount
    return true
end

---Gets the count of an item in inventory
---@param inventory table The inventory instance
---@param itemId string Item identifier
---@return number count
function InventoryItemManager:getItemCount(inventory, itemId)
    if not itemId then
        return 0
    end
    
    return inventory.materials[itemId] or 0
end

return InventoryItemManager 