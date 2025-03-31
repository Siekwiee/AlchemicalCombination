-- Event queue not available, using print for events instead
-- local EventQueue = require("src.gamestate.event_queue")

---@class ShopHandlers
---@field core ShopCore Reference to the shop core
---@field inventory Inventory Reference to the player's inventory
local ShopHandlers = {}

---Creates a new ShopHandlers instance
---@param shopCore ShopCore The shop core instance
---@param inventory Inventory The player's inventory
---@return ShopHandlers
function ShopHandlers:new(shopCore, inventory)
    local o = {}
    setmetatable(o, { __index = self })
    
    o.core = shopCore
    o.inventory = inventory
    
    return o
end

---Handles purchasing an item
---@param category string Item category
---@param itemId string Item identifier
---@param amount number Amount to purchase (default: 1)
---@return boolean success
---@return string message
function ShopHandlers:purchaseItem(category, itemId, amount)
    amount = amount or 1
    
    -- Check if item is available
    if not self.core:isItemAvailable(category, itemId) then
        return false, "Item not available for purchase"
    end
    
    -- Get item price
    local price = self.core:getItemPrice(category, itemId) * amount
    
    -- Check if player has enough gold
    if self.inventory:getGold() < price then
        return false, "Not enough gold"
    end
    
    -- Process the purchase
    local success = self.inventory:removeGold(price)
    if not success then
        return false, "Failed to remove gold"
    end
    
    -- Add the item to inventory
    self.inventory:addItem(itemId, amount)
    
    -- Log purchase event instead of using EventQueue
    print("Shop: Purchased " .. amount .. " " .. itemId .. " for " .. price .. " gold")
    
    return true, "Purchase successful"
end

---Handles selling an item
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
---@return string message
function ShopHandlers:sellItem(itemId, amount)
    amount = amount or 1
    
    -- Check if item is sellable
    local value = self.core:getSellableItemValue(itemId)
    if value <= 0 then
        return false, "Item cannot be sold"
    end
    
    -- Check if player has enough of the item
    if self.inventory:getItemCount(itemId) < amount then
        return false, "Not enough items to sell"
    end
    
    -- Process the sale
    local success = self.inventory:removeItem(itemId, amount)
    if not success then
        return false, "Failed to remove item from inventory"
    end
    
    -- Add gold to inventory
    local totalValue = value * amount
    self.inventory:addGold(totalValue)
    
    -- Log sell event instead of using EventQueue
    print("Shop: Sold " .. amount .. " " .. itemId .. " for " .. totalValue .. " gold")
    
    return true, "Sale successful"
end

---Checks if an item can be purchased
---@param category string Item category
---@param itemId string Item identifier
---@param amount number Amount to check (default: 1)
---@return boolean canPurchase
---@return string message
function ShopHandlers:canPurchaseItem(category, itemId, amount)
    amount = amount or 1
    
    -- Check if item is available
    if not self.core:isItemAvailable(category, itemId) then
        return false, "Item not available for purchase"
    end
    
    -- Get item price
    local price = self.core:getItemPrice(category, itemId) * amount
    
    -- Check if player has enough gold
    if self.inventory:getGold() < price then
        return false, "Not enough gold"
    end
    
    return true, ""
end

---Checks if an item can be sold
---@param itemId string Item identifier
---@param amount number Amount to check (default: 1)
---@return boolean canSell
---@return string message
function ShopHandlers:canSellItem(itemId, amount)
    amount = amount or 1
    
    -- Check if item is sellable
    local value = self.core:getSellableItemValue(itemId)
    if value <= 0 then
        return false, "Item cannot be sold"
    end
    
    -- Check if player has enough of the item
    if self.inventory:getItemCount(itemId) < amount then
        return false, "Not enough items to sell"
    end
    
    return true, ""
end

return ShopHandlers
