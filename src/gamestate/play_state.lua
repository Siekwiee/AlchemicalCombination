-- Imports
local Debug = require("src.core.debug.init")
local love = require("love")
local Renderer = require("src.renderer.init")
local UIModularGrid = require("src.userInterface.components.modular_grid.init")
local InputManager = require("src.userInput.Manager")
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
    self.components.debug = Debug
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
        input_manager = self.input_manager  -- Pass the input manager to the grid
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
    
    Debug.debug(Debug, "PlayState:add_sample_items - Added basic items to grid")
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
    -- Debug key press
    Debug.debug(Debug, "PlayState:keypressed - Key: " .. tostring(key))
    
    -- Handle key press events
    if key == "g" then
        -- Toggle grid visibility
        if self.components.modular_grid then
            self.components.modular_grid:toggle()
        end
    elseif key == "d" then
        -- Toggle debug overlay
        if self.components.debug then
            self.components.debug:toggle()
        end
    elseif key == "i" then
        -- Toggle inventory
        Debug.debug(Debug, "PlayState:keypressed - Toggle inventory")
        if self.components.inventory then
            self.components.inventory:toggle()
            Debug.debug(Debug, "PlayState:keypressed - Inventory visibility: " .. tostring(self.components.inventory.visible))
        end
    end
end

function PlayState:mousepressed(x, y, button)
    Debug.debug(Debug, "PlayState:mousepressed - Button " .. button .. " at " .. x .. "," .. y)
    
    -- Ensure we have an input manager
    if not self.input_manager then
        Debug.debug(Debug, "PlayState:mousepressed - No input manager available")
        return false
    end
    
    -- Handle UI elements in proper priority order
    
    -- 1. Try inventory first if visible
    if self.components.inventory and 
       self.components.inventory.visible and 
       self.components.inventory:handle_mouse_pressed(x, y, button) then
        Debug.debug(Debug, "PlayState:mousepressed - Handled by inventory")
        return true
    end
    
    -- 2. Try modular grid if available
    if self.components.modular_grid and self.components.modular_grid.core then
        -- Let input manager handle all grid interactions
        local result = self.input_manager:handle_grid_click(
            self.components.modular_grid.core,
            x, y, button
        )
        Debug.debug(Debug, "PlayState:mousepressed - Grid handling result: " .. tostring(result))
        return result
    end
    
    return false
end

function PlayState:mousereleased(x, y, button)
    Debug.debug(Debug, "PlayState:mousereleased - Button " .. button .. " at " .. x .. "," .. y)
    
    -- Ensure we have an input manager
    if not self.input_manager then
        Debug.debug(Debug, "PlayState:mousereleased - No input manager available")
        return false
    end
    
    -- Handle UI elements in proper priority order
    
    -- 1. Try inventory first if visible
    if self.components.inventory and 
       self.components.inventory.visible and 
       type(self.components.inventory.handle_mouse_released) == "function" then
        local result = self.components.inventory:handle_mouse_released(x, y, button)
        if result then
            Debug.debug(Debug, "PlayState:mousereleased - Handled by inventory")
            return true
        end
    end
    
    -- 2. Try modular grid if available
    if self.components.modular_grid and self.components.modular_grid.core then
        local result = self.components.modular_grid:handle_mouse_released(x, y, button)
        Debug.debug(Debug, "PlayState:mousereleased - Grid handling result: " .. tostring(result))
        return result
    end
    
    return false
end

function PlayState:Switchto()
    love.graphics.clear()
    Debug.debug(Debug, "Switching to Play State")
    
    -- Use the global state object if available
    if _G.STATE and _G.STATE.switch_state then
        _G.STATE:switch_state("play")
    else
        -- Fallback to old method if global state not available
        return PlayState:new()
    end
end

return PlayState
