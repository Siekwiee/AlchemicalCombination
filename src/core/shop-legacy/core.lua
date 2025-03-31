local love = require("love")

---@class ShopCore
---@field items table Shop items data
---@field availableItems table Available items for purchase
---@field lockedItems table Locked items not yet available
---@field sellableItems table Items player can sell
local ShopCore = {}

---Creates a new ShopCore instance
---@return ShopCore
function ShopCore:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    o.items = {}
    o.availableItems = {}
    o.lockedItems = {}
    o.sellableItems = {}
    
    return o
end

---Loads shop items data from JSON file
---@return boolean success
function ShopCore:loadShopItems()
    local success, shopData
    
    -- Try to load the shop data with pcall for error handling
    success, shopData = pcall(function()
        local contents = love.filesystem.read("/home/siekwie/Documents/Dev/AlchemicalCombination/src/data/shop_items.json")
        if not contents then
            error("Failed to read shop_items.json file")
        end
        
        local decoded = json.decode(contents)
        if not decoded then
            error("Failed to decode shop_items.json")
        end
        
        return decoded
    end)
    
    if success and shopData and type(shopData) == "table" then
        self.items = shopData
        self.availableItems = shopData.available_items or {}
        self.lockedItems = shopData.locked_items or {}
        self.sellableItems = shopData.sellable_items or {}
        return true
    else
        print("Failed to load shop data: " .. tostring(shopData))
        return false
    end
end

---Checks if an item is available for purchase
---@param category string Item category
---@param itemId string Item identifier
---@return boolean
function ShopCore:isItemAvailable(category, itemId)
    return self.availableItems[category] and self.availableItems[category][itemId] ~= nil
end

---Gets the price of an item
---@param category string Item category
---@param itemId string Item identifier
---@return number price
function ShopCore:getItemPrice(category, itemId)
    if self:isItemAvailable(category, itemId) then
        return self.availableItems[category][itemId].price or 0
    end
    return 0
end

---Gets the description of an item
---@param category string Item category
---@param itemId string Item identifier
---@return string description
function ShopCore:getItemDescription(category, itemId)
    if self:isItemAvailable(category, itemId) then
        return self.availableItems[category][itemId].description or ""
    elseif self.lockedItems.default then
        return self.lockedItems.default.description or ""
    end
    return ""
end

---Gets the value of a sellable item
---@param itemId string Item identifier
---@return number value
function ShopCore:getSellableItemValue(itemId)
    if self.sellableItems[itemId] then
        return self.sellableItems[itemId].value or 0
    end
    return 0
end

---Gets all available item categories
---@return table categories
function ShopCore:getAvailableCategories()
    local categories = {}
    for category, _ in pairs(self.availableItems) do
        table.insert(categories, category)
    end
    return categories
end

---Gets all items in a category
---@param category string Category name
---@return table items
function ShopCore:getCategoryItems(category)
    local items = {}
    if self.availableItems[category] then
        for itemId, _ in pairs(self.availableItems[category]) do
            table.insert(items, itemId)
        end
    end
    return items
end

---Gets all sellable items
---@return table items
function ShopCore:getSellableItems()
    local items = {}
    for itemId, _ in pairs(self.sellableItems) do
        table.insert(items, itemId)
    end
    return items
end

return ShopCore
