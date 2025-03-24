local love = require("love")
local json = require("src.data.json")
local Inventory = require("src.data.inventory.inventory")

---@class Inventory
---@field new fun(self: Inventory): Inventory Create a new inventory instance
---@field addItem fun(self: Inventory, itemName: string, count: number) Add items to inventory
---@field removeItem fun(self: Inventory, itemName: string, count: number) Remove items from inventory
---@field getItems fun(self: Inventory): {[string]: number} Get all items in inventory
---@field getItemCount fun(self: Inventory, itemName: string): number Get count of a specific item

-- Import sub-modules
local Drawing = require("src.data.combination_grid.drawing")
local CellUtils = require("src.data.combination_grid.cell_utils")
local CombinationLogic = require("src.data.combination_grid.combination_logic")
local GridHandlers = require("src.data.combination_grid.grid_handlers")
local CombinationEffects = require("src.data.combination_effects.init")

---@class GridCell
---@field element string The element ID in this cell
---@field transformation Transformation|nil Transformation data if element is transforming

---@class CombinationGrid
---@field rows number Number of rows in the grid
---@field columns number Number of columns in the grid
---@field grid GridCell[][] The grid data containing elements
---@field cellSize number Size of each cell in pixels
---@field margin number Margin between cells in pixels
---@field selectedCell {row: number, col: number}|nil Currently selected cell
---@field elements {[string]: {name: string, color: number[]}} Element data keyed by element id
---@field materialData {[string]: {name: string, color: number[], tier: number, description: string, value: number, recipe: table|nil}} Material properties loaded from JSON
---@field inventory Inventory|nil The player's inventory
---@field transformations Transformation[] Active transformations in the grid
-- Function fields
---@field new fun(self: CombinationGrid, rows: number, columns: number): CombinationGrid Create a new CombinationGrid
---@field loadMaterials fun(self: CombinationGrid): boolean Load material data from JSON file
---@field update fun(self: CombinationGrid, dt: number) Update the grid
---@field getInventoryKeys fun(self: CombinationGrid): string[] Get all inventory keys with non-zero counts
-- Cell Utility fields
---@field getCellPosition fun(self: CombinationGrid, row: number, col: number): number, number Get screen position of a cell
---@field getCellAtPosition fun(self: CombinationGrid, mouseX: number, mouseY: number): number|nil, number|nil Get cell coordinates at screen position
---@field findEmptyCell fun(self: CombinationGrid): number|nil, number|nil Find an empty cell in the grid
-- Drawing fields
---@field draw fun(self: CombinationGrid) Draw the entire combination grid
---@field drawGrid fun(self: CombinationGrid) Draw the grid structure
---@field drawElement fun(self: CombinationGrid, elementName: string, x: number, y: number) Draw a single element
---@field drawInventory fun(self: CombinationGrid, x: number, y: number, width: number, height: number) Draw the inventory interface
---@field drawInventoryItem fun(self: CombinationGrid, elementName: string, count: number, x: number, y: number, size: number) Draw a single inventory item
---@field drawEffects fun(self: CombinationGrid) Draw visualization effects
-- Grid Handler fields
---@field handleClick fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Handle a click on the grid
---@field handleInventoryClick fun(self: CombinationGrid, x: number, y: number, width: number, height: number): string|nil Handle a click on the inventory
---@field addElementFromInventory fun(self: CombinationGrid, elementName: string, row: number, col: number): boolean Add an element from inventory to the grid
---@field removeElementToInventory fun(self: CombinationGrid, x: number, y: number): boolean, string|nil, number, number Remove an element from grid and add it to inventory
-- Combination Logic fields
---@field combineElements fun(self: CombinationGrid, row1: number, col1: number, row2: number, col2: number): boolean Combine two elements on the grid
---@field getCombinationResult fun(self: CombinationGrid, element1: string, element2: string): string|nil Get the result of combining two elements
---@field findRecipeMatch fun(self: CombinationGrid, elements: table): string|nil Find a material that matches the provided recipe elements
-- Combination Effects fields
---@field handleSpecialCombination fun(self: CombinationGrid, element1: string, element2: string, targetRow: number, targetCol: number): boolean Handle special combinations between elements
---@field updateTransformations fun(self: CombinationGrid, dt: number) Update all active transformations
---@field startSeedTransformation fun(self: CombinationGrid, row: number, col: number) Start a seed transformation process
---@field debugTransformations fun(self: CombinationGrid) Print debug information about active transformations

local CombinationGrid = {
    rows = 0,
    columns = 0,
    grid = {},
    cellSize = 120,
    margin = 10,
    selectedCell = nil,
    elements = {},
    materialData = {},
    inventory = nil,
    transformations = {}
}


---@raise Error if materials data cannot be loaded
function CombinationGrid:new(rows, columns)
    -- Validate input parameters
    
    if type(rows) ~= "number" or rows < 2 then
        error("Invalid rows parameter: must be a number >= 2")
    end
    
    if type(columns) ~= "number" or columns < 2 then
        error("Invalid columns parameter: must be a number >= 2")
    end
    
    local o = {}
    setmetatable(o, { __index = self })
    
    -- Initialize core properties
    -- Initialize the game state and visualization
    local Visualization = require("src.visualization.init")
    o.visualization = Visualization:new()
    o.rows = rows
    o.columns = columns
    o.cellSize = 120
    o.margin = 10
    o.selectedCell = nil
    o.materialData = {}
    o.elements = {}
    o.transformations = {}
    
    -- Initialize the inventory system
    o.inventory = Inventory:new()
    if not o.inventory then
        error("Failed to initialize game: Could not create inventory")
    end
    
    -- Initialize grid structure
    o.grid = {}
    for i = 1, o.rows do
        o.grid[i] = {}
        for j = 1, o.columns do
            o.grid[i][j] = nil
        end
    end
    
    -- Load material data
    local materialLoadSuccess = o:loadMaterials()
    if not materialLoadSuccess then
        error("Failed to initialize game: Could not load materials data")
    end
    
    -- Apply all functional modules
    print("Applying modules to combination grid...")
    Drawing.applyTo(o)
    CellUtils.applyTo(o)
    CombinationLogic.applyTo(o)
    GridHandlers.applyTo(o)
    CombinationEffects.applyTo(o)
    
    
    
    -- Set the effects manager for RandomDrops
    local RandomDrops = require("src.data.combination_effects.random_drops")
    RandomDrops.setEffectsManager(o.visualization.effects)
    
    -- Explicitly define methods that might have conflicts
    o.addElementFromInventory = GridHandlers.addElementFromInventory

    print("CombinationGrid initialized with " .. rows .. "x" .. columns .. " grid")
    return o
end

---Load material data from JSON file
---@return boolean success Whether materials were loaded successfully
function CombinationGrid:loadMaterials()
    print("Loading materials data...")
    
    -- Check if materials file exists
    local materialsPath = "src/data/materials.json"
    local info = love.filesystem.getInfo(materialsPath)
    if not info then
        error("Error: materials.json file not found at path: " .. materialsPath)
        return false
    end
    
    -- Load the materials data
    local contents = love.filesystem.read(materialsPath)
    if not contents then
        error("Error: Could not read materials.json")
        return false
    end
    
    -- Parse JSON with error handling
    local success, jsonData = pcall(function() 
        return json.decode(contents)
    end)
    
    if not success or not jsonData then
        error("Error: Failed to parse materials.json: " .. tostring(jsonData))
        return false
    end
    
    -- Validate data structure
    if not jsonData.materials then
        error("Error: Invalid materials.json structure (missing materials object)")
        return false
    end
    
    -- Store the data
    self.materialData = jsonData.materials
    
    -- Initialize elements data using materialData
    self.elements = {}
    for elementId, elementData in pairs(self.materialData) do
        if not elementData.name or not elementData.color then
            print("Warning: Material '" .. elementId .. "' is missing required fields")
        end
        
        self.elements[elementId] = {
            name = elementData.name or elementId,
            color = elementData.color or {255, 255, 255}
        }
    end
    
    -- Load random drop configurations from materials data
    local RandomDrops = require("src.data.combination_effects.random_drops")
    RandomDrops.loadFromMaterialsData(self.materialData)
    
    -- Add starting materials to inventory
    local startingMaterials = {
        ["fire"] = 3,
        ["water"] = 3,
        ["earth"] = 3,
        ["air"] = 3,
        ["seed"] = 3
    }
    
    for element, count in pairs(startingMaterials) do
        if self.elements[element] then
            self.inventory:addItem(element, count)
            print("Added " .. count .. "x " .. element .. " to starting inventory")
        else
            print("Warning: Starting material '" .. element .. "' not found in materials data")
        end
    end
    
    -- Count the elements properly
    local elementCount = 0
    for _ in pairs(self.elements) do
        elementCount = elementCount + 1
    end
    
    print("Materials loaded successfully: " .. elementCount .. " elements available")
    return true
end

---Update the grid (animations, etc.)
---@param dt number Delta time
function CombinationGrid:update(dt)
    -- Debug the number of active transformations
    if self.transformations and #self.transformations > 0 then
        -- Periodically run full debug
        if math.random() < 0.02 and self.debugTransformations then
            self:debugTransformations()
        end
    end
    
    -- Update transformations if they exist
    if self.updateTransformations then
        self:updateTransformations(dt)
    else
        print("Warning: updateTransformations function not found")
    end
    
    -- Update visualization effects
    if self.visualization then
        self.visualization:update(dt)
    end
end

---Get all inventory keys with non-zero counts
---@return string[] Array of element IDs
function CombinationGrid:getInventoryKeys()
    local keys = {}
    
    if not self.inventory then
        print("Warning: Inventory is nil when getting inventory keys")
        return keys
    end
    
    local items = self.inventory:getItems()
    if not items then
        print("Warning: No items found in inventory")
        return keys
    end
    
    for k, v in pairs(items) do
        if v > 0 then
            table.insert(keys, k)
        end
    end
    
    return keys
end

-- Add the drawEffects method to the existing drawing code
function CombinationGrid:drawEffects()
    if self.visualization then
        self.visualization:draw()
    end
end

return CombinationGrid 