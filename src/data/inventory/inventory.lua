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

---Creates a new Inventory instance
---@return Inventory
function Inventory:new()
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize with default values
    o.materials = {}
    o.materialData = {}
    o.gold = 100  -- Starting gold
    
    -- Load materials data
    if not o:loadMaterialsData() then
        print("Warning: Failed to load materials data. Using defaults.")
    end
    
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

---Adds item to inventory
---@param itemId string Item identifier
---@param amount number Amount to add (default: 1)
function Inventory:addItem(itemId, amount)
    if not itemId then
        error("Cannot add nil item to inventory")
        return
    end
    
    amount = amount or 1
    
    if not self.materials[itemId] then
        self.materials[itemId] = amount
    else
        self.materials[itemId] = self.materials[itemId] + amount
    end
end

---Removes item from inventory
---@param itemId string Item identifier
---@param amount number Amount to remove (default: 1)
---@return boolean success
function Inventory:removeItem(itemId, amount)
    if not itemId then
        error("Cannot remove nil item from inventory")
        return false
    end
    
    amount = amount or 1
    
    if not self.materials[itemId] or self.materials[itemId] < amount then
        return false
    end
    
    self.materials[itemId] = self.materials[itemId] - amount
    return true
end

---Gets the count of an item in inventory
---@param itemId string Item identifier
---@return number count
function Inventory:getItemCount(itemId)
    if not itemId then
        return 0
    end
    
    return self.materials[itemId] or 0
end

---Adds gold to inventory
---@param amount number Amount to add
function Inventory:addGold(amount)
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
    
    self.gold = self.gold + amount
    print("Added " .. amount .. " gold. New total: " .. self.gold)
end

---Removes gold from inventory
---@param amount number Amount to remove
---@return boolean success
function Inventory:removeGold(amount)
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
    
    if self.gold < amount then
        print("Not enough gold! Have: " .. self.gold .. ", Need: " .. amount)
        return false
    end
    
    self.gold = self.gold - amount
    print("Removed " .. amount .. " gold. New total: " .. self.gold)
    return true
end

---Sells an item for gold
---@param itemId string Item identifier
---@param amount number Amount to sell (default: 1)
---@return boolean success
function Inventory:sellItem(itemId, amount)
    if not itemId then
        error("Cannot sell nil item")
        return false
    end
    
    amount = amount or 1
    
    if not self:removeItem(itemId, amount) then
        print("Cannot sell " .. amount .. "x " .. itemId .. ": not enough in inventory")
        return false
    end
    
    local value = 0
    if self.materialData[itemId] then
        value = self.materialData[itemId].value * amount
        -- Apply any selling modifiers here (e.g., sell for 75% of value)
        value = value * 0.75
        -- Round to 2 decimal places
        value = math.floor(value * 100) / 100
    end
    
    self:addGold(value)
    print("Sold " .. amount .. "x " .. itemId .. " for " .. value .. " gold")
    return true
end

---Buys an item with gold
---@param itemId string Item identifier
---@param amount number Amount to buy (default: 1)
---@return boolean success
function Inventory:buyItem(itemId, amount)
    if not itemId then
        error("Cannot buy nil item")
        return false
    end
    
    amount = amount or 1
    
    -- Check if item exists in material data
    if not self.materialData[itemId] then
        print("Cannot buy unknown item: " .. itemId)
        return false
    end
    
    -- Calculate cost
    local cost = self.materialData[itemId].value * amount
    -- Apply any buying modifiers (e.g. buy for 125% of value)
    cost = cost * 1.25
    -- Round to 2 decimal places
    cost = math.floor(cost * 100) / 100
    
    -- Check if we have enough gold
    if not self:removeGold(cost) then
        return false
    end
    
    -- Add item to inventory
    self:addItem(itemId, amount)
    print("Bought " .. amount .. "x " .. itemId .. " for " .. cost .. " gold")
    return true
end

---Gets all inventory items
---@return table items
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

---@return number
function Inventory:getGold()
    return self.gold
end

---@return string
function Inventory:getFormattedGold()
    return string.format("%.2f", self.gold)
end

return Inventory
