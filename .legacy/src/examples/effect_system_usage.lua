--[[ 
Example demonstrating how to use the refactored effect system
This shows how to:
1. Create visual effects
2. Connect gameplay transformations to visual effects
3. Configure custom effects
--]]

-- Import required modules
local CombinationGrid = require("src.data.combination_grid.init")
local CombinationEffects = require("src.data.combination_effects.init")
local Visualization = require("src.visualization.init")
local Effects = require("src.visualization.effects.init")

-- Example function for using visual effects directly
local function demonstrateVisualEffects()
    print("=== Demonstrating Visual Effects ===")
    
    -- Create a visualization component
    local viz = Visualization:new()
    
    -- Create various effects at positions
    viz.effects:createFlash(100, 100, {1, 0, 0, 0.8}, 1.0, 50) -- Red flash
    viz.effects:createFade(200, 100, {0, 1, 0, 0.8}, 2.0, 60)  -- Green fade
    viz.effects:createTextEffect(300, 100, "Hello, World!", {1, 1, 1, 1}, 3.0) -- Text
    
    -- Show a combination effect
    viz:showCombination(400, 100, "fire", "water", "steam", false)
    
    -- Show a lucky combination with item drop
    viz:showCombination(500, 100, "earth", "crystal", "gold", true, "diamond")
    
    -- Show element effect
    viz:showElement(150, 200, "fire")
    
    -- Show sell effect
    viz:showSell(250, 200, 100)
    
    -- Show item drop
    viz:showItemDrop(350, 200, "rare_crystal")
    
    print("Created various visual effects. In a real game, call viz:update(dt) and viz:draw() in your game loop.")
end

-- Example function for connecting gameplay transformations with visual effects
local function demonstrateTransformationEffects()
    print("=== Demonstrating Transformation Integration ===")
    
    -- Create a combination grid
    local grid = CombinationGrid:new(5, 5)
    
    -- Apply combination effects module
    CombinationEffects.applyTo(grid)
    
    -- Create a visualization component
    local viz = Visualization:new()
    
    -- Connect the visualization to the grid
    grid:connectVisualization(viz)
    
    -- Now gameplay transformations will automatically create visual effects
    -- Example: Start a seed transformation
    grid:startSeedTransformation(2, 3)
    
    -- Example: Simulate combining elements
    grid.grid[1][1] = { element = "fire" }
    grid.grid[1][2] = { element = "water" }
    grid:combineElements(1, 1, 1, 2) -- Will create combination effect automatically
    
    print("Created transformations with integrated visual effects.")
    print("In a real game, update both systems: grid:updateTransformations(dt) and viz:update(dt)")
end

-- Example for extending the effect system with custom effects
local function demonstrateCustomEffects()
    print("=== Demonstrating Custom Effects ===")
    
    -- Create a new custom effect type by inheriting from BaseEffect
    local BaseEffect = require("src.visualization.effects.base_effect")
    
    ---@class RippleEffect : BaseEffect
    ---@field radius number Current radius of the ripple
    ---@field maxRadius number Maximum radius of the ripple
    ---@field thickness number Thickness of the ripple line
    ---@field color table RGBA color values
    local RippleEffect = {}
    setmetatable(RippleEffect, { __index = BaseEffect })
    
    -- Create a new ripple effect
    ---@param x number X position
    ---@param y number Y position
    ---@param color table RGBA color values
    ---@param duration number Duration in seconds
    ---@param maxRadius number Maximum radius
    ---@return RippleEffect
    function RippleEffect:create(x, y, color, duration, maxRadius)
        local params = {
            type = "ripple",
            x = x,
            y = y,
            duration = duration or 1.5
        }
        
        local effect = BaseEffect.create(self, params)
        effect.color = color or {1, 1, 1, 1}
        effect.radius = 0
        effect.maxRadius = maxRadius or 100
        effect.thickness = 3
        
        return effect
    end
    
    -- Update the ripple effect
    ---@param dt number Delta time
    function RippleEffect:update(dt)
        BaseEffect.update(self, dt)
        
        if self.complete then
            return
        end
        
        -- Calculate progress (0 to 1)
        local progress = 1 - (self.timeRemaining / self.duration)
        
        -- Update radius based on progress
        self.radius = self.maxRadius * progress
    end
    
    -- Draw the ripple effect
    function RippleEffect:draw()
        if self.complete then
            return
        end
        
        local love = require("love")
        
        -- Calculate alpha based on progress
        local progress = 1 - (self.timeRemaining / self.duration)
        local alpha = self.color[4] * (1 - progress)
        
        -- Draw ripple circle
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
        love.graphics.setLineWidth(self.thickness)
        love.graphics.circle("line", self.x, self.y, self.radius)
    end
    
    -- Register the custom effect with the Effects module
    _G.RippleEffect = RippleEffect -- Make available globally (for this example only)
    
    print("Created a custom RippleEffect that inherits from BaseEffect")
    print("In a real game, you would add this effect to src/visualization/effects/ directory")
    print("and register it in src/visualization/effects/init.lua")
end

-- Run the examples
local function runExamples()
    demonstrateVisualEffects()
    print("\n")
    demonstrateTransformationEffects()
    print("\n")
    demonstrateCustomEffects()
end

return {
    runExamples = runExamples,
    demonstrateVisualEffects = demonstrateVisualEffects,
    demonstrateTransformationEffects = demonstrateTransformationEffects,
    demonstrateCustomEffects = demonstrateCustomEffects
} 