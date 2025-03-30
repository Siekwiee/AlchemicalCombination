local Debug = require("src.core.debug.init")
local InputHandler = require("src.userInput.handlers.InputHandler")

---@class InventoryHandler : InputHandler
---@field game_state GameState Game state reference
local InventoryHandler = setmetatable({}, { __index = InputHandler })
InventoryHandler.__index = InventoryHandler

---Creates a new inventory input handler
---@param game_state GameState Game state reference
---@return InventoryHandler
function InventoryHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

---Handles mouse press events for inventory
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function InventoryHandler:handle_mouse_pressed(x, y, button)
  -- Get inventory
  local inventory = self:get_inventory()
  if not inventory then
    return false
  end
  
  -- Check if inventory is visible
  if not inventory.visible then
    return false
  end
  
  -- Check if click is within inventory bounds
  if not self:is_point_in_inventory(inventory, x, y) then
    return false
  end
  
  -- Handle inventory click
  return self:handle_inventory_click(inventory, x, y, button)
end

---Handles mouse release events for inventory
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function InventoryHandler:handle_mouse_released(x, y, button)
  -- Get inventory
  local inventory = self:get_inventory()
  if not inventory then
    return false
  end
  
  -- Check if inventory is visible
  if not inventory.visible then
    return false
  end
  
  -- Check if click is within inventory bounds
  if not self:is_point_in_inventory(inventory, x, y) then
    return false
  end
  
  -- Handle inventory release
  return self:handle_inventory_release(inventory, x, y, button)
end

---Gets the inventory component from the game state
---@return table|nil The inventory or nil if not found
function InventoryHandler:get_inventory()
  if self.game_state.components and self.game_state.components.inventory then
    return self.game_state.components.inventory
  elseif self.game_state.current_state and self.game_state.current_state.inventory then
    return self.game_state.current_state.inventory
  end
  
  return nil
end

---Checks if a point is within the inventory bounds
---@param inventory table The inventory to check
---@param x number Point X position
---@param y number Point Y position
---@return boolean Whether the point is within the inventory
function InventoryHandler:is_point_in_inventory(inventory, x, y)
  return x >= inventory.x and x <= inventory.x + inventory.width and
         y >= inventory.y and y <= inventory.y + inventory.height
end

---Handles inventory interaction logic
---@param inventory table The inventory to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function InventoryHandler:handle_inventory_click(inventory, x, y, button)
  -- Determine which slot was clicked
  local slot_index = self:get_slot_at_position(inventory, x, y)
  if not slot_index then
    return false
  end
  
  -- Check if the slot has an item
  local item = inventory:get_item_at(slot_index)
  
  -- Left click (select/use item)
  if button == 1 then
    return self:handle_inventory_left_click(inventory, slot_index, item)
  end
  
  -- Right click (info/secondary action)
  if button == 2 then
    return self:handle_inventory_right_click(inventory, slot_index, item)
  end
  
  return false
end

---Handles inventory mouse release events
---@param inventory table The inventory to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function InventoryHandler:handle_inventory_release(inventory, x, y, button)
  -- We could implement drag-and-drop logic here
  return false
end

---Gets the slot index at a given position
---@param inventory table The inventory
---@param x number Mouse X position
---@param y number Mouse Y position
---@return number|nil The slot index or nil if not on a slot
function InventoryHandler:get_slot_at_position(inventory, x, y)
  -- Calculate local coordinates
  local rel_x = x - inventory.x
  local rel_y = y - inventory.y
  
  -- Account for any header/title area
  local content_y = inventory.padding or 0
  if inventory.header_height then
    content_y = content_y + inventory.header_height
  end
  
  -- Check if in content area
  if rel_y < content_y then
    return nil
  end
  
  -- Calculate slot position
  local slot_size = inventory.slot_size or 40
  local slot_padding = inventory.slot_padding or 5
  local slots_per_row = inventory.slots_per_row or 5
  
  local slot_area_x = math.floor(rel_x / (slot_size + slot_padding))
  local slot_area_y = math.floor((rel_y - content_y) / (slot_size + slot_padding))
  
  -- Check if within valid slot range
  if slot_area_x < 0 or slot_area_x >= slots_per_row then
    return nil
  end
  
  -- Calculate slot index
  local slot_index = slot_area_y * slots_per_row + slot_area_x + 1
  
  -- Validate slot index
  if slot_index <= 0 or slot_index > inventory.max_slots then
    return nil
  end
  
  return slot_index
end

---Handles left click on inventory slot
---@param inventory table The inventory
---@param slot_index number Slot index that was clicked
---@param item table|nil Item in the slot, or nil if empty
---@return boolean Whether the input was handled
function InventoryHandler:handle_inventory_left_click(inventory, slot_index, item)
  -- If there's no item, can't do anything
  if not item then
    -- Deselect current selection if any
    if inventory.selected_slot then
      inventory.selected_slot = nil
      self:debug("InventoryHandler - Deselected inventory slot (empty slot clicked)")
      return true
    end
    return false
  end
  
  -- If this slot is already selected, deselect it
  if inventory.selected_slot == slot_index then
    inventory.selected_slot = nil
    self:debug("InventoryHandler - Deselected inventory slot: " .. slot_index)
    return true
  end
  
  -- Select this slot
  inventory.selected_slot = slot_index
  self:debug("InventoryHandler - Selected inventory slot: " .. slot_index .. " with item: " .. (item.name or "unnamed"))
  return true
end

---Handles right click on inventory slot
---@param inventory table The inventory
---@param slot_index number Slot index that was clicked
---@param item table|nil Item in the slot, or nil if empty
---@return boolean Whether the input was handled
function InventoryHandler:handle_inventory_right_click(inventory, slot_index, item)
  -- If there's no item, can't do anything
  if not item then
    return false
  end
  
  -- If the item has a use function, call it
  if item.use then
    local success = item:use(self.game_state)
    if success then
      self:debug("InventoryHandler - Used item: " .. (item.name or "unnamed"))
      
      -- Remove item if it was consumed
      if item.consumed then
        inventory:remove_item_at(slot_index)
      end
      
      return true
    end
  end
  
  -- Show item info (if applicable)
  if inventory.show_item_info then
    inventory:show_item_info(item)
    self:debug("InventoryHandler - Showing info for item: " .. (item.name or "unnamed"))
    return true
  end
  
  return false
end

return InventoryHandler 