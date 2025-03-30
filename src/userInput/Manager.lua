local Debug = require("src.core.debug.init")
-- Remove direct import of MainMenu to break circular dependency
-- local MainMenu = require("src.gamestate.main_menu")

local InputManager = {}
InputManager.__index = InputManager


---@class InputManager
---@field new fun(game_state: GameState)
---@field keypressed fun(self: InputManager, key: string, scancode: string, isrepeat: boolean)
---@field mousepressed fun(self: InputManager, x: number, y: number, button: number)
---@field mousereleased fun(self: InputManager, x: number, y: number, button: number)
---@field mousemoved fun(self: InputManager, x: number, y: number, dx: number, dy: number)
---@field wheelmoved fun(self: InputManager, x: number, y: number)
---@field handle_grid_click fun(self: InputManager, grid: table, x: number, y: number, button: number): boolean
function InputManager:new(game_state)
  local self = setmetatable({}, self)
  self.game_state = game_state

  -- Initialize mouse state
  self.mouse = {
    x = 0,
    y = 0,
    buttons = {
      pressed = {},
      released = {},
      down = {}
    },
    wheel = {
      x = 0,
      y = 0
    }
  }
  
  -- Key bindings
  self.key_bindings = {
    quit = "escape",
    inventory = "i",
    craft = "c",
    debug = "f3"
  }
  
  -- For logging control
  self.log_mouse_events = false
  
  return self
end

function InputManager:update(dt)
  -- Reset one-frame input states
  self.mouse.buttons.pressed = {}
  self.mouse.buttons.released = {}
  self.mouse.wheel.x = 0
  self.mouse.wheel.y = 0
  
  -- Update mouse position
  self.mouse.x, self.mouse.y = love.mouse.getPosition()
end

function InputManager:mousepressed(x, y, button)
  -- Update mouse state
  self.mouse.buttons.pressed[button] = true
  self.mouse.buttons.down[button] = true
  
  -- DIRECT DEBUG OUTPUT
  Debug.debug(Debug, "InputManager received mouse press at " .. x .. "," .. y .. " with button " .. button)
  
  -- If we're in the play state, forward directly to the play state's handlers
  if self.game_state.current_state and self.game_state.current_state.state_name == "playstate" then
    Debug.debug(Debug, "Forwarding directly to play state")
    if self.game_state.current_state.mousepressed then
      return self.game_state.current_state:mousepressed(x, y, button)
    end
  end
  
  -- Forward to UI manager if available
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_pressed(x, y, button) then
    Debug.debug(Debug, "UI manager handled mouse press")
    return -- UI handled the input
  end
  
  -- Otherwise, forward to appropriate state handler
  self:handle_mouse_pressed(x, y, button)
end

function InputManager:mousereleased(x, y, button)
  -- Update mouse state
  self.mouse.buttons.released[button] = true
  self.mouse.buttons.down[button] = false
  
  -- DIRECT DEBUG OUTPUT
  Debug.debug(Debug, "InputManager received mouse release at " .. x .. "," .. y .. " with button " .. button)
  
  -- If we're in the play state, forward directly to the play state's handlers
  if self.game_state.current_state and self.game_state.current_state.state_name == "playstate" then
    Debug.debug(Debug, "Forwarding directly to play state")
    if self.game_state.current_state.mousereleased then
      return self.game_state.current_state:mousereleased(x, y, button)
    end
  end
  
  -- Forward to UI manager if available
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_released(x, y, button) then
    Debug.debug(Debug, "UI manager handled mouse release")
    return -- UI handled the input
  end
  
  -- Handle state-specific release
  if self.game_state.current_state then
    if self.game_state.current_state.state_name == "playing" then
      self:handle_mouse_released_playing(x, y, button)
    elseif self.game_state.current_state.state_name == "menu" then
      self:handle_mouse_released_main_menu(x, y, button)
    end
  end
end

function InputManager:mousemoved(x, y, dx, dy)
  -- Update mouse position
  self.mouse.x = x
  self.mouse.y = y
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_mouse_moved(x, y, dx, dy) then
    return -- UI handled the input
  end
  
  -- Handle state-specific movement
  if self.game_state.current_state then
    if self.game_state.current_state.state_name == "playing" then
      self:handle_mouse_moved_playing(x, y, dx, dy)
    end
  end
end

function InputManager:wheelmoved(x, y)
  -- Update mouse wheel state
  self.mouse.wheel.x = x
  self.mouse.wheel.y = y
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_wheel_moved(x, y) then
    return -- UI handled the input
  end
end

function InputManager:keypressed(key, scancode, isrepeat)
  -- Check for game control keys first
  if key == self.key_bindings.quit then
    love.event.quit()
    return
  end
  
  if key == self.key_bindings.debug then
    if self.game_state.components and self.game_state.components.debug then
      self.game_state.components.debug:toggle()
    end
    -- Toggle logging of mouse events
    self.log_mouse_events = not self.log_mouse_events
    Debug.debug(Debug, "Mouse event logging " .. (self.log_mouse_events and "enabled" or "disabled"))
    return
  end
  
  -- Forward to UI manager first
  if self.game_state.ui_manager and self.game_state.ui_manager:handle_input() then
    return -- UI handled the input
  end
  
  -- Handle other gameplay keys
  if key == self.key_bindings.inventory then
    -- Toggle inventory
    if self.game_state.components and self.game_state.components.inventory then
      self.game_state.components.inventory:toggle()
    end
  elseif key == self.key_bindings.craft then
    -- Open crafting menu
    if self.game_state.components and self.game_state.components.crafting then
      self.game_state.components.crafting:open_menu()
    end
  end
end

function InputManager:handle_mouse_pressed(x, y, button)
  -- Only log when enabled
  if self.log_mouse_events then
    Debug.debug(Debug, "handle_mouse_pressed")
  end

  if self.game_state.current_state and self.game_state.current_state.state_name == "menu" then
    self:handle_mouse_pressed_main_menu(x, y, button)
  end
end

function InputManager:handle_mouse_pressed_playing(x, y, button)
  if self.log_mouse_events then
    Debug.debug(Debug, "handle_mouse_pressed_playing")
  end
end

function InputManager:handle_mouse_pressed_main_menu(x, y, button)
    -- Only handle left mouse button
    if button ~= 1 then return nil end
    local ui_buttons = self.game_state.current_state.ui_buttons
    -- Check if any button was clicked
    for _, ui_button in ipairs(self.game_state.current_state.ui_buttons) do
      if ui_button:check_click(x, y, button) then
        ui_button.on_click()
      end
    end
end

function InputManager:handle_mouse_released_playing(x, y, button)
  if self.log_mouse_events then
    Debug.debug(Debug, "handle_mouse_released_playing")
  end
end

function InputManager:handle_mouse_released_main_menu(x, y, button)
  if self.log_mouse_events then
    Debug.debug(Debug, "handle_mouse_released_main_menu")
  end
end

function InputManager:handle_mouse_moved_playing(x, y, dx, dy)
  if self.log_mouse_events then
    Debug.debug(Debug, "handle_mouse_moved_playing")
  end
end

---Handles grid interaction logic
---@param grid table The grid to handle input for
---@param x number Mouse x position
---@param y number Mouse y position
---@param button number The mouse button that was pressed
---@return boolean Whether the input was handled
function InputManager:handle_grid_click(grid, x, y, button)
    -- Convert to local grid coordinates
    local rel_x = x - grid.x
    local rel_y = y - grid.y
    
    -- Check if click is within grid bounds
    if rel_x < 0 or rel_x > grid.width or 
       rel_y < 0 or rel_y > grid.height then
        Debug.debug(Debug, "InputManager:handle_grid_click - Click outside grid bounds")
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
        Debug.debug(Debug, "InputManager:handle_grid_click - Invalid cell position")
        return false
    end
    
    local cell = grid:get_cell_at(row, col)
    if not cell then
        Debug.debug(Debug, "InputManager:handle_grid_click - No cell found at position")
        return false
    end
    
    -- Handle right-click (transfer to inventory)
    if button == 2 then
        if cell.item then
            Debug.debug(Debug, "InputManager:handle_grid_click - Right click on item: " .. (cell.item.name or "unnamed"))
            
            -- Get reference to inventory from game state
            local inventory = self.game_state.components.inventory
            if not inventory then
                Debug.debug(Debug, "InputManager:handle_grid_click - No inventory found")
                return false
            end
            
            -- Store item reference and remove from cell
            local item = cell.item
            cell.item = nil
            
            -- Try to add to inventory
            local success = inventory:add_item(item)
            if success then
                Debug.debug(Debug, "InputManager:handle_grid_click - Successfully transferred item to inventory")
                return true
            else
                -- Put item back if transfer failed
                cell.item = item
                Debug.debug(Debug, "InputManager:handle_grid_click - Failed to transfer item to inventory")
                return false
            end
        end
        return false
    end
    
    -- Handle left-click (selection and combination)
    if button == 1 then
        -- If we have a selected inventory item, try to place it
        local inventory = self.game_state.components.inventory
        if inventory and inventory.selected_slot then
            local item = inventory:get_selected_item()
            if item and not cell.item then
                -- Remove from inventory and add to grid
                item = inventory:remove_selected_item()
                cell.item = item
                Debug.debug(Debug, "InputManager:handle_grid_click - Placed inventory item in grid")
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
                Debug.debug(Debug, "InputManager:handle_grid_click - Deselected cell")
                return true
            end
            
            -- Try to combine items
            if cell.item then
                local success = grid:combine_items(grid.selected_cell, cell)
                grid.selected_cell.active = false
                grid.selected_cell = nil
                Debug.debug(Debug, "InputManager:handle_grid_click - Combination " .. (success and "succeeded" or "failed"))
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
            Debug.debug(Debug, "InputManager:handle_grid_click - Selected cell with item: " .. (cell.item.name or "unnamed"))
            return true
        end
    end
    
    return false
end

---Gets the inventory component from the game state
---@return table|nil The inventory UI component or nil if not found
function InputManager:get_inventory()
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
function InputManager:handle_grid_combine(grid, source_cell, target_cell)
  Debug.debug(Debug, "READY TO COMBINE: " .. source_cell.id .. " + " .. target_cell.id)
  
  -- Combine the items
  Debug.debug(Debug, "COMBINING cells: " .. source_cell.id .. " + " .. target_cell.id)
  Debug.debug(Debug, "Items: " .. (source_cell.item and source_cell.item.name or "nil") .. " + "
            .. (target_cell.item and target_cell.item.name or "nil"))
  
  -- Check if source cell has an item
  if not source_cell.item then
    Debug.debug(Debug, "ERROR: Source cell has no item!")
    source_cell.active = false
    grid.selected_cell = nil
    return false
  end
  
  -- Check if target cell has an item
  if not target_cell.item then
    Debug.debug(Debug, "ERROR: Target cell has no item!")
    return false
  end
  
  -- Try to combine using item manager
  local combination_result
  
  -- Check for combine method
  if grid.item_manager.combine then
    combination_result = grid.item_manager:combine(source_cell.item, target_cell.item)
  else
    Debug.debug(Debug, "ERROR: Item manager missing combine method!")
    combination_result = nil
  end
  
  -- Emergency fallback if item manager failed to combine
  if not combination_result then
    combination_result = self:handle_emergency_combination(source_cell.item.id, target_cell.item.id)
  end
  
  -- Check if we have a valid result
  if combination_result then
    Debug.debug(Debug, "COMBINATION SUCCESSFUL! Created: " .. (combination_result.name or "unnamed"))
    
    -- Apply the combination result
    Debug.debug(Debug, "Removing item from source cell " .. source_cell.id)
    source_cell:remove_item()
    
    Debug.debug(Debug, "Setting result in target cell " .. target_cell.id)
    target_cell:remove_item()
    target_cell:add_item(combination_result)
    
    Debug.debug(Debug, "COMBINATION COMPLETE!")
  else
    Debug.debug(Debug, "Combination FAILED - no recipe found")
    source_cell.active = false
    grid.selected_cell = nil
    return false
  end
  
  -- Clear selection
  source_cell.active = false
  grid.selected_cell = nil
  
  Debug.debug(Debug, "----- END GRID CLICK EVENT -----")
  
  return true
end

---Provides fallback combinations when the standard item manager fails
---@param source_id string Source item ID
---@param target_id string Target item ID
---@return table|nil The combination result or nil if no fallback found
function InputManager:handle_emergency_combination(source_id, target_id)
  Debug.debug(Debug, "Trying emergency fallback combination for " .. source_id .. " + " .. target_id)
  
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
    Debug.debug(Debug, "EMERGENCY: Found hardcoded combination: " .. result.name)
    return result
  end
  
  Debug.debug(Debug, "No hardcoded combination found")
  return nil
end

return InputManager