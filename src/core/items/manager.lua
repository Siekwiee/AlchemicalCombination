local Debug = require("src.core.debug.init")
local ItemLoader = require("src.core.items.loader")

local ItemManager = {}
ItemManager.__index = ItemManager

function ItemManager:new()
  local self = setmetatable({}, ItemManager)
  
  -- Initialize
  self.items = {}
  self.combinations = {}
  self:load_data()
  
  return self
end

function ItemManager:load_data()
  -- Load data from Lua module
  self.items = ItemLoader.load_items() or {}
  self.combinations = ItemLoader.load_combinations() or {}
  
  -- Ensure all items have proper color data
  for id, item in pairs(self.items) do
    if not item.color then
      item.color = {1, 1, 1, 1}
    elseif #item.color < 4 then
      -- Add alpha channel if missing
      item.color[4] = item.color[4] or 1.0
    end
    
    -- Set default level if not specified
    item.level = item.level or 1
  end
  
  Debug.debug(Debug, "ItemManager:new: Initialized with " .. self:count_items() .. " items and " .. self:count_combinations() .. " combinations")
end

---Add a new item to the system
---@param item table The item to add
---@return boolean Success or failure
function ItemManager:add_item(item)
  if not item or not item.id then
    return false
  end
  
  -- Add to loader data
  local success = ItemLoader.add_item(item)
  if success then
    -- Also add to local cache
    self.items[item.id] = item
  end
  
  return success
end

---Add a new combination to the system
---@param item1_id string First item ID
---@param item2_id string Second item ID
---@param result table The result item
---@return boolean Success or failure
function ItemManager:add_combination(item1_id, item2_id, result)
  if not item1_id or not item2_id or not result then
    return false
  end
  
  -- Add result item if not already in system
  if result.id and not self.items[result.id] then
    self:add_item(result)
  end
  
  -- Add to loader data
  local success = ItemLoader.add_combination(item1_id, item2_id, result)
  if success then
    -- Also update local cache
    local inputs = {item1_id, item2_id}
    table.sort(inputs)
    local key = table.concat(inputs, "+")
    self.combinations[key] = result
  end
  
  return success
end

---Get an item by ID
---@param id string Item ID
---@return table|nil Item data or nil if not found
function ItemManager:get_item(id)
  return self.items[id]
end

---Get all items
---@return table All items
function ItemManager:get_all_items()
  return self.items
end

---Count the number of items
---@return number Number of items
function ItemManager:count_items()
  local count = 0
  for _ in pairs(self.items) do
    count = count + 1
  end
  return count
end

---Count the number of combinations
---@return number Number of combinations
function ItemManager:count_combinations()
  local count = 0
  for _ in pairs(self.combinations) do
    count = count + 1
  end
  return count
end

---Create an item instance from data
---@param item_id string Item ID
---@return table|nil Item instance or nil if not found
function ItemManager:create_item(item_id)
  local item_data = self:get_item(item_id)
  if not item_data then
    Debug.debug(Debug, "ItemManager:create_item: Item not found: " .. tostring(item_id))
    
    -- If it's a basic item and somehow not in our data, create a generic one
    if item_id == "water" or item_id == "fire" or item_id == "earth" or item_id == "air" then
      local colors = {
        water = {0.2, 0.4, 0.8, 1.0},
        fire = {0.9, 0.3, 0.1, 1.0},
        earth = {0.5, 0.3, 0.0, 1.0},
        air = {0.8, 0.8, 0.9, 1.0}
      }
      
      return {
        id = item_id,
        name = item_id:sub(1,1):upper() .. item_id:sub(2),
        type = "basic",
        level = 1,
        color = colors[item_id] or {1, 1, 1, 1}
      }
    end
    
    return nil
  end
  
  -- Create a deep copy of the item data
  local item = {}
  for k, v in pairs(item_data) do
    if type(v) == "table" then
      item[k] = {}
      for k2, v2 in pairs(v) do
        item[k][k2] = v2
      end
    else
      item[k] = v
    end
  end
  
  -- Ensure color data exists
  if not item.color then
    item.color = {1, 1, 1, 1}
  elseif #item.color < 4 then
    item.color[4] = item.color[4] or 1.0
  end
  
  -- Ensure level exists
  item.level = item.level or 1
  
  return item
end

---Try to combine two items
---@param item1 table First item
---@param item2 table Second item
---@return table|nil Result item or nil if no valid combination
function ItemManager:combine(item1, item2)
  if not item1 or not item2 then
    print("ItemManager:combine - Invalid items (nil values)")
    return nil
  end
  
  print("ItemManager:combine - Attempting to combine: " .. 
        (item1.name or "unnamed") .. " + " .. (item2.name or "unnamed"))
  
  -- Handle same-type combination (level up)
  if item1.id == item2.id then
    local result = self:create_item(item1.id)
    if result and result.level then
      result.level = (item1.level or 1) + 1
      print("ItemManager:combine - Upgraded " .. result.name .. " to level " .. result.level)
      return result
    end
  end
  
  -- Create sorted key for lookup
  local inputs = {item1.id, item2.id}
  table.sort(inputs)
  local key = table.concat(inputs, "+")
  
  print("ItemManager:combine - Looking up combination key: " .. key)
  
  -- Look up combination result
  local result_data = self.combinations[key]
  if result_data then
    print("ItemManager:combine - Created " .. result_data.name .. " from " .. 
          item1.name .. " and " .. item2.name)
    
    -- Make sure we return a proper item by running it through create_item
    if result_data.id then
      local item = self:create_item(result_data.id)
      if item then 
        print("ItemManager:combine - Successfully created: " .. item.name)
        return item 
      end
    end
    
    -- If create_item failed or no id, just return the raw result data
    print("ItemManager:combine - Returning raw result data")
    return result_data
  end
  
  print("ItemManager:combine - No combination found for " .. item1.name .. " + " .. item2.name)
  return nil
end

return ItemManager 