local love = require("love")
local json = require("src.data.json")

---@class InventoryCore
---@field materials table
---@field materialData table
---@field gold number
local InventoryCore = {
    materials = {},
    materialData = {},
    gold = 0
}

---Creates a new InventoryCore instance
---@return InventoryCore
function InventoryCore:new()
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
function InventoryCore:loadMaterialsData()
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
        print("Failed to load materials data in InventoryCore: " .. tostring(materialsData))
        return false
    end
end

---Gets all inventory items
---@return table items
function InventoryCore:getItems()
    return self.materials
end

---@return table
function InventoryCore:getItemList()
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
function InventoryCore:getGold()
    return self.gold
end

---@return string
function InventoryCore:getFormattedGold()
    return string.format("%.2f", self.gold)
end

return InventoryCore 