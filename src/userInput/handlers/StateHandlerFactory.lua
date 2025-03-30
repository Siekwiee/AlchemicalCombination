local Debug = require("src.core.debug.init")

-- Import state handlers
local PlayStateHandler = require("src.userInput.handlers.state.PlayStateHandler")
local MenuStateHandler = require("src.userInput.handlers.state.MenuStateHandler")

---Factory for creating state-specific input handlers
local StateHandlerFactory = {}

---Creates an appropriate handler for the current game state
---@param game_state GameState Game state reference
---@return table The appropriate input handler for the current state
function StateHandlerFactory:create_handler(game_state)
  -- Check current state and create appropriate handler
  if not game_state.current_state then
    Debug.debug(Debug, "StateHandlerFactory - No current state found, using default")
    return MenuStateHandler:new(game_state)
  end
  
  local state_name = game_state.current_state.state_name
  
  if state_name == "playstate" or state_name == "playing" then
    Debug.debug(Debug, "StateHandlerFactory - Creating PlayStateHandler")
    return PlayStateHandler:new(game_state)
  elseif state_name == "menu" or state_name == "mainmenu" then
    Debug.debug(Debug, "StateHandlerFactory - Creating MenuStateHandler")
    return MenuStateHandler:new(game_state)
  end
  
  -- Default to menu handler if state is unknown
  Debug.debug(Debug, "StateHandlerFactory - Unknown state: " .. tostring(state_name) .. ", using default")
  return MenuStateHandler:new(game_state)
end

return StateHandlerFactory 