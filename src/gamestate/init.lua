--This is the init file for the gamestate module

local Gamestate = {}


---@class Gamestate
---@field state Gamestate
---@field allStates table<string, Gamestate>
---@field deltaTime number
---@return Gamestate
function Gamestate:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end




