---@class ItemManagementSystem
local ItemManagementSystem = {}

---Adds item to inventory
---@param inventoryComponent InventoryComponent
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function ItemManagementSystem:addItem(inventoryComponent, itemId, amount)
    if not itemId then
        error("Cannot add nil item to inventory")
        return
    end
    
    amount = amount or 1
    
    local materials = inventoryComponent:getMaterials()
    local currentAmount = materials[itemId] or 0
    inventoryComponent:setMaterial(itemId, currentAmount + amount)
end

---Removes item from inventory
---@param inventoryComponent InventoryComponent
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success
function ItemManagementSystem:removeItem(inventoryComponent, itemId, amount)
    if not itemId then
        error("Cannot remove nil item from inventory")
        return false
    end
    
    amount = amount or 1
    
    local materials = inventoryComponent:getMaterials()
    local currentAmount = materials[itemId] or 0
    
    if currentAmount < amount then
        return false
    end
    
    inventoryComponent:setMaterial(itemId, currentAmount - amount)
    return true
end

---Gets the count of an item in inventory
---@param inventoryComponent InventoryComponent
---@param itemId string Item identifier
---@return number count
function ItemManagementSystem:getItemCount(inventoryComponent, itemId)
    if not itemId then
        return 0
    end
    
    local materials = inventoryComponent:getMaterials()
    return materials[itemId] or 0
end

return ItemManagementSystem 