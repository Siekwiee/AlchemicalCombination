---@class GridCellCore
---@field x number
---@field y number
---@field width number
---@field height number
---@field id string
---@field row number
---@field col number
---@field item table|nil
---@field hover boolean
---@field active boolean
---@field contains_point fun(self: GridCellCore, x: number, y: number): boolean
---@field add_item fun(self: GridCellCore, item: table): boolean
---@field remove_item fun(self: GridCellCore): table|nil
---@field has_item fun(self: GridCellCore): boolean
---@field update fun(self: GridCellCore, x: number, y: number)
local GridCellCore = {}
GridCellCore.__index = GridCellCore

---Create a new grid cell
---@param config table Configuration for the grid cell
---@return GridCellCore
function GridCellCore.new(config)
  local cell = setmetatable({}, {__index = GridCellCore})
  
  -- Required properties
  cell.x = config.x or 0
  cell.y = config.y or 0
  cell.width = config.width or 64
  cell.height = config.height or 64
  cell.id = config.id or (config.row or 0) .. "," .. (config.col or 0)
  cell.row = config.row or 0
  cell.col = config.col or 0
  
  -- Optional properties
  cell.item = config.item or nil
  cell.hover = false
  cell.active = false
  
  return cell
end

---Update the cell's state
---@param x number Mouse x position
---@param y number Mouse y position
function GridCellCore:update(x, y)
  -- Skip if no mouse position
  if not x or not y then
    return
  end
  
  -- Check if mouse is inside cell
  self.hover = self:contains_point(x, y)
  
  if self.hover then
    -- Cell is being hovered over
  end
end

---Check if a point is inside the cell
---@param x number X coordinate to check
---@param y number Y coordinate to check
---@return boolean Whether the point is inside the cell
function GridCellCore:contains_point(x, y)
  -- Validate input
  if not x or not y then
    return false
  end
  
  -- Simple rectangle collision detection
  if x >= self.x and x <= self.x + self.width and
     y >= self.y and y <= self.y + self.height then
    return true
  end
  
  return false
end

---Add an item to the cell
---@param item table The item to add
---@return boolean Whether the item was successfully added
function GridCellCore:add_item(item)
  -- Check if cell already has an item
  if self.item then
    return false
  end
  
  -- Add the item
  self.item = item
  
  return true
end

---Remove the item from the cell
---@return table|nil The removed item, or nil if there was no item
function GridCellCore:remove_item()
  -- Check if cell has an item
  if not self.item then
    return nil
  end
  
  -- Remove and return the item
  local item = self.item
  self.item = nil
  
  return item
end

---Check if the cell has an item
---@return boolean Whether the cell has an item
function GridCellCore:has_item()
  return self.item ~= nil
end

return GridCellCore 