-- Element colors module for visualization
local ElementColors = {}

-- Default element colors
ElementColors.colors = {
    default = {1, 1, 1, 0.8}, -- Default white
    fire = {1, 0.3, 0, 0.8}, -- Orange
    water = {0, 0.5, 1, 0.8}, -- Blue
    earth = {0.5, 0.3, 0.1, 0.8}, -- Brown
    air = {0.9, 0.9, 1, 0.6}, -- Light blue
    metal = {0.7, 0.7, 0.7, 0.8}, -- Silver
    crystal = {0.5, 0.8, 0.9, 0.7}, -- Light blue crystal
    steam = {0.9, 0.9, 0.9, 0.6}, -- White vapor
    lava = {1.0, 0.4, 0.1, 0.8}, -- Bright orange
    -- Add more elements as needed
}

-- Get color for a specific element type
function ElementColors:getColor(elementType)
    return self.colors[elementType] or self.colors.default
end

-- Register a new element color
function ElementColors:registerColor(elementType, color)
    self.colors[elementType] = color
end

return ElementColors 