local Transformations = require("src.data.combination_effects.transformations")
local RandomDrops = require("src.data.combination_effects.random_drops")

local SpecialCombinations = {}

-- Configure additional random drop chances
function SpecialCombinations.setupRandomDrops()
    -- Random drops are now configured in materials.json
    -- This function remains for backward compatibility
    print("SpecialCombinations: Random drops now configured via materials.json")
end

---Handle seed + water combination
---@param grid CombinationGrid The grid instance
---@param element1 string First element ID
---@param element2 string Second element ID
---@param targetRow number Target row for the result
---@param targetCol number Target column for the result
---@return boolean handled Whether a special combination was handled
function SpecialCombinations.seedAndWater(grid, element1, element2, targetRow, targetCol)
    if (element1 == "seed" and element2 == "water") or (element1 == "water" and element2 == "seed") then
        -- Place a seed in the target cell
        grid.grid[targetRow][targetCol] = { element = "seed" }
        
        -- Start seed transformation
        SpecialCombinations.startSeedTransformation(grid, targetRow, targetCol)
        
        print("Special combination started: Seed + Water at " .. targetRow .. "," .. targetCol)
        return true
    end
    
    return false
end

---Start a seed transformation process
---@param grid CombinationGrid The grid instance
---@param row number Grid row
---@param col number Grid column
function SpecialCombinations.startSeedTransformation(grid, row, col)
    -- Create transformation data
    local duration = 30 -- 30 seconds transformation time
    local transformation = Transformations.create(
        "seed_to_plant", 
        row, 
        col, 
        duration, 
        "plant"
    )
    
    -- Ensure the seed is in the grid
    if not grid.grid[row][col] or grid.grid[row][col].element ~= "seed" then
        grid.grid[row][col] = { element = "seed" }
    end
    
    -- Add transformation to grid and list
    Transformations.add(grid, transformation)
    
    print("Started seed transformation at " .. row .. "," .. col .. " with " .. transformation.timeRemaining .. " seconds remaining")
end

---Handle special combinations between elements
---@param grid CombinationGrid The grid instance
---@param element1 string First element ID
---@param element2 string Second element ID
---@param targetRow number Target row for the result
---@param targetCol number Target column for the result
---@return boolean handled Whether a special combination was handled
function SpecialCombinations.handle(grid, element1, element2, targetRow, targetCol)
    -- Handle seed + water combination
    if SpecialCombinations.seedAndWater(grid, element1, element2, targetRow, targetCol) then
        return true
    end
    
    -- Add more special combinations here
    
    -- No special combination found
    return false
end

-- Call setup function for backward compatibility
SpecialCombinations.setupRandomDrops()

return SpecialCombinations 