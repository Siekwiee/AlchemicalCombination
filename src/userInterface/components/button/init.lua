-- Button Initialization (combination of core.lua and visualization.lua)
local Debug = require("src.core.debug.init")
local ButtonCore = require("src.userInterface.components.button.core")
local ButtonViz = require("src.userInterface.components.button.visualization")

---@class Button
---@field x number
---@field y number
---@field width number
---@field height number
---@field text string
---@field on_click function
---@field disabled boolean
local Button = {}
Button.__index = Button
---TODO: Add check_click function
---Creates a new button
---@param config table Button configuration with x, y, width, height, text, and on_click properties
---@return Button  
function Button:new(config)
    local o = {}
    setmetatable(o, {__index = self})
    -- Required properties
    if config.buttons then
---@diagnostic disable-next-line: deprecated
        local a = unpack(config.buttons)
        o.buttons = config.buttons or {}
        Debug.debug(Debug, "Button:new " .. table.concat(a, ", "))
    end
    o.x = config.x or 0
    o.y = config.y or 0
    o.width = config.width or 100
    o.height = config.height or 40
    self.check_click = ButtonCore.check_click
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
    self.hover = ButtonCore.update_state(self, mx, my)
end

function Button:draw()
    -- Draw the button using visualization module
    ButtonViz.draw(self)
end

function Button:check_click(x, y, button)
    if self.disabled then
        return false
    end
    if self:check_click(x, y, button) then
        self.on_click()
        return true
    end
    return false
end

return Button
