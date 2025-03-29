--This is the init file for the renderer module
local Renderer = {}
Renderer.__index = Renderer

local Background = require("src.renderer.background")
local Entities = require("src.renderer.entities")
local UI = require("src.renderer.ui")

---@class Renderer
---@field new fun(): Renderer
---@field draw fun(self: Renderer, state_name: string, GameState: GameState)
---@field drawBackground fun(game_state: GameState)
---@field drawEntities fun(game_state: GameState)
---@field drawUI fun(game_state: GameState)
---@field layers table<string, number>
---@field game_state GameState
function Renderer:new()
    local self = setmetatable({}, self)

    self:init()
    return self
end

function Renderer:init()
    self.layers = {
        "background",
        "entities",
        "ui"
    }
end

function Renderer:draw(state_name, GameState)
    self.state_name = state_name
    self.game_state = GameState
    
    -- Make sure GameState has a valid state_name
    if GameState and not GameState.state_name then
        GameState.state_name = state_name
    end
    
    Background:drawBackground(GameState)
    --self:drawEntities()  -- Keep entities commented as they may not be needed in menu
    UI:drawUI(state_name, GameState)
end

return Renderer

