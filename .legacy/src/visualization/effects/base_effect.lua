---@class BaseEffect
---@field type string Type of effect
---@field x number X position
---@field y number Y position
---@field duration number Total duration in seconds
---@field timeRemaining number Time remaining in seconds
---@field complete boolean Whether the effect is complete
local BaseEffect = {}

-- Create a new base effect
---@param params table Parameters including type, x, y, duration
---@return BaseEffect
function BaseEffect:create(params)
    local effect = {
        type = params.type or "base",
        x = params.x or 0,
        y = params.y or 0,
        duration = params.duration or 1.0,
        timeRemaining = params.duration or 1.0,
        complete = false
    }
    
    setmetatable(effect, { __index = self })
    return effect
end

-- Update the effect
---@param dt number Delta time
function BaseEffect:update(dt)
    if self.complete then
        return
    end
    
    self.timeRemaining = self.timeRemaining - dt
    if self.timeRemaining <= 0 then
        self.complete = true
    end
end

-- Draw the effect
function BaseEffect:draw()
    -- Base implementation does nothing
    -- Override in child classes
end

-- Check if the effect is complete
---@return boolean
function BaseEffect:isComplete()
    return self.complete
end

return BaseEffect 