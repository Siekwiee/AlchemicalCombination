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
  
  if not cell.item then
    Debug.debug(Debug, "ModularGridCore.remove_item: Cell has no item")
    return nil
  end
  
  local item = cell.item
  cell.item = nil
  Debug.debug(Debug, "ModularGridCore.remove_item: Removed item " .. (item.name or "unnamed"))
  return item
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

---Handles mouse press on the grid - now delegates to InputManager
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@param input_manager table Optional InputManager instance
---@return boolean Whether the input was handled
function ModularGridCore.handle_mouse_pressed(grid, x, y, button, input_manager)
    -- Require input manager
    if not input_manager or not input_manager.handle_grid_click then
        Debug.debug(Debug, "ERROR: ModularGridCore.handle_mouse_pressed - No valid input manager provided")
        return false
    end
    
    return input_manager:handle_grid_click(grid, x, y, button)
end

---Handles mouse release on the grid
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function ModularGridCore.handle_mouse_released(grid, x, y, button)
    -- Handle selection clearing
    if grid.selected_cell then
        local was_selected = grid.selected_cell
        grid.selected_cell.active = false
        grid.selected_cell = nil
        Debug.debug(Debug, "ModularGridCore.handle_mouse_released - Cleared selection from cell: " .. was_selected.id)
        return true
    end
    
    -- Handle active cell state
    if grid.active_cell then
        grid.active_cell.hover = false
        grid.active_cell = nil
        return true
    end
    
    return false
end

return ModularGridCore 