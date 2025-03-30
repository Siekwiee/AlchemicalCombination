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

---Creates a new button
---@param config table Button configuration with x, y, width, height, text, and on_click properties
---@return Button  
function Button:new(config)
    local o = {}
    setmetatable(o, {__index = self})
    -- Required properties
    if config.buttons then
        o.buttons = config.buttons or {}
    end
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
    self.hover = ButtonCore.update_state(self, mx, my)
end

function Button:draw()
    -- Draw the button using visualization module
    ButtonViz.draw(self)
end

function Button:check_click(x, y, button)
    Debug.debug(Debug, "Button:check_click for " .. self.text .. " at " .. x .. "," .. y)
    
    if self.disabled then
        return false
    end
    
    local is_clicked = ButtonCore.check_click(self, x, y, button)
    
    if is_clicked and self.on_click then
        Debug.debug(Debug, "Button clicked: " .. self.text)
        self.on_click()
        return true
    end
    
    return false
end

return Button
