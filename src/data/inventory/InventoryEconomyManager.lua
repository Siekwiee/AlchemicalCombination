local InventoryItemManager = require("src.data.inventory.InventoryItemManager")

---@class InventoryEconomyManager
local InventoryEconomyManager = {}

---Adds gold to inventory
---@param inventory table The inventory instance
---@param amount number Amount to add
function InventoryEconomyManager:addGold(inventory, amount)
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
    
    inventory.gold = inventory.gold + amount
    print("Added " .. amount .. " gold. New total: " .. inventory.gold)
end

---Removes gold from inventory
---@param inventory table The inventory instance
---@param amount number Amount to remove
---@return boolean success
function InventoryEconomyManager:removeGold(inventory, amount)
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
    
    if inventory.gold < amount then
        print("Not enough gold! Have: " .. inventory.gold .. ", Need: " .. amount)
        return false
    end
    
    inventory.gold = inventory.gold - amount
    print("Removed " .. amount .. " gold. New total: " .. inventory.gold)
    return true
end

---Sells an item for gold
---@param inventory table The inventory instance
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function InventoryEconomyManager:sellItem(inventory, itemId, amount)
    if not itemId then
        error("Cannot sell nil item")
        return false
    end
    
    amount = amount or 1
    
    if not InventoryItemManager:removeItem(inventory, itemId, amount) then
        print("Cannot sell " .. amount .. "x " .. itemId .. ": not enough in inventory")
        return false
    end
    
    local value = 0
    if inventory.materialData[itemId] then
        value = inventory.materialData[itemId].value * amount
        -- Apply any selling modifiers here (e.g., sell for 75% of value)
        value = value * 0.75
        -- Round to 2 decimal places
        value = math.floor(value * 100) / 100
    end
    
    self:addGold(inventory, value)
    print("Sold " .. amount .. "x " .. itemId .. " for " .. value .. " gold")
    return true
end

---Buys an item with gold
---@param inventory table The inventory instance
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function InventoryEconomyManager:buyItem(inventory, itemId, amount)
    if not itemId then
        error("Cannot buy nil item")
        return false
    end
    
    amount = amount or 1
    
    -- Check if item exists in material data
    if not inventory.materialData[itemId] then
        print("Cannot buy unknown item: " .. itemId)
        return false
    end
    
    -- Calculate cost
    local cost = inventory.materialData[itemId].value * amount
    -- Apply any buying modifiers (e.g. buy for 125% of value)
    cost = cost * 1.25
    -- Round to 2 decimal places
    cost = math.floor(cost * 100) / 100
    
    -- Check if we have enough gold
    if not self:removeGold(inventory, cost) then
        return false
    end
    
    -- Add item to inventory
    InventoryItemManager:addItem(inventory, itemId, amount)
    print("Bought " .. amount .. "x " .. itemId .. " for " .. cost .. " gold")
    return true
end

return InventoryEconomyManager 