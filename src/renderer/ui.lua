local UIManager = require("src.userInterface.Manager")
local Debug = require("src.core.debug.init")

local UI = {}
UI.__index = UI

---@class UI
---@field ui_manager UIManager
---@field drawUI fun(state_name: string, GameState: GameState)
function UI:drawUI(state_name, GameState)
    Debug.debug(Debug, "UI:drawUI - Starting UI draw")
    if GameState then
        Debug.debug(Debug, "UI:drawUI - GameState exists")
        if GameState.ui_buttons then
            Debug.debug(Debug, "UI:drawUI - Found " .. #GameState.ui_buttons .. " buttons in GameState")
        else
            Debug.debug(Debug, "UI:drawUI - No ui_buttons in GameState")
        end
        
        -- Check for modular grid
        if GameState.components and GameState.components.modular_grid then
            Debug.debug(Debug, "UI:drawUI - Found modular grid in GameState")
        end
    else
        Debug.debug(Debug, "UI:drawUI - No GameState provided")
    end
    
    --draw ui
    local ui_manager = UIManager:new(GameState)
    ui_manager:draw()
    
    --draw the fps counter
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
end

return UI

