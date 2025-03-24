---@class MaterialDataComponent
---@field materialData table<string, table> Material data indexed by itemId
local MaterialDataComponent = {}

---Creates a new MaterialDataComponent instance
---@return MaterialDataComponent
function MaterialDataComponent:new()
    local o = {
        materialData = {}
    }
    setmetatable(o, { __index = self })
    return o
end

---Sets the material data
---@param data table<string, table> Material data indexed by itemId
function MaterialDataComponent:setMaterialData(data)
    self.materialData = data
end

---Gets material data for an item
---@param itemId string
---@return table|nil
function MaterialDataComponent:getMaterialData(itemId)
    return self.materialData[itemId]
end

---Gets all material data
---@return table<string, table>
function MaterialDataComponent:getAllMaterialData()
    return self.materialData
end

return MaterialDataComponent 