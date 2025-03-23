local love = require("love")
local json = require("src.data.json")
local InventorySystem = require("src.data.inventory.systems.InventorySystem")

---@class Inventory
---@field system InventorySystem
local Inventory = {}

---Creates a new Inventory instance
---@return Inventory
function Inventory:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize with the new ECS-based inventory system
    o.system = InventorySystem:new()
    
    return o
end

---Loads material data from JSON file
---@deprecated Use the system's initialization which automatically loads material data
---@return boolean success
function Inventory:loadMaterialsData()
    print("Warning: loadMaterialsData() is deprecated. Material data is now loaded automatically during initialization.")
    return true -- Always return success since data loading is handled by the system
end

-- Item Management Methods (forwarding to the system)

---Adds item to inventory
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function Inventory:addItem(itemId, amount)
    self.system:addItem(itemId, amount)
end

---Removes item from inventory
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success Whether the removal was successful
function Inventory:removeItem(itemId, amount)
    return self.system:removeItem(itemId, amount)
end

---Gets the count of an item in inventory
---@param itemId string Item identifier
---@return number count
function Inventory:getItemCount(itemId)
    return self.system:getItemCount(itemId)
end

-- Economy Management Methods (forwarding to the system)

---Adds gold to inventory
---@param amount number Amount to add
function Inventory:addGold(amount)
    self.system:addGold(amount)
end

---Removes gold from inventory
---@param amount number Amount to remove
---@return boolean success
function Inventory:removeGold(amount)
    return self.system:removeGold(amount)
end

---Sells an item for gold
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function Inventory:sellItem(itemId, amount)
    return self.system:sellItem(itemId, amount)
end

---Buys an item with gold
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function Inventory:buyItem(itemId, amount)
    return self.system:buyItem(itemId, amount)
end

-- Data Access Methods (forwarding to the system)

---Gets all inventory items
---@return table items
function Inventory:getItems()
    return self.system:getItems()
end

---@return table
function Inventory:getItemList()
    return self.system:getItemList()
end

---@return number
function Inventory:getGold()
    return self.system:getGold()
end

---@return string
function Inventory:getFormattedGold()
    return self.system:getFormattedGold()
end

return Inventory
