---@class Transformation
---@field type string The type of transformation
---@field row number Grid row
---@field col number Grid column
---@field duration number Total duration of transformation in seconds
---@field timeRemaining number Time remaining until completion in seconds
---@field complete boolean Whether transformation is complete
---@field resultElement string The element that will result from this transformation
---@field grid CombinationGrid Reference to the grid this transformation belongs to

local Transformations = {}

---Create a new transformation object
---@param type string The transformation type
---@param row number Grid row
---@param col number Grid column
---@param duration number Duration in seconds
---@param resultElement string The element that will result
---@param grid CombinationGrid The grid this transformation belongs to
---@return Transformation
function Transformations.create(type, row, col, duration, resultElement, grid)
    return {
        type = type,
        row = row,
        col = col,
        duration = duration,
        timeRemaining = duration,
        complete = false,
        resultElement = resultElement,
        grid = grid
    }
end

---Add a transformation to the grid and transformations list
---@param grid CombinationGrid The grid instance
---@param transformation Transformation The transformation to add
function Transformations.add(grid, transformation)
    -- Store grid reference in the transformation if not already present
    if not transformation.grid then
        transformation.grid = grid
    end
    
    -- Add to active transformations list
    table.insert(grid.transformations, transformation)
    
    -- Ensure the grid cell exists and has the transformation attached
    if grid.grid[transformation.row][transformation.col] then
        grid.grid[transformation.row][transformation.col].transformation = transformation
    else
        print("Warning: Cannot attach transformation to nonexistent grid cell")
    end
    
    -- Trigger event for visualization if available
    if grid.effectBridge then
        grid.effectBridge:onTransformationStart(transformation)
    end
end

---Complete a transformation
---@param grid CombinationGrid The grid instance 
---@param transform Transformation The transformation to complete
---@param index number The index in the transformations array
function Transformations.complete(grid, transform, index)
    transform.complete = true
    
    -- Replace element with the result
    if grid.grid[transform.row][transform.col] then
        grid.grid[transform.row][transform.col].element = transform.resultElement
        grid.grid[transform.row][transform.col].transformation = nil
        
        print("Transformation complete: " .. transform.type .. " at " .. transform.row .. "," .. transform.col)
        
        -- Trigger event for visualization if available
        if grid.effectBridge then
            grid.effectBridge:onTransformationComplete(transform)
        end
    end
    
    -- Remove from active transformations
    table.remove(grid.transformations, index)
end

---Update a single transformation
---@param grid CombinationGrid The grid instance
---@param transform Transformation The transformation to update
---@param dt number Delta time
---@param index number The index in the transformations array
---@return boolean Whether the transformation was completed
function Transformations.update(grid, transform, dt, index)
    -- Update timer
    transform.timeRemaining = transform.timeRemaining - dt
    
    -- Debug output to track transformation progress
    if math.floor(transform.timeRemaining + 0.5) % 5 == 0 then
        print("Transformation at " .. transform.row .. "," .. transform.col .. " - Time remaining: " .. transform.timeRemaining)
    end
    
    -- Calculate progress for visualization
    local progress = 1 - (transform.timeRemaining / transform.duration)
    
    -- Trigger progress event for visualization if available
    if grid.effectBridge then
        grid.effectBridge:onTransformationProgress(transform, progress)
    end
    
    -- Check if transformation is complete
    if transform.timeRemaining <= 0 then
        Transformations.complete(grid, transform, index)
        return true
    end
    
    return false
end

---Debug active transformations
---@param grid CombinationGrid The grid instance
function Transformations.debug(grid)
    print("=== Active Transformations Debug ===")
    print("Total transformations: " .. #grid.transformations)
    
    for i, transform in ipairs(grid.transformations) do
        print("Transformation #" .. i .. ":")
        print("  Type: " .. transform.type)
        print("  Position: " .. transform.row .. "," .. transform.col)
        print("  Time Remaining: " .. transform.timeRemaining .. "/" .. transform.duration)
        print("  Target Element: " .. transform.resultElement)
        
        -- Verify the grid cell
        local gridCell = grid.grid[transform.row][transform.col]
        if gridCell then
            print("  Grid cell exists with element: " .. tostring(gridCell.element))
            if gridCell.transformation then
                print("  Cell has transformation data")
            else
                print("  WARNING: Cell is missing transformation data")
            end
        else
            print("  WARNING: Grid cell is nil!")
        end
    end
    print("===================================")
end

---Update all active transformations
---@param grid CombinationGrid The grid instance
---@param dt number Delta time
function Transformations.updateAll(grid, dt)
    -- Debug active transformations occasionally
    if grid.transformations and #grid.transformations > 0 and math.random() < 0.005 then
        Transformations.debug(grid)
    end
    
    local i = 1
    while i <= #grid.transformations do
        ---@type Transformation
        local transform = grid.transformations[i]
        
        -- Update this transformation
        local completed = Transformations.update(grid, transform, dt, i)
        
        -- Only increment if we didn't remove the current transformation
        if not completed then
            i = i + 1
        end
    end
end

return Transformations 