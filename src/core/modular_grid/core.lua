local Debug = require("src.core.debug.init")
local GridCell = require("src.core.grid_cell.init")
local love = require("love")

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
  
  -- Optional properties
  grid.active_cell = nil
  grid.drag_source = nil
  grid.drag_item = nil
  
  -- Initialize cells
  grid.cells = {}
  for row = 1, grid.rows do
    for col = 1, grid.cols do
      local cell_x = grid.x + (col - 1) * (grid.cell_width + grid.spacing)
      local cell_y = grid.y + (row - 1) * (grid.cell_height + grid.spacing)
      local id = "cell_" .. row .. "_" .. col
      
      grid.cells[id] = GridCell.new({
        x = cell_x,
        y = cell_y,
        width = grid.cell_width,
        height = grid.cell_height,
        id = id
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
  -- Reset active cell
  grid.active_cell = nil
  
  -- Update all cells and find the active one
  for id, cell in pairs(grid.cells) do
    cell:update(mx, my)
    
    if cell.hover then
      grid.active_cell = cell
    end
  end
  
  -- Handle drag and drop logic
  if grid.drag_item and grid.active_cell and not love.mouse.isDown(1) then
    -- Attempt to place the dragged item
    if not grid.active_cell:has_item() then
      grid.active_cell:add_item(grid.drag_item)
    else
      -- If the target cell has an item, attempt to combine
      ModularGridCore.combine_items(grid, grid.drag_source, grid.active_cell)
    end
    
    grid.drag_item = nil
    grid.drag_source = nil
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
  
  local id = "cell_" .. row .. "_" .. col
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
  
  -- Example combination logic - can be expanded based on game rules
  if source_item.type == target_item.type then
    -- Simple upgrade: same types combine to level up
    if target_item.level then
      target_item.level = target_item.level + 1
      Debug.debug(Debug, "ModularGridCore.combine_items: Upgraded item to level " .. target_item.level)
    end
    
    -- Remove the source item
    source_cell:remove_item()
    return true
  end
  
  -- Check for special combinations based on item properties
  -- This can be expanded with a recipe system
  local combined_item = nil
  
  -- Example: combining water and fire creates steam
  if (source_item.type == "water" and target_item.type == "fire") or
     (source_item.type == "fire" and target_item.type == "water") then
    combined_item = {
      type = "steam",
      name = "Steam",
      level = 1
    }
  end
  
  if combined_item then
    -- Replace target item with the combined result
    target_cell:remove_item()
    target_cell:add_item(combined_item)
    source_cell:remove_item()
    Debug.debug(Debug, "ModularGridCore.combine_items: Created new item " .. combined_item.name)
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
  if button ~= 1 then
    return false
  end
  
  local cell = ModularGridCore.get_cell_by_position(grid, x, y)
  if not cell then
    return false
  end
  
  Debug.debug(Debug, "ModularGridCore.handle_mouse_pressed: Selected cell " .. cell.id)
  
  -- Start drag if the cell has an item
  if cell:has_item() then
    grid.drag_source = cell
    grid.drag_item = cell.item
    cell.active = true
    return true
  end
  
  return false
end

---Handles mouse release on the grid
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function ModularGridCore.handle_mouse_released(grid, x, y, button)
  if button ~= 1 or not grid.drag_item then
    return false
  end
  
  local cell = ModularGridCore.get_cell_by_position(grid, x, y)
  if not cell then
    -- If released outside the grid, return the item to its source
    if grid.drag_source then
      grid.drag_source.active = false
      grid.drag_item = nil
      grid.drag_source = nil
    end
    return false
  end
  
  Debug.debug(Debug, "ModularGridCore.handle_mouse_released: Released on cell " .. cell.id)
  
  -- If released on a different cell
  if cell ~= grid.drag_source then
    if not cell:has_item() then
      -- Place item in empty cell
      cell:add_item(grid.drag_item)
      grid.drag_source:remove_item()
    else
      -- Try to combine items
      ModularGridCore.combine_items(grid, grid.drag_source, cell)
    end
  end
  
  -- Reset drag state
  if grid.drag_source then
    grid.drag_source.active = false
  end
  grid.drag_item = nil
  grid.drag_source = nil
  
  return true
end

return ModularGridCore 