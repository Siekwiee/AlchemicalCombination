local UIManager = require("src.userInterface.Manager")

local UI = {}
UI.__index = UI

-- Store UI managers by game state to avoid recreation
local ui_managers = {}

---@class UI
---@field ui_manager UIManager
---@field drawUI fun(state_name: string, GameState: GameState)
function UI:drawUI(state_name, GameState)
    -- Get or create a UI manager for this game state
    local ui_manager
    if GameState and GameState.state_name then
        if not ui_managers[GameState.state_name] then
            ui_managers[GameState.state_name] = UIManager:new(GameState)
        end
        ui_manager = ui_managers[GameState.state_name]
    else
        -- Fallback for states without names
        ui_manager = UIManager:new(GameState)
    end
    
    -- Draw the UI
    ui_manager:draw()
    
    -- Draw the fps counter
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
end

return UI

