---@class InventoryComponent
---@field materials table<string, number> Map of itemId to quantity
---@field gold number Current gold amount
local InventoryComponent = {}

---Creates a new InventoryComponent instance
---@return InventoryComponent
function InventoryComponent:new()
    local o = {
        materials = {},
        gold = 100  -- Starting gold
    }
    setmetatable(o, { __index = self })
    return o
end

---Gets all inventory items
---@return table<string, number> Map of itemId to quantity
function InventoryComponent:getMaterials()
    return self.materials
end

---@return number
function InventoryComponent:getGold()
    return self.gold
end

---@param gold number
function InventoryComponent:setGold(gold)
    self.gold = gold
end

---@param itemId string
---@param amount number
function InventoryComponent:setMaterial(itemId, amount)
    self.materials[itemId] = amount
end

return InventoryComponent 