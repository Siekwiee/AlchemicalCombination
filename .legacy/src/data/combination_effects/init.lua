---@class Transformation
---@field type string The type of transformation
---@field row number Grid row
---@field col number Grid column
---@field duration number Total duration of transformation in seconds
---@field timeRemaining number Time remaining until completion in seconds
---@field complete boolean Whether transformation is complete
---@field resultElement string The element that will result from this transformation
---@field grid CombinationGrid Reference to the grid this transformation belongs to

---@class CombinationEffects
---@field applyTo fun(grid: CombinationGrid) Applies this module to a CombinationGrid instance
---@field handleSpecialCombination fun(self: CombinationGrid, element1: string, element2: string, targetRow: number, targetCol: number): boolean Whether a special combination was handled
---@field update fun(self: CombinationGrid, dt: number) Update all active transformations
---@field startSeedTransformation fun(self: CombinationGrid, row: number, col: number) Start a seed transformation process
---@field debugTransformations fun(self: CombinationGrid) Print debug information about active transformations
---@field configureRandomDrops fun(self: CombinationGrid) Configure random drop chances for crafting
---@field connectVisualization fun(self: CombinationGrid, visualization: table) Connect a visualization component for effects

-- Load sub-modules
local Transformations = require("src.data.combination_effects.transformations")
local SpecialCombinations = require("src.data.combination_effects.special_combinations")
local RandomDrops = require("src.data.combination_effects.random_drops")

local CombinationEffects = {}

---Apply this module to a CombinationGrid instance
---@param grid CombinationGrid The CombinationGrid instance
function CombinationEffects.applyTo(grid)
    -- Add functions from this module to the grid
    grid.handleSpecialCombination = CombinationEffects.handleSpecialCombination
    grid.startSeedTransformation = CombinationEffects.startSeedTransformation
    grid.updateTransformations = CombinationEffects.update
    grid.debugTransformations = CombinationEffects.debugTransformations
    grid.configureRandomDrops = CombinationEffects.configureRandomDrops
    grid.connectVisualization = CombinationEffects.connectVisualization
    
    -- Initialize transformations table if not already present
    if not grid.transformations then
        grid.transformations = {}
    end

    -- Configure random drops
    CombinationEffects.configureRandomDrops(grid)
end

---Connect a visualization component for effects
---@param self CombinationGrid The CombinationGrid instance
---@param visualization table The visualization component
function CombinationEffects.connectVisualization(self, visualization)
    if not visualization then
        print("Warning: Cannot connect nil visualization to grid")
        return
    end
    
    self.visualization = visualization
    
    -- Initialize effect bridge if the visualization supports it
    if visualization.connectToGrid then
        visualization:connectToGrid(self)
    end
    
    print("Grid connected to visualization component")
end

---Configure random drop chances for crafting
---@param self CombinationGrid The CombinationGrid instance
function CombinationEffects.configureRandomDrops(self)
    -- RandomDrops are already initialized with default values
    -- We can add custom configurations here if needed
    
    -- For example, we could add different drop chances based on the grid's properties
    -- Or add different side products for different recipes
    
    -- Example: Add a 5% chance to get earth when crafting crystal
    -- RandomDrops.addDropConfig("crystal", "earth", 0.05)
end

---Handle special combinations between elements
---@param self CombinationGrid The CombinationGrid instance
---@param element1 string First element ID
---@param element2 string Second element ID
---@param targetRow number Target row for the result
---@param targetCol number Target column for the result
---@return boolean handled Whether a special combination was handled
function CombinationEffects.handleSpecialCombination(self, element1, element2, targetRow, targetCol)
    -- Call the handler from SpecialCombinations module
    return SpecialCombinations.handle(self, element1, element2, targetRow, targetCol)
end

---Start a seed transformation process
---@param self CombinationGrid The CombinationGrid instance
---@param row number Grid row
---@param col number Grid column
function CombinationEffects.startSeedTransformation(self, row, col)
    -- Call the seed transformation function from SpecialCombinations module
    SpecialCombinations.startSeedTransformation(self, row, col)
end

---Debug active transformations
---@param self CombinationGrid The CombinationGrid instance
function CombinationEffects.debugTransformations(self)
    -- Call the debug function from Transformations module
    Transformations.debug(self)
end

---Update all active transformations
---@param self CombinationGrid The CombinationGrid instance
---@param dt number Delta time
function CombinationEffects.update(self, dt)
    -- Call the update function from Transformations module
    Transformations.updateAll(self, dt)
end

return CombinationEffects
