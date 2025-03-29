local Debug = require("src.core.debug.init")
local GridCell = require("src.core.grid_cell.init")
local love = require("love")
local ItemManager = require("src.core.items.manager")

local ModularGridCore = {}

---Creates a new modular grid
---@param config table Configuration table with x, y, rows, cols, cell_width, cell_height, and spacing
---@return table New modular grid instance
function ModularGridCore.new(config)
  local grid = setmetatable({}, {__index = ModularGridCore})
  
  -- Required properties
  grid.x = config.x or 0
  grid.y = config.y or 0
  grid.rows = config.rows or 4
  grid.cols = config.cols or 4
  grid.cell_width = config.cell_width or 64
  grid.cell_height = config.cell_height or 64
  grid.spacing = config.spacing or 4
  
  -- Calculate total dimensions
  grid.width = (grid.cell_width + grid.spacing) * grid.cols - grid.spacing
  grid.height = (grid.cell_height + grid.spacing) * grid.rows - grid.spacing
  
  -- Initialize item manager
  grid.item_manager = ItemManager:new()
  
  -- Optional properties
  grid.active_cell = nil
  grid.selected_cell = nil
  grid.title = config.title or nil
  
  -- Initialize cells
  grid.cells = {}
  for row = 1, grid.rows do
    for col = 1, grid.cols do
      local cell_x = grid.x + (col - 1) * (grid.cell_width + grid.spacing)
      local cell_y = grid.y + (row - 1) * (grid.cell_height + grid.spacing)
      local id = row .. "," .. col
      
      grid.cells[id] = GridCell.new({
        x = cell_x,
        y = cell_y,
        width = grid.cell_width,
        height = grid.cell_height,
        id = id,
        row = row,
        col = col
      })
    end
  end
  
  Debug.debug(Debug, "ModularGridCore.new: Created grid with " .. grid.rows * grid.cols .. " cells")
  
  return grid
end

---Updates the modular grid state
---@param grid table The grid to update
---@param mx number Mouse x position
---@param my number Mouse y position
---@param dt number Delta time
function ModularGridCore.update(grid, mx, my, dt)
  if not mx or not my then
    mx, my = love.mouse.getPosition()
  end

  -- Reset active cell
  grid.active_cell = nil
  
  -- Update all cells and find the active one
  for id, cell in pairs(grid.cells) do
    cell:update(mx, my)
    
    if cell.hover then
      grid.active_cell = cell
    end
  end
end

---Gets a cell by its row and column indices
---@param grid table The grid to get a cell from
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@return table|nil The cell at the specified position, or nil if out of bounds
function ModularGridCore.get_cell_at(grid, row, col)
  if row < 1 or row > grid.rows or col < 1 or col > grid.cols then
    return nil
  end
  
  local id = row .. "," .. col
  return grid.cells[id]
end

---Gets a cell by its position in pixels
---@param grid table The grid to get a cell from
---@param x number The x coordinate in pixels
---@param y number The y coordinate in pixels
---@return table|nil The cell at the specified position, or nil if no cell was found
function ModularGridCore.get_cell_by_position(grid, x, y)
  for id, cell in pairs(grid.cells) do
    if cell:contains_point(x, y) then
      return cell
    end
  end
  
  return nil
end

---Adds an item to a cell at the specified row and column
---@param grid table The grid to add an item to
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@param item table The item to add
---@return boolean Whether the item was successfully added
function ModularGridCore.add_item(grid, row, col, item)
  local cell = ModularGridCore.get_cell_at(grid, row, col)
  
  if not cell then
    Debug.debug(Debug, "ModularGridCore.add_item: Invalid cell position")
    return false
  end
  
  -- If we receive just an item ID or name, convert it to a full item object
  if type(item) == "string" then
    item = grid.item_manager:create_item(item)
    if not item then
      Debug.debug(Debug, "ModularGridCore.add_item: Failed to create item from ID: " .. tostring(item))
      return false
    end
  end
  
  return cell:add_item(item)
end

---Removes an item from a cell at the specified row and column
---@param grid table The grid to remove an item from
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@return table|nil The removed item, or nil if there was no item
function ModularGridCore.remove_item(grid, row, col)
  local cell = ModularGridCore.get_cell_at(grid, row, col)
  
  if not cell then
    Debug.debug(Debug, "ModularGridCore.remove_item: Invalid cell position")
    return nil
  end
  
  return cell:remove_item()
end

---Combines items from two cells
---@param grid table The grid containing the cells
---@param source_cell table The source cell
---@param target_cell table The target cell
---@return boolean Whether the combination was successful
function ModularGridCore.combine_items(grid, source_cell, target_cell)
  if not source_cell or not target_cell then
    Debug.debug(Debug, "ModularGridCore.combine_items: Invalid cells")
    return false
  end
  
  local source_item = source_cell.item
  local target_item = target_cell.item
  
  if not source_item or not target_item then
    Debug.debug(Debug, "ModularGridCore.combine_items: Missing items")
    return false
  end
  
  -- Use the item manager to find a valid combination
  local result = grid.item_manager:combine(source_item, target_item)
  
  if result then
    -- Replace target item with the combined result
    target_cell:remove_item()
    target_cell:add_item(result)
    source_cell:remove_item()
    return true
  end
  
  Debug.debug(Debug, "ModularGridCore.combine_items: No valid combination found")
  return false
end

---Handles mouse press on the grid
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function ModularGridCore.handle_mouse_pressed(grid, x, y, button)
  -- Only handle left clicks
  if button ~= 1 then
    return false
  end
  
  -- DIRECT CONSOLE OUTPUT
  print("----- CLICK EVENT -----")
  print("Mouse clicked at (" .. x .. "," .. y .. ") with button " .. button)
  print("Grid position: (" .. grid.x .. "," .. grid.y .. "), dimensions: " .. grid.width .. "x" .. grid.height)
  
  -- Debug the item_manager
  if not grid.item_manager then
    print("ERROR: Grid has NO ITEM MANAGER!")
    -- Create one immediately
    print("Creating emergency item manager")
    local ItemManager = require("src.core.items.manager")
    grid.item_manager = ItemManager:new()
  else
    print("Grid has item manager: " .. tostring(grid.item_manager))
    if grid.item_manager.combine then
      print("Item manager has combine method")
    else
      print("ERROR: Item manager has NO combine method!")
    end
  end
  
  print("Current selected cell: " .. (grid.selected_cell and grid.selected_cell.id or "none"))
  
  -- Check if click is within grid bounds
  if x < grid.x or x > grid.x + grid.width or y < grid.y or y > grid.y + grid.height then
    print("Click OUTSIDE grid bounds")
    if grid.selected_cell then
      print("Clearing selection (was " .. grid.selected_cell.id .. ")")
      grid.selected_cell.active = false
      grid.selected_cell = nil
    end
    return false
  else
    print("Click INSIDE grid bounds")
  end
  
  -- Find which cell was clicked
  local clicked_cell = nil
  for id, cell in pairs(grid.cells) do
    print("Testing cell " .. id .. " at (" .. cell.x .. "," .. cell.y .. ") size " .. cell.width .. "x" .. cell.height)
    if x >= cell.x and x < cell.x + cell.width and
       y >= cell.y and y < cell.y + cell.height then
      clicked_cell = cell
      print("FOUND clicked cell: " .. id)
      break
    end
  end
  
  -- If no cell was found (shouldn't happen but just in case)
  if not clicked_cell then
    print("ERROR: No cell found at click position despite being in grid bounds!")
    return false
  end
  
  -- If clicked cell has no item
  if not clicked_cell.item then
    print("Clicked cell " .. clicked_cell.id .. " has NO ITEM")
    if grid.selected_cell then
      print("Clearing selection (was " .. grid.selected_cell.id .. ")")
      grid.selected_cell.active = false
      grid.selected_cell = nil
    end
    return true
  else
    print("Clicked cell " .. clicked_cell.id .. " has item: " .. (clicked_cell.item.name or "unnamed"))
  end
  
  -- If no cell is currently selected, select this one
  if not grid.selected_cell then
    print("SELECTING cell " .. clicked_cell.id)
    grid.selected_cell = clicked_cell
    clicked_cell.active = true
    return true
  end
  
  -- If this is the same cell as already selected, deselect it
  if grid.selected_cell and grid.selected_cell.id == clicked_cell.id then
    print("DESELECTING cell " .. clicked_cell.id .. " (already selected)")
    grid.selected_cell.active = false
    grid.selected_cell = nil
    return true
  end
  
  -- At this point we have a valid source cell (grid.selected_cell) and target cell (clicked_cell)
  if grid.selected_cell then
    print("READY TO COMBINE: " .. grid.selected_cell.id .. " + " .. clicked_cell.id)
    
    -- Attempt to combine items
    print("COMBINING cells: " .. grid.selected_cell.id .. " + " .. clicked_cell.id)
    print("Items: " .. (grid.selected_cell.item and grid.selected_cell.item.name or "nil") .. " + " 
         .. (clicked_cell.item and clicked_cell.item.name or "nil"))
  end
  
  -- Try to combine items
  if not grid.item_manager then
    print("ERROR: No item manager found!")
    return false
  end
  
  -- Ensure both cells have valid items
  if not grid.selected_cell.item then
    print("ERROR: Source cell has no item!")
    grid.selected_cell.active = false
    grid.selected_cell = nil
    return true
  end
  
  if not clicked_cell.item then
    print("ERROR: Target cell has no item!")
    grid.selected_cell.active = false
    grid.selected_cell = nil
    return true
  end
  
  -- Manually check for and implement hardcoded basic combinations for debugging
  local combination_result = nil
  
  -- Try pcall with the item_manager
  local success, result = pcall(function()
    return grid.item_manager:combine(grid.selected_cell.item, clicked_cell.item)
  end)
  
  if not success then
    print("ERROR in combine call: " .. tostring(result))
    
    -- Emergency fallback for basic elements
    local source_id = grid.selected_cell.item.id
    local target_id = clicked_cell.item.id
    
    print("Trying emergency fallback combination for " .. source_id .. " + " .. target_id)
    
    -- Hard-coded fallback combinations
    local ids = {source_id, target_id}
    table.sort(ids)
    local combo_key = ids[1] .. "+" .. ids[2]
    
    local hardcoded_combinations = {
      ["air+fire"] = {id = "energy", name = "Energy", color = {1.0, 0.8, 0.0, 1.0}},
      ["earth+water"] = {id = "mud", name = "Mud", color = {0.4, 0.3, 0.2, 1.0}},
      ["fire+water"] = {id = "steam", name = "Steam", color = {0.8, 0.8, 0.8, 0.7}},
      ["earth+fire"] = {id = "lava", name = "Lava", color = {0.9, 0.4, 0.0, 1.0}}
    }
    
    combination_result = hardcoded_combinations[combo_key]
    if combination_result then
      print("EMERGENCY: Found hardcoded combination: " .. combination_result.name)
    else
      print("No hardcoded combination found")
    end
  else
    combination_result = result
    if combination_result then
      print("COMBINATION SUCCESSFUL! Created: " .. (combination_result.name or "unnamed"))
    else
      print("Combination FAILED - no recipe found")
    end
  end
  
  if combination_result then
    -- We have a successful combination!
    
    -- Remove source item
    print("Removing item from source cell " .. grid.selected_cell.id)
    grid.selected_cell.item = nil
    
    -- Replace target item with result
    print("Setting result in target cell " .. clicked_cell.id)
    clicked_cell.item = combination_result
    
    print("COMBINATION COMPLETE!")
  else
    print("Combination did not produce a result")
  end
  
  -- Clear selection regardless of outcome
  print("Clearing selection")
  grid.selected_cell.active = false
  grid.selected_cell = nil
  
  print("----- END CLICK EVENT -----")
  return true
end

---Handles mouse release on the grid
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function ModularGridCore.handle_mouse_released(grid, x, y, button)
  -- No special handling needed for mouse release in click-based system
  return false
end

return ModularGridCore 