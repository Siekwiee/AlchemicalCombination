local Debug = require("src.core.debug.init")

---@class InputActions
---@field actions table<string, function> Registered actions that can be triggered by input
---@field default_state table Default state for action parameters
local InputActions = {}
InputActions.__index = InputActions

---Creates a new input actions manager
---@return InputActions
function InputActions:new()
  local self = setmetatable({}, self)
  
  -- Initialize action map
  self.actions = {}
  
  -- Default state for action parameters
  self.default_state = {}
  
  return self
end

---Registers a new action
---@param action_name string Name of the action
---@param callback function Callback function to execute when the action is triggered
function InputActions:register_action(action_name, callback)
  self.actions[action_name] = callback
end

---Sets the default state for action parameters
---@param state table Default state to use when executing actions
function InputActions:set_default_state(state)
  self.default_state = state or {}
end

---Triggers an action by name
---@param action_name string Name of the action to trigger
---@param params table|nil Additional parameters to pass to the action (optional)
---@return boolean Whether the action was triggered successfully
function InputActions:trigger(action_name, params)
  local action = self.actions[action_name]
  
  if not action then
    Debug.debug(Debug, "InputActions - Unknown action: " .. tostring(action_name))
    return false
  end
  
  -- Combine default state with provided params
  local combined_params = {}
  
  -- Copy default state
  for k, v in pairs(self.default_state) do
    combined_params[k] = v
  end
  
  -- Override with provided params
  if params then
    for k, v in pairs(params) do
      combined_params[k] = v
    end
  end
  
  -- Execute the action
  local success, result = pcall(action, combined_params)
  
  if not success then
    Debug.debug(Debug, "InputActions - Error executing action " .. action_name .. ": " .. tostring(result))
    return false
  end
  
  return true
end

---Unregisters an action
---@param action_name string Name of the action to unregister
function InputActions:unregister_action(action_name)
  self.actions[action_name] = nil
end

---Clears all registered actions
function InputActions:clear_actions()
  self.actions = {}
end

return InputActions 