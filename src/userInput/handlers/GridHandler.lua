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
    print("[DEBUG][GridHandler:handle_mouse_pressed] No active grid. Returning false.") -- DEBUG
    return false
  end
  
  -- Check if the click is within grid bounds
  if not self:is_point_in_grid(grid, x, y) then
    print("[DEBUG][GridHandler:handle_mouse_pressed] Click outside grid bounds. Returning false.") -- DEBUG
    return false
  end
  
  -- Process the grid click
  print("[DEBUG][GridHandler:handle_mouse_pressed] Click in bounds, calling handle_grid_click...") -- DEBUG
  local handled = self:handle_grid_click(grid, x, y, button)
  print("[DEBUG][GridHandler:handle_mouse_pressed] handle_grid_click returned: " .. tostring(handled) .. ". Returning this value.") -- DEBUG
  return handled
end

---Handles mouse release events for grid
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Mouse button that was released
---@return boolean Whether the input was handled
function GridHandler:handle_mouse_released(x, y, button)
  -- Get the active grid
  local grid = self:get_active_grid()
  if not grid then
    return false
  end
  
  -- Check if the release is within grid bounds
  if not self:is_point_in_grid(grid, x, y) then
    return false
  end
  
  -- If we have a selected cell, return true to indicate we handled the event
  -- but DON'T clear the selection, so we can combine items later
  if grid.selected_cell then
    return true
  end
  
  return false
end

---Gets the currently active grid from the game state
---@return table|nil The active grid or nil if not found
function GridHandler:get_active_grid()
  -- Get grid from components or current state
  if self.game_state.components and self.game_state.components.modular_grid then
    return self.game_state.components.modular_grid.core
  elseif self.game_state.current_state and self.game_state.current_state.components and 
         self.game_state.current_state.components.modular_grid then
    return self.game_state.current_state.components.modular_grid.core
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
  print("[DEBUG] handle_grid_click called for button " .. button .. " at (" .. x .. "," .. y .. ")") -- DEBUG
  -- Convert to local grid coordinates
  local rel_x = x - grid.x
  local rel_y = y - grid.y
  
  -- Calculate cell position
  local col = math.floor(rel_x / (grid.cell_width + grid.spacing)) + 1
  local row = math.floor(rel_y / (grid.cell_height + grid.spacing)) + 1
  print("[DEBUG] Calculated row: " .. row .. ", col: " .. col) -- DEBUG

  -- Validate cell position
  if row < 1 or row > grid.rows or col < 1 or col > grid.cols then
    print("[DEBUG] Calculated row/col out of bounds.") -- DEBUG
    -- Click was within grid bounds but not on a specific cell calculation area (e.g., spacing)
    -- Clear grid selection if clicking empty space within the grid bounds
    if grid.selected_cell then
        print("[DEBUG] Clearing selection because click was in grid spacing.") -- DEBUG
        grid.selected_cell = nil
    else
        print("[DEBUG] Click in grid spacing, no cell selected.") -- DEBUG
    end
    return false
  end
  
  local cell = grid:get_cell_at(row, col)
  if not cell then
     print("[DEBUG] Cell not found via get_cell_at for row " .. row .. ", col " .. col .. ".") -- DEBUG
     -- Should not happen if row/col are valid, but handle defensively
     if grid.selected_cell then
        print("[DEBUG] Clearing selection because cell lookup failed.") -- DEBUG
        grid.selected_cell = nil
     end
    return false
  end
  
  print("[DEBUG] Found cell: " .. cell.id .. ". Proceeding with button logic.") -- DEBUG

  -- Handle right-click (transfer to inventory)
  if button == 2 then
    print("[DEBUG] Handling right click.") -- DEBUG
    return self:handle_right_click(grid, cell)
  end
  
  -- Handle left-click (selection and combination)
  if button == 1 then
    print("[DEBUG] Handling left click by calling handle_left_click.") -- DEBUG
    return self:handle_left_click(grid, cell)
  end
  
  print("[DEBUG] Unhandled button: " .. button) -- DEBUG
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
  
  -- Get reference to inventory from game state
  local inventory = self:get_inventory()
  if not inventory then
    return false
  end
  
  -- Store item reference
  local item = cell.item
  
  -- Try to add to inventory first
  local success = inventory:add_item(item)
  if success then
    -- Only remove from cell if successfully added to inventory
    cell:remove_item()
    return true
  end
  
  return false
end

---Handles left-click actions on grid cells (selection and combination)
---@param grid table The grid containing the cell
---@param cell table The clicked cell
---@return boolean Whether the input was handled
function GridHandler:handle_left_click(grid, cell)
  local inventory = self:get_inventory()
  
  -- Priority 1: Handle placing a selected inventory item
  if inventory and inventory.selected_slot then
      local item_to_place = inventory:get_selected_item()
      if item_to_place then
          -- Only if target cell is empty
          if not cell.item then
              -- First remove from inventory (returns the actual item)
              item_to_place = inventory:remove_selected_item()
              if item_to_place then
                  local add_success = cell:add_item(item_to_place)
                  if add_success then
                      -- Clear inventory selection on successful placement
                      inventory.selected_slot = nil
                      return true
                  else
                      -- Failed to add to cell, put back in inventory
                      inventory:add_item(item_to_place)
                  end
              end
          end
          
          -- Always clear inventory selection to avoid confusing state
          inventory.selected_slot = nil
          return true
      else
          -- Invalid selection, clear it
          inventory.selected_slot = nil
          return true
      end
  end

  -- Priority 2: Handle grid-to-grid interaction - clicking on a cell with no inventory selection

  -- If a cell is already selected...
  if grid.selected_cell then
      local source_cell = grid.selected_cell
      local target_cell = cell
      
      -- Clicking same cell? Deselect
      if source_cell == target_cell then
          grid.selected_cell = nil
          return true
      end
      
      -- Both cells have items? Try combine
      if source_cell.item and target_cell.item then
          local combined = self:combine_items(grid, source_cell, target_cell)
          grid.selected_cell = nil
          return true
      end
      
      -- Source has item but target is empty? Move item
      if source_cell.item and not target_cell.item then
          local item = source_cell:remove_item()
          if item then
              local success = target_cell:add_item(item)
              if not success then
                  -- Move failed, put back
                  source_cell:add_item(item)
              end
          end
          grid.selected_cell = nil
          return true
      end
      
      -- Target has item but source is empty? (Shouldn't happen but handle just in case)
      if not source_cell.item and target_cell.item then
          grid.selected_cell = nil
          return true
      end
      
      -- Both empty? Just clear selection
      grid.selected_cell = nil
      return true
  end
  
  -- No cell selected yet - select this one if it has an item
  if cell.item then
      grid.selected_cell = cell
      return true
  end
  
  return false
end

---Gets the inventory component from the game state
---@return table|nil The inventory UI component or nil if not found
function GridHandler:get_inventory()
  -- First try to get inventory from components
  if self.game_state.components and self.game_state.components.inventory then
    return self.game_state.components.inventory
  end
  
  -- Then try current state components
  if self.game_state.current_state and 
     self.game_state.current_state.components and 
     self.game_state.current_state.components.inventory then
    return self.game_state.current_state.components.inventory
  end
  
  -- Finally try inventory system
  if self.game_state.inventory_system then
    return self.game_state.inventory_system
  end
  
  return nil
end

---Handles combining items in the grid
---@param grid table The grid containing the cells
---@param source_cell table The source cell (already selected)
---@param target_cell table The target cell (just clicked)
---@return boolean Whether the combination was successful
function GridHandler:combine_items(grid, source_cell, target_cell)
  -- Validate cells and items
  if not source_cell or not target_cell then
    return false
  end
  
  if not source_cell.item or not target_cell.item then
    return false
  end
  
  -- Try to combine using item manager
  local combination_result
  if grid.item_manager and grid.item_manager.combine then
    combination_result = grid.item_manager:combine(source_cell.item, target_cell.item)
  end
  
  -- Check if we have a valid result
  if combination_result then
    -- Remove items from both cells
    source_cell:remove_item()
    target_cell:remove_item()
    
    -- Add the result to the target cell
    target_cell:add_item(combination_result)
    return true
  end
  
  return false
end

---Provides fallback combinations when the standard item manager fails
---@param source_id string Source item ID
---@param target_id string Target item ID
---@return table|nil The combination result or nil if no fallback found
function GridHandler:handle_emergency_combination(source_id, target_id)
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
    return result
  end
  
  return nil
end

return GridHandler 