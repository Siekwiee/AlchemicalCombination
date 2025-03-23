local love = require("love")
local json = require("src.data.json")

---@class Inventory
---@field materials table
---@field materialData table
---@field gold number
local Inventory = {
    materials = {},
    materialData = {},
    gold = 0
}

function Inventory:new()
    local o = {}
    setmetatable(o, { __index = self })
    o.materials = {}
    o.materialData = {}
    o.gold = 100  -- Starting gold
    
    -- Load materials data
    o:loadMaterialsData()
    
    return o
end

function Inventory:loadMaterialsData()
    local success, materialsData
    
    -- Try to load the materials data
    success, materialsData = pcall(function()
        local contents = love.filesystem.read("src/data/materials.json")
        if contents then
            return json.decode(contents)
        end
        return nil
    end)
    
    if success and materialsData then
        self.materialData = materialsData.materials
        return true
    else
        print("Failed to load materials data in Inventory: " .. tostring(materialsData))
        return false
    end
end

---@param itemId string
---@param amount number
function Inventory:addItem(itemId, amount)
    amount = amount or 1
    
    if not self.materials[itemId] then
        self.materials[itemId] = amount
    else
        self.materials[itemId] = self.materials[itemId] + amount
    end
end

---@param itemId string
---@param amount number
---@return boolean
function Inventory:removeItem(itemId, amount)
    amount = amount or 1
    
    if not self.materials[itemId] or self.materials[itemId] < amount then
        return false
    end
    
    self.materials[itemId] = self.materials[itemId] - amount
    return true
end

---@param itemId string
---@return number
function Inventory:getItemCount(itemId)
    return self.materials[itemId] or 0
end

---@param amount number
function Inventory:addGold(amount)
    self.gold = self.gold + amount
end

---@param amount number
---@return boolean
function Inventory:removeGold(amount)
    if self.gold < amount then
        return false
    end
    
    self.gold = self.gold - amount
    return true
end

---@param itemId string
---@param amount number
---@return boolean
function Inventory:sellItem(itemId, amount)
    amount = amount or 1
    
    if not self:removeItem(itemId, amount) then
        return false
    end
    
    local value = 0
    if self.materialData[itemId] then
        value = self.materialData[itemId].value * amount
    end
    
    self:addGold(value)
    return true
end

---@param itemId string
---@param amount number
---@return boolean
function Inventory:buyItem(itemId, amount)
    amount = amount or 1
    
    if not self.materialData[itemId] then
        return false
    end
    
    local cost = self.materialData[itemId].value * amount
    
    if not self:removeGold(cost) then
        return false
    end
    
    self:addItem(itemId, amount)
    return true
end

---@return table
function Inventory:getItems()
    return self.materials
end

---@return table
function Inventory:getItemList()
    local items = {}
    for id, count in pairs(self.materials) do
        if count > 0 then
            table.insert(items, {
                id = id,
                count = count,
                name = self.materialData[id] and self.materialData[id].name or id,
                tier = self.materialData[id] and self.materialData[id].tier or 0,
                value = self.materialData[id] and self.materialData[id].value or 0
            })
        end
    end
    return items
end

return Inventory
