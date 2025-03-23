local ItemManagementSystem = require("src.data.inventory.systems.ItemManagementSystem")
local EconomySystem = require("src.data.inventory.systems.EconomySystem")
local InventoryComponent = require("src.data.inventory.components.InventoryComponent")
local MaterialDataComponent = require("src.data.inventory.components.MaterialDataComponent")
local MaterialDataService = require("src.data.inventory.services.MaterialDataService")

---@class InventorySystem
---@field inventoryComponent InventoryComponent
---@field materialDataComponent MaterialDataComponent
local InventorySystem = {}

---Creates a new InventorySystem instance
---@return InventorySystem
function InventorySystem:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize components
    o.inventoryComponent = InventoryComponent:new()
    o.materialDataComponent = MaterialDataComponent:new()
    
    -- Load material data
    local success, materialsData = MaterialDataService:loadMaterialsData()
    if success then
        o.materialDataComponent:setMaterialData(materialsData)
    else
        print("Warning: Failed to load materials data. Using defaults. Error: " .. tostring(materialsData))
    end
    
    return o
end

-- Item Management Methods

---Adds item to inventory
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function InventorySystem:addItem(itemId, amount)
    ItemManagementSystem:addItem(self.inventoryComponent, itemId, amount)
end

---Removes item from inventory
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success
function InventorySystem:removeItem(itemId, amount)
    return ItemManagementSystem:removeItem(self.inventoryComponent, itemId, amount)
end

---Gets the count of an item in inventory
---@param itemId string Item identifier
---@return number count
function InventorySystem:getItemCount(itemId)
    return ItemManagementSystem:getItemCount(self.inventoryComponent, itemId)
end

-- Economy Management Methods

---Adds gold to inventory
---@param amount number Amount to add
function InventorySystem:addGold(amount)
    EconomySystem:addGold(self.inventoryComponent, self.materialDataComponent, amount)
end

---Removes gold from inventory
---@param amount number Amount to remove
---@return boolean success
function InventorySystem:removeGold(amount)
    return EconomySystem:removeGold(self.inventoryComponent, self.materialDataComponent, amount)
end

---Sells an item for gold
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function InventorySystem:sellItem(itemId, amount)
    return EconomySystem:sellItem(self.inventoryComponent, self.materialDataComponent, itemId, amount)
end

---Buys an item with gold
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function InventorySystem:buyItem(itemId, amount)
    return EconomySystem:buyItem(self.inventoryComponent, self.materialDataComponent, itemId, amount)
end

-- Data Access Methods

---Gets all inventory items
---@return table items
function InventorySystem:getItems()
    return self.inventoryComponent:getMaterials()
end

---Gets formatted list of items with additional data
---@return table
function InventorySystem:getItemList()
    local items = {}
    local materials = self.inventoryComponent:getMaterials()
    
    for id, count in pairs(materials) do
        if count > 0 then
            local materialData = self.materialDataComponent:getMaterialData(id) or {}
            table.insert(items, {
                id = id,
                count = count,
                name = materialData.name or id,
                tier = materialData.tier or 0,
                value = materialData.value or 0
            })
        end
    end
    return items
end

---@return number
function InventorySystem:getGold()
    return self.inventoryComponent:getGold()
end

---@return string
function InventorySystem:getFormattedGold()
    return EconomySystem:getFormattedGold(self.inventoryComponent)
end

return InventorySystem 