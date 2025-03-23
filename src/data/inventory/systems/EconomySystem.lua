local ItemManagementSystem = require("src.data.inventory.systems.ItemManagementSystem")

---@class EconomySystem
local EconomySystem = {}

---Adds gold to inventory
---@param inventoryComponent InventoryComponent
---@param materialDataComponent MaterialDataComponent
---@param amount number Amount to add
function EconomySystem:addGold(inventoryComponent, materialDataComponent, amount)
    if type(amount) ~= "number" then
        error("Gold amount must be a number")
        return
    end
    
    -- Round to 2 decimal places to avoid floating point errors
    amount = math.floor(amount * 100) / 100
    
    if amount < 0 then
        error("Cannot add negative gold amount")
        return
    end
    
    local currentGold = inventoryComponent:getGold()
    inventoryComponent:setGold(currentGold + amount)
    print("Added " .. amount .. " gold. New total: " .. inventoryComponent:getGold())
end

---Removes gold from inventory
---@param inventoryComponent InventoryComponent
---@param materialDataComponent MaterialDataComponent
---@param amount number Amount to remove
---@return boolean success
function EconomySystem:removeGold(inventoryComponent, materialDataComponent, amount)
    if type(amount) ~= "number" then
        error("Gold amount must be a number")
        return false
    end
    
    -- Round to 2 decimal places to avoid floating point errors
    amount = math.floor(amount * 100) / 100
    
    if amount < 0 then
        error("Cannot remove negative gold amount")
        return false
    end
    
    local currentGold = inventoryComponent:getGold()
    if currentGold < amount then
        print("Not enough gold! Have: " .. currentGold .. ", Need: " .. amount)
        return false
    end
    
    inventoryComponent:setGold(currentGold - amount)
    print("Removed " .. amount .. " gold. New total: " .. inventoryComponent:getGold())
    return true
end

---Sells an item for gold
---@param inventoryComponent InventoryComponent
---@param materialDataComponent MaterialDataComponent
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function EconomySystem:sellItem(inventoryComponent, materialDataComponent, itemId, amount)
    if not itemId then
        error("Cannot sell nil item")
        return false
    end
    
    amount = amount or 1
    
    if not ItemManagementSystem:removeItem(inventoryComponent, itemId, amount) then
        print("Cannot sell " .. amount .. "x " .. itemId .. ": not enough in inventory")
        return false
    end
    
    local value = 0
    local materialData = materialDataComponent:getMaterialData(itemId)
    if materialData then
        value = materialData.value * amount
        -- Apply any selling modifiers here (e.g., sell for 75% of value)
        value = value * 0.75
        -- Round to 2 decimal places
        value = math.floor(value * 100) / 100
    end
    
    self:addGold(inventoryComponent, materialDataComponent, value)
    print("Sold " .. amount .. "x " .. itemId .. " for " .. value .. " gold")
    return true
end

---Buys an item with gold
---@param inventoryComponent InventoryComponent
---@param materialDataComponent MaterialDataComponent
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function EconomySystem:buyItem(inventoryComponent, materialDataComponent, itemId, amount)
    if not itemId then
        error("Cannot buy nil item")
        return false
    end
    
    amount = amount or 1
    
    -- Check if item exists in material data
    local materialData = materialDataComponent:getMaterialData(itemId)
    if not materialData then
        print("Cannot buy unknown item: " .. itemId)
        return false
    end
    
    -- Calculate cost
    local cost = materialData.value * amount
    -- Apply any buying modifiers (e.g. buy for 125% of value)
    cost = cost * 1.25
    -- Round to 2 decimal places
    cost = math.floor(cost * 100) / 100
    
    -- Check if we have enough gold
    if not self:removeGold(inventoryComponent, materialDataComponent, cost) then
        return false
    end
    
    -- Add item to inventory
    ItemManagementSystem:addItem(inventoryComponent, itemId, amount)
    print("Bought " .. amount .. "x " .. itemId .. " for " .. cost .. " gold")
    return true
end

---@param inventoryComponent InventoryComponent
---@return string
function EconomySystem:getFormattedGold(inventoryComponent)
    return string.format("%.2f", inventoryComponent:getGold())
end

return EconomySystem 