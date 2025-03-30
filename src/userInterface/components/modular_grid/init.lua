--This is the init file for the modular grid ui module

local Debug = require("src.core.debug.init")
local ModularGridCore = require("src.core.modular_grid.core")
local ModularGrid = require("src.core.modular_grid.init")
local ModularGridVisualization = require("src.core.modular_grid.visualization")
local love = require("love")

local UIModularGrid = {}
UIModularGrid.__index = UIModularGrid

---Creates a new modular grid UI component
---@param config table Grid configuration with x, y, rows, cols, etc.
---@return table New grid UI component
function UIModularGrid:new(config)
  local grid = setmetatable({}, self)
  
  -- Create core grid
  grid.core = ModularGrid.new(config)
  
  -- UI integration properties
  grid.visible = config.visible or true
  grid.enabled = config.enabled or true
  
  -- Store reference to input manager if provided
  grid.input_manager = config.input_manager
  
  return grid
end

---Updates the grid state
---@param dt number Delta time
function UIModularGrid:update(dt)
  if not self.visible or not self.enabled then
    return
  end
  
  local mx, my = love.mouse.getPosition()
  self.core:update(mx, my, dt)
end

---Draws the grid
function UIModularGrid:draw()
  if not self.visible then
    return
  end
  
  if not self.core then
    return
  end
  
  -- Use the visualization module directly instead of relying on forwarded methods
  ModularGridVisualization.draw(self.core)
end

---Adds an item to a cell at the specified row and column
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@param item table The item to add
---@return boolean Whether the item was successfully added
function UIModularGrid:add_item(row, col, item)
  if not self.core then
    return false
  end
  return self.core:add_item(row, col, item)
end

---Removes an item from a cell at the specified row and column
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@return table|nil The removed item, or nil if there was no item
function UIModularGrid:remove_item(row, col)
  if not self.core then
    return nil
  end
  return self.core:remove_item(row, col)
end

---Sets the input manager for this grid
---@param input_manager table The input manager to use
function UIModularGrid:set_input_manager(input_manager)
  self.input_manager = input_manager
end

---Handles mouse pressed events
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function UIModularGrid:handle_mouse_pressed(x, y, button)
  if not self.visible or not self.enabled then
    return false
  end
  
  -- Forward to the core grid, passing the input manager
  return self.core:handle_mouse_pressed(x, y, button, self.input_manager)
end

---Handles mouse released events
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was released
---@return boolean Whether the input was handled
function UIModularGrid:handle_mouse_released(x, y, button)
  if not self.visible or not self.enabled then
    return false
  end
  
  -- Forward to the core grid
  return self.core:handle_mouse_released(x, y, button)
end

---Toggles grid visibility
function UIModularGrid:toggle()
  self.visible = not self.visible
end

---Sets grid visibility
---@param visible boolean Whether the grid should be visible
function UIModularGrid:set_visible(visible)
  self.visible = visible
end

---Sets grid enabled state
---@param enabled boolean Whether the grid should be enabled
function UIModularGrid:set_enabled(enabled)
  self.enabled = enabled
end

---Gets the grid cell at the specified row and column
---@param row number The row index (1-based)
---@param col number The column index (1-based)
---@return table|nil The cell at the specified position, or nil if out of bounds
function UIModularGrid:get_cell_at(row, col)
  return self.core:get_cell_at(row, col)
end

return UIModularGrid
