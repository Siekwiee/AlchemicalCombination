local Debug = require("src.core.debug.init")
local love = require("love")

---@class DragDropManager
---@field new fun(): DragDropManager
---@field start_drag fun(object: table, x: number, y: number): boolean
---@field update_drag fun(x: number, y: number): void
---@field end_drag fun(x: number, y: number): table|nil
---@field is_dragging fun(): boolean
---@field get_dragged_item fun(): table|nil
---@field draw_dragged_item fun(): void
local DragDropManager = {}
DragDropManager.__index = DragDropManager

function DragDropManager:new()
    local instance = setmetatable({}, self)
    
    instance.dragging = false
    instance.dragged_item = nil
    instance.drag_source = nil
    instance.drag_offset_x = 0
    instance.drag_offset_y = 0
    instance.on_drop_callback = nil
    instance.drag_button = 1  -- Default to left mouse button
    
    return instance
end

---Sets the mouse button used for dragging
---@param button number The mouse button to use for dragging (1 = left, 2 = right, 3 = middle)
function DragDropManager:set_drag_button(button)
    self.drag_button = button
end

---Gets the current drag button
---@return number The current drag button
function DragDropManager:get_drag_button()
    return self.drag_button
end

---Starts dragging an object
---@param object table The object to drag
---@param source table The source of the drag (e.g., a grid cell)
---@param x number Mouse x position
---@param y number Mouse y position
---@return boolean Whether dragging was successfully started
function DragDropManager:start_drag(object, source, x, y)
    Debug.debug(Debug, "DragDropManager:start_drag - Starting drag operation with mouse at " .. x .. "," .. y)
    Debug.debug(Debug, "DragDropManager:start_drag - Mouse button down: " .. tostring(love.mouse.isDown(1)))
    
    if not object then
        Debug.debug(Debug, "DragDropManager:start_drag: Cannot drag nil object")
        return false
    end
    
    -- Set dragging state first to ensure consistency
    self.dragging = true
    self.dragged_item = object
    self.drag_source = source
    
    -- Default offset values (centered on mouse)
    self.drag_offset_x = 0
    self.drag_offset_y = 0
    
    -- Calculate offset from mouse to center of item for smoother dragging
    if source then
        if source.x and source.y and source.width and source.height then
            -- Use cell center as reference point for dragging
            local center_x = source.x + source.width / 2
            local center_y = source.y + source.height / 2
            
            -- Calculate offset from mouse to center
            self.drag_offset_x = center_x - x
            self.drag_offset_y = center_y - y
            
            Debug.debug(Debug, "DragDropManager:start_drag: Offset calculated as " .. 
                        self.drag_offset_x .. "," .. self.drag_offset_y)
        end
    end
    
    local name = object.name or "unnamed"
    Debug.debug(Debug, "DragDropManager:start_drag: Started dragging " .. name .. " from source " .. 
                (source and source.id or "unknown"))
    
    -- Force manual update to ensure first frame of dragging looks correct
    self:update_drag(x, y)
    
    return true
end

---Updates the dragging state
---@param x number Mouse x position
---@param y number Mouse y position
function DragDropManager:update_drag(x, y)
    if not self.dragging then
        return
    end
    
    local mx, my
    if x and y then
        mx, my = x, y
    else
        mx, my = love.mouse.getPosition()
    end
    
    -- Debug: print current mouse position during drag
    Debug.debug(Debug, "DragDropManager:update_drag - Mouse position: " .. mx .. "," .. my)
    
    -- Check if mouse button is released
    local mb_down = love.mouse.isDown(self.drag_button)
    Debug.debug(Debug, "DragDropManager:update_drag - Mouse button down: " .. tostring(mb_down))
    
    if not mb_down then
        Debug.debug(Debug, "DragDropManager:update_drag - Mouse button released")
        self:end_drag(mx, my)
    end
end

---Registers a callback function to be called when item is dropped
---@param callback function The function to call when an item is dropped
function DragDropManager:register_drop_callback(callback)
    self.on_drop_callback = callback
end

---Ends dragging and returns the dragged item
---@param x number Mouse x position
---@param y number Mouse y position
---@return table|nil The dragged item, or nil if no item was being dragged
function DragDropManager:end_drag(x, y)
    if not self.dragging then
        return nil
    end
    
    local item = self.dragged_item
    local source = self.drag_source
    
    -- Reset drag state (important to do this before callback to prevent re-entrancy issues)
    local was_dragging = self.dragging
    self.dragging = false
    
    -- Call the drop callback if registered
    if was_dragging and self.on_drop_callback then
        -- We still want the callback to have access to item and source
        self.on_drop_callback(item, source, x, y)
    end
    
    -- Now fully reset state after callback
    self.dragged_item = nil
    self.drag_source = nil
    
    if item and item.name then
        Debug.debug(Debug, "DragDropManager:end_drag: Ended dragging item " .. item.name)
    else
        Debug.debug(Debug, "DragDropManager:end_drag: Ended dragging")
    end
    
    return item
end

---Checks if an item is currently being dragged
---@return boolean Whether an item is being dragged
function DragDropManager:is_dragging()
    return self.dragging
end

---Gets the currently dragged item
---@return table|nil The dragged item, or nil if no item is being dragged
function DragDropManager:get_dragged_item()
    return self.dragged_item
end

---Gets the source of the current drag
---@return table|nil The drag source, or nil if no drag is in progress
function DragDropManager:get_drag_source()
    return self.drag_source
end

---Draws the dragged item at the current mouse position
---@param draw_function function Optional custom draw function that receives (item, x, y)
function DragDropManager:draw_dragged_item(draw_function)
    if not self.dragging or not self.dragged_item then
        return
    end
    
    local mx, my = love.mouse.getPosition()
    local draw_x = mx + self.drag_offset_x
    local draw_y = my + self.drag_offset_y
    
    Debug.debug(Debug, "DragDropManager:draw_dragged_item - Drawing at " .. draw_x .. "," .. draw_y)
    
    if draw_function then
        -- Use custom draw function if provided
        draw_function(self.dragged_item, draw_x, draw_y)
    else
        -- Default drawing behavior
        local r, g, b, a = love.graphics.getColor()
        
        -- Draw a colored rectangle
        if self.dragged_item.color then
            love.graphics.setColor(
                self.dragged_item.color[1],
                self.dragged_item.color[2],
                self.dragged_item.color[3],
                self.dragged_item.color[4] or 0.8
            )
        else
            love.graphics.setColor(1, 0.8, 0.3, 0.8)
        end
        
        -- Draw a larger rectangle for visibility
        love.graphics.rectangle(
            "fill", 
            draw_x - 30, 
            draw_y - 30, 
            60, 
            60
        )
        
        -- Draw item name
        if self.dragged_item.name then
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print(self.dragged_item.name, draw_x - 15, draw_y - 8)
        end
        
        -- Restore color
        love.graphics.setColor(r, g, b, a)
    end
end

return DragDropManager 