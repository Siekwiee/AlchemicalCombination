local love = require("love")
local json = require("src.data.json")
local InventoryCore = require("src.data.inventory.InventoryCore")
local InventoryItemManager = require("src.data.inventory.InventoryItemManager")
local InventoryEconomyManager = require("src.data.inventory.InventoryEconomyManager")

---@class Inventory
---@field core InventoryCore
local Inventory = {}

---Creates a new Inventory instance
---@return Inventory
function Inventory:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize with core components
    o.core = InventoryCore:new()
    
    return o
end

---Loads material data from JSON file
---@return boolean success
function Inventory:loadMaterialsData()
    local success, materialsData
    
    -- Try to load the materials data with pcall for error handling
    success, materialsData = pcall(function()
        local contents = love.filesystem.read("src/data/materials.json")
        if not contents then
            error("Failed to read materials.json file")
        end
        
        local decoded = json.decode(contents)
        if not decoded then
            error("Failed to decode materials.json")
        end
        
        return decoded
    end)
    
    if success and materialsData then
        if not materialsData.materials then
            print("Warning: Materials data doesn't contain 'materials' field")
            return false
        end
        
        self.materialData = materialsData.materials
        return true
    else
        print("Failed to load materials data in Inventory: " .. tostring(materialsData))
        return false
    end
end

-- Item Management Methods (forwarding to ItemManager)

---Adds item to inventory
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function Inventory:addItem(itemId, amount)
    InventoryItemManager:addItem(self.core, itemId, amount)
end

---Removes item from inventory
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success
function Inventory:removeItem(itemId, amount)
    return InventoryItemManager:removeItem(self.core, itemId, amount)
end

---Gets the count of an item in inventory
---@param itemId string Item identifier
---@return number count
function Inventory:getItemCount(itemId)
    return InventoryItemManager:getItemCount(self.core, itemId)
end

-- Economy Management Methods (forwarding to EconomyManager)

---Adds gold to inventory
---@param amount number Amount to add
function Inventory:addGold(amount)
    InventoryEconomyManager:addGold(self.core, amount)
end

---Removes gold from inventory
---@param amount number Amount to remove
---@return boolean success
function Inventory:removeGold(amount)
    return InventoryEconomyManager:removeGold(self.core, amount)
end

---Sells an item for gold
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function Inventory:sellItem(itemId, amount)
    return InventoryEconomyManager:sellItem(self.core, itemId, amount)
end

---Buys an item with gold
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function Inventory:buyItem(itemId, amount)
    return InventoryEconomyManager:buyItem(self.core, itemId, amount)
end

-- Data Access Methods (forwarding to Core)

---Gets all inventory items
---@return table items
function Inventory:getItems()
    return self.core:getItems()
end

---@return table
function Inventory:getItemList()
    return self.core:getItemList()
end

---@return number
function Inventory:getGold()
    return self.core:getGold()
end

---@return string
function Inventory:getFormattedGold()
    return self.core:getFormattedGold()
end

return Inventory
