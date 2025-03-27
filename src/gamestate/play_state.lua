-- Imports
local Debug = require("src.core.debug.init")
local love = require("love")

local PlayState = {}

---@class PlayState
---@field new fun(): PlayState
---@field Switchto fun(gameState: GameState): void
function PlayState:new()
    local instance = {}
    setmetatable(instance, {__index = self})

    instance.renderer = Renderer:new(instance)
    return instance
end

function PlayState:Switchto(gameState)
    love.graphics.clear()
    Debug.debug(Debug, "Playing")
    gameState.current_state = PlayState:new()
end
return PlayState
