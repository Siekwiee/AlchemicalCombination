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
    return MenuStateHandler:new(game_state)
  end
  
  local state_name = game_state.current_state.state_name
  
  if state_name == "playstate" or state_name == "playing" then
    return PlayStateHandler:new(game_state)
  elseif state_name == "menu" or state_name == "mainmenu" then
    return MenuStateHandler:new(game_state)
  end
  
  -- Default to menu handler if state is unknown
  return MenuStateHandler:new(game_state)
end

return StateHandlerFactory 