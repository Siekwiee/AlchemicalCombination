local love = require("love")
local json = require("src.data.json")

---@class MaterialDataService
local MaterialDataService = {}

---Loads material data from JSON file
---@return boolean success
---@return table|string data
function MaterialDataService:loadMaterialsData()
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
            return false, "Materials data doesn't contain 'materials' field"
        end
        
        return true, materialsData.materials
    else
        return false, tostring(materialsData)
    end
end

return MaterialDataService 