---@class InputBindings
---@field key_map table<string, string> Maps action names to keys
---@field button_map table<string, number> Maps action names to mouse buttons
local InputBindings = {}
InputBindings.__index = InputBindings

---Creates a new input bindings manager
---@param initial_bindings table|nil Initial bindings configuration (optional)
---@return InputBindings
function InputBindings:new(initial_bindings)
  local self = setmetatable({}, self)
  
  -- Initialize empty bindings
  self.key_map = {}
  self.button_map = {}
  
  -- Apply initial bindings if provided
  if initial_bindings then
    self:set_bindings(initial_bindings)
  end
  
  return self
end

---Sets key and button bindings
---@param bindings table Bindings configuration
function InputBindings:set_bindings(bindings)
  if bindings.keys then
    for action, key in pairs(bindings.keys) do
      self.key_map[action] = key
    end
  end
  
  if bindings.buttons then
    for action, button in pairs(bindings.buttons) do
      self.button_map[action] = button
    end
  end
end

---Gets the key bound to an action
---@param action string Action name
---@return string|nil Key bound to the action or nil if not found
function InputBindings:get_key(action)
  return self.key_map[action]
end

---Gets the mouse button bound to an action
---@param action string Action name
---@return number|nil Button bound to the action or nil if not found
function InputBindings:get_button(action)
  return self.button_map[action]
end

---Gets the action bound to a key
---@param key string Key to check
---@return string|nil Action bound to the key or nil if not found
function InputBindings:get_action_for_key(key)
  for action, bound_key in pairs(self.key_map) do
    if bound_key == key then
      return action
    end
  end
  return nil
end

---Gets the action bound to a mouse button
---@param button number Button to check
---@return string|nil Action bound to the button or nil if not found
function InputBindings:get_action_for_button(button)
  for action, bound_button in pairs(self.button_map) do
    if bound_button == button then
      return action
    end
  end
  return nil
end

---Binds a key to an action
---@param action string Action name
---@param key string Key to bind
function InputBindings:bind_key(action, key)
  self.key_map[action] = key
end

---Binds a mouse button to an action
---@param action string Action name
---@param button number Button to bind
function InputBindings:bind_button(action, button)
  self.button_map[action] = button
end

---Clears all bindings
function InputBindings:clear()
  self.key_map = {}
  self.button_map = {}
end

---Saves current bindings to a configuration table
---@return table Configuration table with current bindings
function InputBindings:to_config()
  return {
    keys = self.key_map,
    buttons = self.button_map
  }
end

return InputBindings 