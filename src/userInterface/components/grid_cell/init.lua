--This is the init file for the grid cell ui module

local GridCell = require("src.core.grid_cell.init")

local UIGridCell = {}
UIGridCell.__index = UIGridCell

---Creates a new grid cell UI component
---@param config table Grid cell configuration with x, y, width, height, etc.
---@return table New grid cell UI component
function UIGridCell:new(config)
  local cell = setmetatable({}, self)
  
  -- Create core grid cell
  cell.core = GridCell.new(config)
  
  -- UI integration properties
  cell.visible = config.visible or true
  cell.enabled = config.enabled or true
  
  return cell
end

---Updates the grid cell state
---@param dt number Delta time
function UIGridCell:update(dt)
  if not self.visible or not self.enabled then
    return
  end
  
  local mx, my = love.mouse.getPosition()
  self.core:update(mx, my)
end

---Draws the grid cell
function UIGridCell:draw()
  if not self.visible then
    return
  end
  
  self.core:draw()
end

---Handles mouse pressed events
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function UIGridCell:handle_mouse_pressed(x, y, button)
  if not self.visible or not self.enabled then
    return false
  end
  
  if self.core:contains_point(x, y) then
    self.core.active = true
    
    if self.on_click then
      self.on_click(self)
    end
    
    return true
  end
  
  return false
end

---Handles mouse released events
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function UIGridCell:handle_mouse_released(x, y, button)
  if not self.visible or not self.enabled then
    return false
  end
  
  if self.core.active then
    self.core.active = false
    
    if self.on_release then
      self.on_release(self, x, y)
    end
    
    return true
  end
  
  return false
end

---Gets the grid cell's item
---@return table|nil The cell's item, or nil if empty
function UIGridCell:get_item()
  return self.core.item
end

---Adds an item to the grid cell
---@param item table The item to add
---@return boolean Whether the item was successfully added
function UIGridCell:add_item(item)
  return self.core:add_item(item)
end

---Removes the item from the grid cell
---@return table|nil The removed item, or nil if there was no item
function UIGridCell:remove_item()
  return self.core:remove_item()
end

---Checks if the grid cell has an item
---@return boolean Whether the cell has an item
function UIGridCell:has_item()
  return self.core:has_item()
end

return UIGridCell
