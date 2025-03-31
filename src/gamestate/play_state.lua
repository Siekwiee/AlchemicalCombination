-- Imports
local love = require("love")
local Renderer = require("src.renderer.init")
local UIModularGrid = require("src.userInterface.components.modular_grid.init")
local InputManager = require("src.userInput.InputManager")
local ItemManager = require("src.core.items.manager")
local UIInventory = require("src.userInterface.components.inventory.init")

local PlayState = {}

---@class PlayState
---@field new fun(): PlayState
---@field Switchto fun(): void
---@field init fun(): void
---@field draw fun(): void
---@field update fun(dt: number): void
---@field keypressed fun(key: string, scancode: string, isrepeat: boolean): void
---@field mousepressed fun(x: number, y: number, button: number): void
---@field mousereleased fun(x: number, y: number, button: number): void
---@field renderer Renderer
---@field state_name string
---@field ui_buttons table
---@field components table
function PlayState:new()
    local instance = {}
    setmetatable(instance, { __index = PlayState })
    instance.state_name = "playstate"
    instance.ui_buttons = {}
    instance.components = {}

    instance:init()
    return instance
end

function PlayState:init()
    -- Initialize components
    self.components.item_manager = ItemManager:new()
    
    -- Initialize input manager
    self.input_manager = InputManager:new(self)
    
    -- Create a modular grid in the center of the screen
    local screen_width, screen_height = love.graphics.getDimensions()
    local grid_width, grid_height = 300, 300
    local grid_x = (screen_width - grid_width) / 2
    local grid_y = (screen_height - grid_height) / 2
    
    self.components.modular_grid = UIModularGrid:new({
        x = grid_x,
        y = grid_y,
        rows = 4,
        cols = 4,
        cell_width = 64,
        cell_height = 64,
        spacing = 8,
        title = nil,
        input_manager = self.input_manager,  -- Pass the input manager to the grid
        item_manager = self.components.item_manager  -- Pass the item manager to the grid
    })
    
    -- Create inventory UI
    self.components.inventory = UIInventory:new({
        x = 50,
        y = 50,
        max_slots = 10,
        rows = 2,
        item_manager = self.components.item_manager,
        input_manager = self.input_manager
    })
    
    -- Add some sample items for testing
    self:add_sample_items()
end

function PlayState:add_sample_items()
    -- Add basic items from our item manager
    local items = {"water", "fire", "earth", "air"}
    
    -- Place the items in the corners of the grid
    self.components.modular_grid:add_item(1, 1, self.components.item_manager:create_item("water"))
    self.components.modular_grid:add_item(1, 4, self.components.item_manager:create_item("fire"))
    self.components.modular_grid:add_item(4, 1, self.components.item_manager:create_item("earth"))
    self.components.modular_grid:add_item(4, 4, self.components.item_manager:create_item("air"))
end

function PlayState:update(dt)
    -- Update input manager
    if self.input_manager then
        self.input_manager:update(dt)
    end
    
    -- Update modular grid
    if self.components.modular_grid then
        self.components.modular_grid:update(dt)
    end
    
    -- Update inventory
    if self.components.inventory then
        self.components.inventory:update(dt)
    end
end

function PlayState:draw()
    -- Initialize renderer
    self.renderer = Renderer:new()
    self.renderer:draw(self.state_name, self)
    
    -- Draw modular grid directly
    if self.components.modular_grid and self.components.modular_grid.core then
        self.components.modular_grid:draw()
    end
    
    -- Draw inventory
    if self.components.inventory then
        self.components.inventory:draw()
    end
end

function PlayState:keypressed(key, scancode, isrepeat)
    -- Handle key press events
    if key == "g" then
        -- Toggle grid visibility
        if self.components.modular_grid then
            self.components.modular_grid:toggle()
        end
    elseif key == "i" then
        -- Toggle inventory
        if self.components.inventory then
            self.components.inventory:toggle()
        end
    end
end

function PlayState:mousepressed(x, y, button)
    -- Ensure we have an input manager
    if not self.input_manager then
        return false
    end
    
    -- Forward to input manager to handle using its handler system
    return self.input_manager:mousepressed(x, y, button)
end

function PlayState:mousereleased(x, y, button)
    -- Ensure we have an input manager
    if not self.input_manager then
        return false
    end
    
    -- Forward to input manager to handle using its handler system
    return self.input_manager:mousereleased(x, y, button)
end

function PlayState:Switchto()
    love.graphics.clear()
    
    -- Use the global state object if available
    if _G.STATE and _G.STATE.switch_state then
        _G.STATE:switch_state("play")
    else
        -- Fallback to old method if global state not available
        return PlayState:new()
    end
end

return PlayState
