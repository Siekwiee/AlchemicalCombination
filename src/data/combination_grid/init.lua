local love = require("love")
local json = require("src.data.json")
local Inventory = require("src.data.inventory.inventory")

-- Import sub-modules
local Drawing = require("src.data.combination_grid.drawing")
local CellUtils = require("src.data.combination_grid.cell_utils")
local CombinationLogic = require("src.data.combination_grid.combination_logic")
local GridHandlers = require("src.data.combination_grid.grid_handlers")

---@class CombinationGrid
---@field rows number Number of rows in the grid
---@field columns number Number of columns in the grid
---@field grid table The grid data containing elements
---@field cellSize number Size of each cell in pixels
---@field margin number Margin between cells in pixels
---@field selectedCell table|nil Currently selected cell {row, col}
---@field elements table Element data keyed by element id
---@field materialData table Material properties loaded from JSON
---@field inventory Inventory|nil The player's inventory
---@field new fun(self: CombinationGrid, rows: number, columns: number): CombinationGrid Create a new CombinationGrid
---@field loadMaterials fun(self: CombinationGrid): boolean Load material data from JSON file
---@field update fun(self: CombinationGrid, dt: number) Update the grid
---@field getInventoryKeys fun(self: CombinationGrid): table Get all inventory keys with non-zero counts
---@field getCellPosition fun(self: CombinationGrid, row: number, col: number): number, number Get screen position of a cell
---@field getCellAtPosition fun(self: CombinationGrid, mouseX: number, mouseY: number): number|nil, number|nil Get cell coordinates at screen position
---@field findEmptyCell fun(self: CombinationGrid): number|nil, number|nil Find an empty cell in the grid
---@field draw fun(self: CombinationGrid) Draw the entire combination grid
---@field drawGrid fun(self: CombinationGrid) Draw the grid structure
---@field drawElement fun(self: CombinationGrid, elementName: string, x: number, y: number) Draw a single element
---@field drawInventory fun(self: CombinationGrid, x: number, y: number, width: number, height: number) Draw the inventory interface
---@field drawInventoryItem fun(self: CombinationGrid, elementName: string, count: number, x: number, y: number, size: number) Draw a single inventory item
---@field handleClick fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Handle a click on the grid
---@field handleInventoryClick fun(self: CombinationGrid, x: number, y: number, width: number, height: number): string|nil Handle a click on the inventory
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Add an element from inventory to the grid
---@field removeElementToInventory fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Remove an element from grid and add it to inventory
---@field combineElements fun(self: CombinationGrid, row1: number, col1: number, row2: number, col2: number): boolean Combine two elements on the grid
---@field getCombinationResult fun(self: CombinationGrid, element1: string, element2: string): string|nil Get the result of combining two elements
---@field findRecipeMatch fun(self: CombinationGrid, elements: table): string|nil Find a material that matches the provided recipe elements
local CombinationGrid = {
    rows = 0,
    columns = 0,
    grid = {},
    cellSize = 120,
    margin = 10,
    selectedCell = nil,
    elements = {},
    materialData = {},
    inventory = nil
}

---Create a new CombinationGrid
---@param rows number Number of rows
---@param columns number Number of columns
---@return CombinationGrid
function CombinationGrid:new(rows, columns)
    local o = {}
    setmetatable(o, { __index = self })
    o.rows = rows or 3
    o.columns = columns or 3
    o.grid = {}
    o.cellSize = 120
    o.margin = 10
    o.selectedCell = nil
    o.materialData = {}
    o.elements = {}
    
    -- Initialize inventory
    o.inventory = Inventory:new()
    
    -- Initialize grid
    for i = 1, o.rows do
        o.grid[i] = {}
        for j = 1, o.columns do
            o.grid[i][j] = nil
        end
    end
    
    -- Load materials from JSON
    if not o:loadMaterials() then
        error("Failed to initialize game: Could not load materials data")
    end
    
    -- Apply modules to add functionality to the grid
    Drawing.applyTo(o)
    CellUtils.applyTo(o)
    CombinationLogic.applyTo(o)
    GridHandlers.applyTo(o)
    
    -- Explicitly define the addElementFromInventory method
    o.addElementFromInventory = GridHandlers.addElementFromInventory

    return o
end

---Load material data from JSON file
---@return boolean Success
function CombinationGrid:loadMaterials()
    -- Check if materials file exists
    local info = love.filesystem.getInfo("src/data/materials.json")
    if not info then
        error("Error: materials.json file not found")
        return false
    end
    
    -- Load the materials data
    local contents = love.filesystem.read("src/data/materials.json")
    if not contents then
        error("Error: Could not read materials.json")
        return false
    end
    
    -- Parse JSON
    local success, jsonData = pcall(function() 
        return json.decode(contents)
    end)
    
    if not success or not jsonData then
        error("Error: Failed to parse materials.json: " .. tostring(jsonData))
        return false
    end
    
    -- Validate data structure
    if not jsonData.materials then
        error("Error: Invalid materials.json structure (missing materials)")
        return false
    end
    
    -- Store the data
    self.materialData = jsonData.materials
    
    -- Initialize elements data using materialData
    for elementId, elementData in pairs(self.materialData) do
        self.elements[elementId] = {
            name = elementData.name,
            color = elementData.color
        }
    end
    
    -- Add starting materials to inventory
    self.inventory:addItem("fire", 3)
    self.inventory:addItem("water", 3)
    self.inventory:addItem("earth", 3)
    self.inventory:addItem("air", 3)

    print("Materials loaded successfully")
    return true
end

---Update the grid (animations, etc.)
---@param dt number Delta time
function CombinationGrid:update(dt)
    -- Update grid logic here (animations, etc.)
end

---Get all inventory keys with non-zero counts
---@return table Array of element IDs
function CombinationGrid:getInventoryKeys()
    local keys = {}
    for k, v in pairs(self.inventory:getItems()) do
        if v > 0 then
            table.insert(keys, k)
        end
    end
    return keys
end

return CombinationGrid 