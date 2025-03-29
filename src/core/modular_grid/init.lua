--This is the init file for the modular grid module
local ModularGrid = {}
ModularGrid.__index = ModularGrid

-- Import components
local ModularGridCore = require("src.core.modular_grid.core")
local ModularGridVisualization = require("src.core.modular_grid.visualization")
local GridCell = require("src.core.grid_cell.init")

-- Forward function declarations
ModularGrid.update = ModularGridCore.update
ModularGrid.get_cell_at = ModularGridCore.get_cell_at
ModularGrid.get_cell_by_position = ModularGridCore.get_cell_by_position
ModularGrid.add_item = ModularGridCore.add_item
ModularGrid.remove_item = ModularGridCore.remove_item
ModularGrid.combine_items = ModularGridCore.combine_items
ModularGrid.draw = ModularGridVisualization.draw
ModularGrid.handle_mouse_pressed = ModularGridCore.handle_mouse_pressed
ModularGrid.handle_mouse_released = ModularGridCore.handle_mouse_released

---Creates a new modular grid
---@param config table Configuration table with x, y, rows, cols, etc.
---@return table The new modular grid instance
function ModularGrid.new(config)
    local grid = {}
    
    -- Set up basic grid properties
    grid.x = config.x or 0
    grid.y = config.y or 0
    grid.rows = config.rows or 3
    grid.cols = config.cols or 3
    grid.cell_width = config.cell_width or 64
    grid.cell_height = config.cell_height or 64
    grid.spacing = config.spacing or 8
    grid.title = config.title
    
    -- Calculate total dimensions
    grid.width = grid.cols * grid.cell_width + (grid.cols - 1) * grid.spacing
    grid.height = grid.rows * grid.cell_height + (grid.rows - 1) * grid.spacing
    
    -- Initialize cells
    grid.cells = {}
    
    -- Initialize selection tracking
    grid.selected_cell = nil
    
    -- Create grid cells
    for row = 1, grid.rows do
        for col = 1, grid.cols do
            local cell_x = grid.x + (col - 1) * (grid.cell_width + grid.spacing)
            local cell_y = grid.y + (row - 1) * (grid.cell_height + grid.spacing)
            
            local id = row .. "," .. col
            local cell = GridCell.new({
                id = id,
                x = cell_x,
                y = cell_y,
                width = grid.cell_width,
                height = grid.cell_height,
                row = row,
                col = col
            })
            
            grid.cells[id] = cell  -- Store by ID instead of using table.insert
        end
    end
    
    return setmetatable(grid, ModularGrid)
end

return ModularGrid