--This is the init file for the renderer module
local Renderer = {}
Renderer.__index = Renderer

local Background = require("src.renderer.background")
local Entities = require("src.renderer.entities")
local UI = require("src.renderer.ui")

---@class Renderer
---@field new fun(game_state: GameState): Renderer
---@field draw fun(self: Renderer)
---@field drawBackground fun(self: Renderer)
---@field drawEntities fun(self: Renderer)
---@field drawUI fun(self: Renderer)
---@field layers table<string, number>
function Renderer:new(game_state)
    local self = setmetatable({}, self)
    self.game_state = game_state
    self.layers = {
      "background",
      "entities",
      "ui"
    }
    
    return self
end

function Renderer:draw()
    self.drawBackground = Background:drawBackground(self)
    --self:drawEntities()
    --self:drawUI()
end

return Renderer

