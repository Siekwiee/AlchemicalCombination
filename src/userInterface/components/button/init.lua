-- Button Initialization (combination of core.lua and visualization.lua)

local ButtonCore = require("src.userInterface.components.button.core")
local ButtonViz = require("src.userInterface.components.button.visualization")

---@class Button
local Button = {}
Button.__index = Button

---Creates a new button
---@param config table Button configuration with x, y, width, height, text, and on_click properties
---@return Button  
function Button:new(config)
    local o = {}
    setmetatable(o, self)
    
    -- Required properties
    o.x = config.x or 0
    o.y = config.y or 0
    o.width = config.width or 100
    o.height = config.height or 40
    
    -- Optional properties
    o.text = config.text or ""
    o.on_click = config.on_click
    o.disabled = config.disabled or false
    
    -- State properties
    o.hover = false
    o.active = false
    
    return o
end

function Button:update(dt)
    -- Update button state based on mouse position
    local mx, my = love.mouse.getPosition()
    ButtonCore.update_state(self, mx, my)
end

function Button:draw()
    -- Draw the button using visualization module
    ButtonViz.draw(self)
end

function Button:check_click(x, y, button)
    if self.disabled then
        return false
    end
    return ButtonCore.check_click(self, x, y, button)
end

return Button
