---@class InputState
---@field keys table<string, boolean> Currently pressed keys
---@field mouse table Mouse state information
local InputState = {}
InputState.__index = InputState

---Creates a new input state tracker
---@return InputState
function InputState:new()
  local self = setmetatable({}, self)
  
  -- Key state
  self.keys = {}
  self.keys_pressed = {}
  self.keys_released = {}
  
  -- Mouse state
  self.mouse = {
    x = 0,
    y = 0,
    delta = { x = 0, y = 0 },
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
  
  return self
end

---Updates the input state
---@param dt number Delta time
function InputState:update(dt)
  -- Clear one-frame states
  self.keys_pressed = {}
  self.keys_released = {}
  self.mouse.buttons.pressed = {}
  self.mouse.buttons.released = {}
  self.mouse.wheel.x = 0
  self.mouse.wheel.y = 0
  self.mouse.delta.x = 0
  self.mouse.delta.y = 0
  
  -- Update global mouse position
  self.mouse.x, self.mouse.y = love.mouse.getPosition()
end

---Registers a key press
---@param key string The key that was pressed
---@param scancode string The scancode of the key
---@param isrepeat boolean Whether this is a key repeat event
function InputState:key_pressed(key, scancode, isrepeat)
  if not isrepeat then
    self.keys[key] = true
    self.keys_pressed[key] = true
  end
end

---Registers a key release
---@param key string The key that was released
---@param scancode string The scancode of the key
function InputState:key_released(key, scancode)
  self.keys[key] = false
  self.keys_released[key] = true
end

---Registers a mouse press
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Button that was pressed
function InputState:mouse_pressed(x, y, button)
  self.mouse.x = x
  self.mouse.y = y
  self.mouse.buttons.pressed[button] = true
  self.mouse.buttons.down[button] = true
end

---Registers a mouse release
---@param x number Mouse X position
---@param y number Mouse Y position
---@param button number Button that was released
function InputState:mouse_released(x, y, button)
  self.mouse.x = x
  self.mouse.y = y
  self.mouse.buttons.released[button] = true
  self.mouse.buttons.down[button] = false
end

---Registers mouse movement
---@param x number Mouse X position
---@param y number Mouse Y position
---@param dx number Mouse X movement delta
---@param dy number Mouse Y movement delta
function InputState:mouse_moved(x, y, dx, dy)
  self.mouse.x = x
  self.mouse.y = y
  self.mouse.delta.x = dx
  self.mouse.delta.y = dy
end

---Registers wheel movement
---@param x number Horizontal wheel movement
---@param y number Vertical wheel movement
function InputState:wheel_moved(x, y)
  self.mouse.wheel.x = x
  self.mouse.wheel.y = y
end

---Check if a key is currently down
---@param key string Key to check
---@return boolean Whether the key is down
function InputState:is_key_down(key)
  return self.keys[key] == true
end

---Check if a key was pressed this frame
---@param key string Key to check
---@return boolean Whether the key was pressed this frame
function InputState:is_key_pressed(key)
  return self.keys_pressed[key] == true
end

---Check if a key was released this frame
---@param key string Key to check
---@return boolean Whether the key was released this frame
function InputState:is_key_released(key)
  return self.keys_released[key] == true
end

---Check if a mouse button is currently down
---@param button number Button to check
---@return boolean Whether the button is down
function InputState:is_mouse_down(button)
  return self.mouse.buttons.down[button] == true
end

---Check if a mouse button was pressed this frame
---@param button number Button to check
---@return boolean Whether the button was pressed this frame
function InputState:is_mouse_pressed(button)
  return self.mouse.buttons.pressed[button] == true
end

---Check if a mouse button was released this frame
---@param button number Button to check
---@return boolean Whether the button was released this frame
function InputState:is_mouse_released(button)
  return self.mouse.buttons.released[button] == true
end

---Get the current mouse position
---@return number x, number y Current mouse position
function InputState:get_mouse_position()
  return self.mouse.x, self.mouse.y
end

---Get mouse wheel state
---@return number x, number y Mouse wheel movement this frame
function InputState:get_wheel_movement()
  return self.mouse.wheel.x, self.mouse.wheel.y
end

return InputState 