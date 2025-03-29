-- Imports
local Debug = require("src.core.debug.init")
local love = require("love")

local PlayState = {}

---@class PlayState
---@field new fun(): PlayState
---@field Switchto fun(): void
---@field init fun(): void
---@field draw fun(): void
---@field renderer Renderer
---@field state_name string
function PlayState:new()
    local instance = {}
    setmetatable(instance, { __index = PlayState })
    self.state_name = "playstate"

    self:init()
    return self
end

function PlayState:init()
    self.renderer = Renderer:new()
end

function PlayState:draw()
    self.renderer:draw(self)
end

function PlayState:Switchto()
    love.graphics.clear()
    Debug.debug(Debug, "Playing")
    PlayState:new()
end
return PlayState
