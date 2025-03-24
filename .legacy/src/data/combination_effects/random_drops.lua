local RandomDrops = {}

-- Table storing drop configurations
-- Format: { recipeResult = { {item = "itemId", chance = 0.01} } }
RandomDrops.dropConfigs = {}

-- Store effects manager reference
RandomDrops.effectsManager = nil

-- Set the effects manager
---@param effectsManager table The effects manager instance
function RandomDrops.setEffectsManager(effectsManager)
    RandomDrops.effectsManager = effectsManager
    print("RandomDrops: Effects manager set")
end

-- Initialize default drop configurations
function RandomDrops.initializeDefaultDrops()
    -- Default configurations are now loaded from materials.json
    -- This method remains for backward compatibility
end

-- Load configurations from materials data
---@param materialsData table The materials data from materials.json
function RandomDrops.loadFromMaterialsData(materialsData)
    -- Clear existing configurations
    RandomDrops.dropConfigs = {}
    
    local configCount = 0
    
    -- Check each material for random_drops field
    for materialId, materialData in pairs(materialsData) do
        if materialData.random_drops then
            for _, dropConfig in ipairs(materialData.random_drops) do
                RandomDrops.addDropConfig(materialId, dropConfig.item, dropConfig.chance)
                configCount = configCount + 1
            end
        end
    end
    
    print("RandomDrops: Loaded " .. configCount .. " drop configurations from materials data")
end

-- Add a drop configuration
---@param recipeResult string The recipe result that triggers this drop chance
---@param itemId string The item that has a chance to drop
---@param chance number Chance between 0 and 1 (e.g., 0.01 = 1%)
function RandomDrops.addDropConfig(recipeResult, itemId, chance)
    if not RandomDrops.dropConfigs[recipeResult] then
        RandomDrops.dropConfigs[recipeResult] = {}
    end
    
    table.insert(RandomDrops.dropConfigs[recipeResult], {
        item = itemId,
        chance = chance
    })
    
    print("Added random drop config: " .. itemId .. " has " .. (chance * 100) .. "% chance when crafting " .. recipeResult)
end

-- Remove a drop configuration
---@param recipeResult string The recipe result
---@param itemId string The item to remove from drop table
function RandomDrops.removeDropConfig(recipeResult, itemId)
    if not RandomDrops.dropConfigs[recipeResult] then
        return
    end
    
    for i, config in ipairs(RandomDrops.dropConfigs[recipeResult]) do
        if config.item == itemId then
            table.remove(RandomDrops.dropConfigs[recipeResult], i)
            print("Removed random drop config: " .. itemId .. " from " .. recipeResult)
            return
        end
    end
end

-- Process drops for a recipe result
---@param recipeResult string The recipe result
---@param inventory table The inventory to add drops to
---@param x number X position for visual effects 
---@param y number Y position for visual effects
---@return table items Array of items that were dropped
---@return boolean hadLuckyDrop Whether any lucky drops occurred
function RandomDrops.processDrops(recipeResult, inventory, x, y)
    local droppedItems = {}
    local hadLuckyDrop = false
    
    if not RandomDrops.dropConfigs[recipeResult] then
        return droppedItems, hadLuckyDrop
    end
    
    for _, config in ipairs(RandomDrops.dropConfigs[recipeResult]) do
        if math.random() < config.chance then
            -- Add item to inventory
            inventory:addItem(config.item, 1)
            
            -- Get item name (if available in inventory system)
            local itemName = config.item
            if inventory.system and inventory.system.materialDataComponent then
                local materialData = inventory.system.materialDataComponent:getMaterialData(config.item)
                if materialData and materialData.name then
                    itemName = materialData.name
                end
            end
            
            print("Lucky! Random drop occurred: " .. itemName)
            table.insert(droppedItems, config.item)
            hadLuckyDrop = true
            
            -- We'll let the calling code handle visualizing the drop
            -- since we're now integrating with the combination effect
        end
    end
    
    return droppedItems, hadLuckyDrop
end

-- Initialize default configurations (kept for backward compatibility)
RandomDrops.initializeDefaultDrops()

return RandomDrops 