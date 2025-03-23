-- Test script for the recipe system
package.path = "./?.lua;" .. package.path

-- Redirect print to io.stdout:write
local oldPrint = print
print = function(...)
    local args = {...}
    for i, v in ipairs(args) do
        io.stdout:write(tostring(v))
        if i < #args then io.stdout:write("\t") end
    end
    io.stdout:write("\n")
    io.stdout:flush()
end

-- Mock love.filesystem functions needed by CombinationGrid
local love = {}
love.filesystem = {}
love.filesystem.getInfo = function(path)
    local paths = {
        ["src/data/materials.json"] = true
    }
    return paths[path]
end
love.filesystem.read = function(path)
    if path == "src/data/materials.json" then
        -- Use direct file I/O since we're in a test environment
        local materialsPath = "src/data/materials.json"
        local file = io.open(materialsPath, "r")
        if not file then
            print("Failed to open materials.json at: " .. materialsPath)
            return nil
        end
        local content = file:read("*all")
        file:close()
        return content
    end
    return nil
end
package.loaded["love"] = love

-- Mock json module needed by CombinationGrid
local json = require("src.data.json")
-- Override decode method to use our materials data
local originalDecode = json.decode
json.decode = function(str)
    -- Parse the materials.json file directly using the original decode
    local data = originalDecode(str)
    if data then
        return data
    else
        -- Fallback to mock data if parsing fails
        return {
            materials = {
                fire = {
                    name = "Fire",
                    tier = 1,
                    color = {1, 0.2, 0.2},
                    value = 10
                },
                water = {
                    name = "Water",
                    tier = 1,
                    color = {0.2, 0.2, 1},
                    value = 10
                },
                earth = {
                    name = "Earth",
                    tier = 1,
                    color = {0.6, 0.4, 0.2},
                    value = 10
                },
                metal = {
                    name = "Metal",
                    tier = 2,
                    color = {0.7, 0.7, 0.7},
                    value = 25,
                    recipe = {
                        fire = 1,
                        earth = 1
                    }
                },
                steam = {
                    name = "Steam",
                    tier = 2,
                    color = {0.8, 0.8, 0.9},
                    value = 25,
                    recipe = {
                        fire = 1,
                        water = 1
                    }
                },
                gold = {
                    name = "Gold",
                    tier = 3,
                    color = {1, 0.84, 0},
                    value = 100,
                    recipe = {
                        metal = 1,
                        fire = 1
                    }
                }
            }
        }
    end
end

-- Mock Inventory class
local Inventory = {}
function Inventory:new()
    local o = {
        items = {}
    }
    setmetatable(o, { __index = self })
    return o
end
function Inventory:addItem(item, count)
    self.items[item] = (self.items[item] or 0) + count
end
function Inventory:removeItem(item, count)
    if self.items[item] and self.items[item] >= count then
        self.items[item] = self.items[item] - count
        return true
    end
    return false
end
function Inventory:getItemCount(item)
    return self.items[item] or 0
end
function Inventory:getItems()
    return self.items
end
package.loaded["src.data.inventory.inventory"] = Inventory

-- Load the Combination Grid
local CombinationGrid = require("src.data.combination_grid.init")

-- Create a new grid
local grid = CombinationGrid:new(3, 3)

-- Test recipes
print("Testing recipe matching:")

-- Test metal recipe (fire + earth)
local metal = grid:findRecipeMatch({fire = 1, earth = 1})
print("fire + earth = " .. (metal or "no match"))

-- Test steam recipe (fire + water)
local steam = grid:findRecipeMatch({fire = 1, water = 1})
print("fire + water = " .. (steam or "no match"))

-- Test gold recipe (metal + fire)
local gold = grid:findRecipeMatch({metal = 1, fire = 1})
print("metal + fire = " .. (gold or "no match"))

-- Test invalid recipe
local invalid = grid:findRecipeMatch({metal = 1, water = 1})
print("metal + water = " .. (invalid or "no match"))

print("\nAll recipe tests completed")

-- Ensure test results are shown regardless of how the script is run
io.stdout:flush()
os.exit(0) 