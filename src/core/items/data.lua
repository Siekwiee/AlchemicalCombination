local ItemData = {}

-- Define all items
ItemData.items = {
  water = {
    id = "water",
    name = "Water",
    type = "basic",
    level = 1,
    description = "A basic item representing water",
    color = {0.2, 0.4, 0.8, 1.0}
  },
  fire = {
    id = "fire",
    name = "Fire",
    type = "basic",
    level = 1,
    description = "A basic item representing fire",
    color = {0.9, 0.3, 0.1, 1.0}
  },
  earth = {
    id = "earth",
    name = "Earth",
    type = "basic",
    level = 1,
    description = "A basic item representing earth",
    color = {0.5, 0.3, 0.0, 1.0}
  },
  air = {
    id = "air",
    name = "Air",
    type = "basic",
    level = 1,
    description = "A basic item representing air",
    color = {0.8, 0.8, 0.9, 1.0}
  },
  -- Add any other items from the JSON file
  -- You can easily add more items here
}

-- Define all combinations with pre-sorted keys
ItemData.combinations = {
  ["air+earth"] = {
    id = "dust",
    name = "Dust",
    type = "compound",
    level = 1,
    description = "Fine earth particles suspended in air",
    color = {0.7, 0.6, 0.5, 0.5}
  },
  ["air+fire"] = {
    id = "smoke",
    name = "Smoke",
    type = "compound",
    level = 1,
    description = "Combustion byproduct in air",
    color = {0.3, 0.3, 0.3, 0.8}
  },
  ["air+water"] = {
    id = "cloud",
    name = "Cloud",
    type = "compound",
    level = 1,
    description = "Water vapor suspended in air",
    color = {0.9, 0.9, 0.9, 0.8}
  },
  ["earth+fire"] = {
    id = "lava",
    name = "Lava",
    type = "compound",
    level = 1,
    description = "Molten earth created by combining fire and earth",
    color = {0.9, 0.4, 0.0, 1.0}
  },
  ["earth+water"] = {
    id = "mud",
    name = "Mud",
    type = "compound",
    level = 1,
    description = "Wet earth created by combining earth and water",
    color = {0.4, 0.3, 0.1, 1.0}
  },
  ["fire+water"] = {
    id = "steam",
    name = "Steam",
    type = "compound",
    level = 1,
    description = "Hot water vapor created by combining water and fire",
    color = {0.8, 0.8, 0.8, 0.7}
  },
  -- Add any other combinations from the JSON file
  -- You can easily add more combinations here
}

-- Function to add a new item
function ItemData.add_item(item)
  if not item or not item.id then
    return false
  end
  
  ItemData.items[item.id] = item
  return true
end

-- Function to add a new combination
function ItemData.add_combination(item1_id, item2_id, result)
  if not item1_id or not item2_id or not result or not result.id then
    return false
  end
  
  -- Create sorted key
  local inputs = {item1_id, item2_id}
  table.sort(inputs)
  local key = table.concat(inputs, "+")
  
  ItemData.combinations[key] = result
  return true
end

return ItemData 