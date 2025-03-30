local Debug = require("src.core.debug.init")
local InputHandler = require("src.userInput.handlers.InputHandler")

---@class GridHandler : InputHandler
---@field game_state GameState Game state reference
local GridHandler = setmetatable({}, { __index = InputHandler })
GridHandler.__index = GridHandler

---Creates a new grid input handler
---@param game_state GameState Game state reference
---@return GridHandler
function GridHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

---Handles mouse press events in grid
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was pressed
---@return boolean Whether the input was handled
function GridHandler:handle_mouse_pressed(x, y, button)
  -- Check if we have a grid to interact with
  local grid = self:get_active_grid()
  if not grid then
    return false
  end
  
  -- Check if the click is within grid bounds
  if not self:is_point_in_grid(grid, x, y) then
    return false
  end
  
  -- Process the grid click
  return self:handle_grid_click(grid, x, y, button)
end

---Handles mouse release events for grid
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function GridHandler:handle_mouse_released(x, y, button)
  -- Not currently handling mouse releases for grid
  return false
end

---Gets the currently active grid from the game state
---@return table|nil The active grid or nil if not found
function GridHandler:get_active_grid()
  -- Get grid from components or current state
  if self.game_state.components and self.game_state.components.grid then
    return self.game_state.components.grid
  elseif self.game_state.current_state and self.game_state.current_state.grid then
    return self.game_state.current_state.grid
  end
  
  return nil
end

---Checks if a point is within the grid bounds
---@param grid table The grid to check
---@param x number Point X position
---@param y number Point Y position
---@return boolean Whether the point is within the grid
function GridHandler:is_point_in_grid(grid, x, y)
  -- Convert to local grid coordinates
  local rel_x = x - grid.x
  local rel_y = y - grid.y
  
  -- Check if inside grid bounds
  return rel_x >= 0 and rel_x <= grid.width and
         rel_y >= 0 and rel_y <= grid.height
end

---Handles grid interaction logic
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function GridHandler:handle_grid_click(grid, x, y, button)
  -- Convert to local grid coordinates
  local rel_x = x - grid.x
  local rel_y = y - grid.y
  
  -- Check if click is within grid bounds (redundant but safe)
  if rel_x < 0 or rel_x > grid.width or 
     rel_y < 0 or rel_y > grid.height then
    self:debug("GridHandler:handle_grid_click - Click outside grid bounds")
    
    -- Clear selection if clicking outside
    if grid.selected_cell then
      grid.selected_cell.active = false
      grid.selected_cell = nil
    end
    return false
  end
  
  -- Calculate cell position
  local col = math.floor(rel_x / (grid.cell_width + grid.spacing)) + 1
  local row = math.floor(rel_y / (grid.cell_height + grid.spacing)) + 1
  
  -- Validate cell position
  if row < 1 or row > grid.rows or col < 1 or col > grid.cols then
    self:debug("GridHandler:handle_grid_click - Invalid cell position")
    return false
  end
  
  local cell = grid:get_cell_at(row, col)
  if not cell then
    self:debug("GridHandler:handle_grid_click - No cell found at position")
    return false
  end
  
  -- Handle right-click (transfer to inventory)
  if button == 2 then
    return self:handle_right_click(grid, cell)
  end
  
  -- Handle left-click (selection and combination)
  if button == 1 then
    return self:handle_left_click(grid, cell)
  end
  
  return false
end

---Handles right-click actions on grid cells (typically item transfer to inventory)
---@param grid table The grid containing the cell
---@param cell table The clicked cell
---@return boolean Whether the input was handled
function GridHandler:handle_right_click(grid, cell)
  if not cell.item then
    return false
  end
  
  self:debug("GridHandler:handle_right_click - Right click on item: " .. (cell.item.name or "unnamed"))
  
  -- Get reference to inventory from game state
  local inventory = self:get_inventory()
  if not inventory then
    self:debug("GridHandler:handle_right_click - No inventory found")
    return false
  end
  
  -- Store item reference and remove from cell
  local item = cell.item
  cell.item = nil
  
  -- Try to add to inventory
  local success = inventory:add_item(item)
  if success then
    self:debug("GridHandler:handle_right_click - Successfully transferred item to inventory")
    return true
  else
    -- Put item back if transfer failed
    cell.item = item
    self:debug("GridHandler:handle_right_click - Failed to transfer item to inventory")
    return false
  end
end

---Handles left-click actions on grid cells (selection and combination)
---@param grid table The grid containing the cell
---@param cell table The clicked cell
---@return boolean Whether the input was handled
function GridHandler:handle_left_click(grid, cell)
  -- If we have a selected inventory item, try to place it
  local inventory = self:get_inventory()
  if inventory and inventory.selected_slot then
    local item = inventory:get_selected_item()
    if item and not cell.item then
      -- Remove from inventory and add to grid
      item = inventory:remove_selected_item()
      cell.item = item
      self:debug("GridHandler:handle_left_click - Placed inventory item in grid")
      return true
    end
    return false
  end
  
  -- If we already have a selected cell
  if grid.selected_cell then
    -- If clicking the same cell, deselect it
    if grid.selected_cell == cell then
      grid.selected_cell.active = false
      grid.selected_cell = nil
      self:debug("GridHandler:handle_left_click - Deselected cell")
      return true
    end
    
    -- Try to combine items
    if cell.item then
      local success = self:combine_items(grid, grid.selected_cell, cell)
      grid.selected_cell.active = false
      grid.selected_cell = nil
      self:debug("GridHandler:handle_left_click - Combination " .. (success and "succeeded" or "failed"))
      return success
    end
  end
  
  -- Select the clicked cell if it has an item
  if cell.item then
    if grid.selected_cell then
      grid.selected_cell.active = false
    end
    grid.selected_cell = cell
    cell.active = true
    self:debug("GridHandler:handle_left_click - Selected cell with item: " .. (cell.item.name or "unnamed"))
    return true
  end
  
  return false
end

---Gets the inventory component from the game state
---@return table|nil The inventory UI component or nil if not found
function GridHandler:get_inventory()
  if not self.game_state or not self.game_state.components then
    return nil
  end
  
  return self.game_state.components.inventory
end

---Handles combining items in the grid
---@param grid table The grid containing the cells
---@param source_cell table The source cell (already selected)
---@param target_cell table The target cell (just clicked)
---@return boolean Whether the combination was successful
function GridHandler:combine_items(grid, source_cell, target_cell)
  self:debug("READY TO COMBINE: " .. source_cell.id .. " + " .. target_cell.id)
  
  -- Log the items
  self:debug("COMBINING cells: " .. source_cell.id .. " + " .. target_cell.id)
  self:debug("Items: " .. (source_cell.item and source_cell.item.name or "nil") .. " + "
         .. (target_cell.item and target_cell.item.name or "nil"))
  
  -- Check if source cell has an item
  if not source_cell.item then
    self:debug("ERROR: Source cell has no item!")
    source_cell.active = false
    grid.selected_cell = nil
    return false
  end
  
  -- Check if target cell has an item
  if not target_cell.item then
    self:debug("ERROR: Target cell has no item!")
    return false
  end
  
  -- Try to combine using item manager
  local combination_result
  
  -- Check for combine method
  if grid.item_manager and grid.item_manager.combine then
    combination_result = grid.item_manager:combine(source_cell.item, target_cell.item)
  else
    self:debug("ERROR: Item manager missing combine method!")
    combination_result = nil
  end
  
  -- Emergency fallback if item manager failed to combine
  if not combination_result then
    combination_result = self:handle_emergency_combination(source_cell.item.id, target_cell.item.id)
  end
  
  -- Check if we have a valid result
  if combination_result then
    self:debug("COMBINATION SUCCESSFUL! Created: " .. (combination_result.name or "unnamed"))
    
    -- Apply the combination result
    self:debug("Removing item from source cell " .. source_cell.id)
    source_cell:remove_item()
    
    self:debug("Setting result in target cell " .. target_cell.id)
    target_cell:remove_item()
    target_cell:add_item(combination_result)
    
    self:debug("COMBINATION COMPLETE!")
  else
    self:debug("Combination FAILED - no recipe found")
    source_cell.active = false
    grid.selected_cell = nil
    return false
  end
  
  -- Clear selection
  source_cell.active = false
  grid.selected_cell = nil
  
  self:debug("----- END GRID CLICK EVENT -----")
  
  return true
end

---Provides fallback combinations when the standard item manager fails
---@param source_id string Source item ID
---@param target_id string Target item ID
---@return table|nil The combination result or nil if no fallback found
function GridHandler:handle_emergency_combination(source_id, target_id)
  self:debug("Trying emergency fallback combination for " .. source_id .. " + " .. target_id)
  
  -- Some hardcoded basic combinations (water + fire = steam, etc.)
  local basic_combinations = {
    ["fire+water"] = {id = "steam", name = "Steam", color = {0.9, 0.9, 0.9}},
    ["air+fire"] = {id = "energy", name = "Energy", color = {1.0, 0.8, 0.2}},
    ["earth+water"] = {id = "mud", name = "Mud", color = {0.4, 0.3, 0.2}},
    ["air+earth"] = {id = "dust", name = "Dust", color = {0.7, 0.7, 0.5}}
  }
  
  -- Try both orderings
  local key1 = source_id .. "+" .. target_id
  local key2 = target_id .. "+" .. source_id
  
  local result = basic_combinations[key1] or basic_combinations[key2]
  
  if result then
    self:debug("EMERGENCY: Found hardcoded combination: " .. result.name)
    return result
  end
  
  self:debug("No hardcoded combination found")
  return nil
end

return GridHandler 