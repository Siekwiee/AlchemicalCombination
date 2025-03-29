local Debug = require("src.core.debug.init")

local GridCellCore = {}

---Creates a new grid cell
---@param config table Configuration table with x, y, width, height, and optional item
---@return table New grid cell instance
function GridCellCore.new(config)
  local cell = setmetatable({}, {__index = GridCellCore})
  
  -- Required properties
  cell.x = config.x or 0
  cell.y = config.y or 0
  cell.width = config.width or 64
  cell.height = config.height or 64
  
  -- Optional properties
  cell.item = config.item or nil
  cell.hover = false
  cell.active = false
  cell.id = config.id or "cell_" .. tostring(cell.x) .. "_" .. tostring(cell.y)
  
  Debug.debug(Debug, "GridCellCore.new: Created grid cell at " .. cell.x .. ", " .. cell.y)
  
  return cell
end

---Updates the grid cell state
---@param cell table The grid cell to update
---@param mx number Mouse x position
---@param my number Mouse y position
---@return boolean Whether the mouse is hovering over this cell
function GridCellCore.update(cell, mx, my)
  -- Validate input
  if not mx or not my then
    Debug.debug(Debug, "GridCellCore.update: Invalid mouse position")
    cell.hover = false
    return false
  end
  
  -- Update hover state
  local contains = GridCellCore.contains_point(cell, mx, my)
  cell.hover = contains
  
  -- Log if hover state changed
  if contains then
    Debug.debug(Debug, "GridCellCore.update: Mouse hovering over cell " .. cell.id)
  end
  
  return contains
end

---Checks if a point is inside this grid cell
---@param cell table The grid cell to check
---@param x number X coordinate to check
---@param y number Y coordinate to check
---@return boolean Whether the point is inside the cell
function GridCellCore.contains_point(cell, x, y)
  if not x or not y then
    Debug.debug(Debug, "GridCellCore.contains_point: Invalid coordinates")
    return false
  end
  
  local result = x >= cell.x and x < cell.x + cell.width and
                 y >= cell.y and y < cell.y + cell.height
  
  if result then
    Debug.debug(Debug, string.format("GridCellCore.contains_point: Point (%d,%d) is inside cell at (%d,%d)", 
      x, y, cell.x, cell.y))
  end
  
  return result
end

---Adds an item to the grid cell
---@param cell table The grid cell to add an item to
---@param item table The item to add
---@return boolean Whether the item was successfully added
function GridCellCore.add_item(cell, item)
  if cell.item then
    Debug.debug(Debug, "GridCellCore.add_item: Cell already contains an item")
    return false
  end
  
  cell.item = item
  Debug.debug(Debug, string.format("GridCellCore.add_item: Added item %s to cell at (%d,%d)", 
    item.name or "unknown", cell.x, cell.y))
  return true
end

---Removes the item from the grid cell
---@param cell table The grid cell to remove the item from
---@return table|nil The removed item, or nil if there was no item
function GridCellCore.remove_item(cell)
  local item = cell.item
  cell.item = nil
  
  if item then
    Debug.debug(Debug, string.format("GridCellCore.remove_item: Removed item %s from cell at (%d,%d)", 
      item.name or "unknown", cell.x, cell.y))
  else
    Debug.debug(Debug, "GridCellCore.remove_item: No item to remove")
  end
  
  return item
end

---Checks if the grid cell has an item
---@param cell table The grid cell to check
---@return boolean Whether the cell has an item
function GridCellCore.has_item(cell)
  return cell.item ~= nil
end

return GridCellCore 