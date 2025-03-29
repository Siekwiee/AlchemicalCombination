local Debug = require("src.core.debug.init")

local ItemLoader = {}

-- Storage for items and combinations
local items_data = {}
local combinations_data = {}

-- Initialize with basic items
function ItemLoader.initialize()
  if next(items_data) ~= nil then
    -- Already initialized
    return
  end
  
  -- Add basic items
  items_data = {
    water = {
      id = "water",
      name = "Water",
      type = "basic",
      level = 1,
      color = {0.2, 0.4, 0.9, 1.0},
      description = "One of the four basic items"
    },
    fire = {
      id = "fire",
      name = "Fire",
      type = "basic",
      level = 1,
      color = {0.9, 0.3, 0.1, 1.0},
      description = "One of the four basic items"
    },
    earth = {
      id = "earth",
      name = "Earth",
      type = "basic",
      level = 1,
      color = {0.5, 0.3, 0.0, 1.0},
      description = "One of the four basic items"
    },
    air = {
      id = "air",
      name = "Air",
      type = "basic",
      level = 1,
      color = {0.8, 0.9, 1.0, 1.0},
      description = "One of the four basic items"
    }
  }
  
  -- Add basic combinations
  combinations_data = {
    ["air+fire"] = {
      id = "energy",
      name = "Energy",
      type = "derived",
      level = 2,
      color = {1.0, 0.8, 0.0, 1.0},
      description = "The force that powers the universe"
    },
    ["earth+water"] = {
      id = "mud",
      name = "Mud",
      type = "derived",
      level = 2,
      color = {0.4, 0.3, 0.2, 1.0},
      description = "Wet earth"
    },
    ["fire+water"] = {
      id = "steam",
      name = "Steam",
      type = "derived",
      level = 2,
      color = {0.8, 0.8, 0.8, 0.7},
      description = "Water vapor"
    },
    ["earth+fire"] = {
      id = "lava",
      name = "Lava",
      type = "derived",
      level = 2,
      color = {0.9, 0.4, 0.0, 1.0},
      description = "Molten rock"
    }
  }
  
  Debug.debug(Debug, "ItemLoader: Initialized with " .. #items_data .. " items and " .. #combinations_data .. " combinations")
end

---Load all item data
---@return table Item data
function ItemLoader.load_items()
  ItemLoader.initialize()
  return items_data
end

---Load all combination data
---@return table Combination data
function ItemLoader.load_combinations()
  ItemLoader.initialize()
  return combinations_data
end

---Add a new item to the system
---@param item table The item to add
---@return boolean Success or failure
function ItemLoader.add_item(item)
  if not item or not item.id then
    Debug.debug(Debug, "ItemLoader.add_item: Invalid item data")
    return false
  end
  
  -- Initialize if needed
  ItemLoader.initialize()
  
  -- Add to items data
  items_data[item.id] = item
  
  Debug.debug(Debug, "ItemLoader.add_item: Added item " .. item.id)
  return true
end

---Add a new combination to the system
---@param item1_id string First item ID
---@param item2_id string Second item ID
---@param result table The result item
---@return boolean Success or failure
function ItemLoader.add_combination(item1_id, item2_id, result)
  if not item1_id or not item2_id or not result then
    Debug.debug(Debug, "ItemLoader.add_combination: Invalid combination data")
    return false
  end
  
  -- Initialize if needed
  ItemLoader.initialize()
  
  -- Create sorted key
  local inputs = {item1_id, item2_id}
  table.sort(inputs)
  local key = table.concat(inputs, "+")
  
  -- Add to combinations data
  combinations_data[key] = result
  
  Debug.debug(Debug, "ItemLoader.add_combination: Added combination " .. key .. " -> " .. result.id)
  return true
end

return ItemLoader 