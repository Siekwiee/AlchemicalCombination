local ElementData = {}

-- Define all elements
ElementData.elements = {
  water = {
    id = "water",
    name = "Water",
    type = "basic",
    level = 1,
    description = "A basic element representing water",
    color = {0.2, 0.4, 0.8, 1.0}
  },
  fire = {
    id = "fire",
    name = "Fire",
    type = "basic",
    level = 1,
    description = "A basic element representing fire",
    color = {0.9, 0.3, 0.1, 1.0}
  },
  earth = {
    id = "earth",
    name = "Earth",
    type = "basic",
    level = 1,
    description = "A basic element representing earth",
    color = {0.5, 0.3, 0.0, 1.0}
  },
  air = {
    id = "air",
    name = "Air",
    type = "basic",
    level = 1,
    description = "A basic element representing air",
    color = {0.8, 0.8, 0.9, 1.0}
  },
  -- Add any other elements from the JSON file
  -- You can easily add more elements here
}

-- Define all combinations with pre-sorted keys
ElementData.combinations = {
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

-- Function to add a new element
function ElementData.add_element(element)
  if not element or not element.id then
    return false
  end
  
  ElementData.elements[element.id] = element
  return true
end

-- Function to add a new combination
function ElementData.add_combination(element1_id, element2_id, result)
  if not element1_id or not element2_id or not result or not result.id then
    return false
  end
  
  -- Create sorted key
  local inputs = {element1_id, element2_id}
  table.sort(inputs)
  local key = table.concat(inputs, "+")
  
  ElementData.combinations[key] = result
  return true
end

return ElementData 