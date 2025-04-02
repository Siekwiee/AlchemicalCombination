-- Imports
local love = require("love")
local Renderer = require("src.renderer.init")
local UIModularGrid = require("src.userInterface.components.modular_grid.init")
local InputManager = require("src.userInput.InputManager")
local ItemManager = require("src.core.items.manager")
local UIInventory = require("src.userInterface.components.inventory.init")
local Shop = require("src.core.shop-legacy.init")
local ShopCore = require("src.core.shop-legacy.core")
local ShopHandlers = require("src.core.shop-legacy.handlers")
local ShopDrawing = require("src.core.shop-legacy.drawing")
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
    
    -- Initialize input manager first, so other components can use it
    self.input_manager = InputManager:new(self)

    -- Add shop handler to input manager
    local ShopHandler = require("src.userInput.handlers.ShopHandler")
    self.input_manager.handlers.shop = ShopHandler:new(self)

    -- Initialize UI Manager
    local UIManager = require("src.userInterface.Manager")
    self.ui_manager = UIManager:new(self)
    
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
        input_manager = self.input_manager,
        item_manager = self.components.item_manager
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
    
    -- Create shop UI
    self.components.shop = Shop:new()
    self.components.shop:setInventory(self.components.inventory)

    -- Add some sample items for testing
    self:add_sample_items()
    
    -- Initialize renderer
    self.renderer = Renderer:new()
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
    -- Use the already initialized renderer
    if self.renderer then
        self.renderer:draw(self.state_name, self)
    end
    
    -- Draw modular grid
    if self.components.modular_grid then
        self.components.modular_grid:draw()
    end
    
    -- Draw inventory
    if self.components.inventory then
        self.components.inventory:draw()
    end

    -- Draw shop
    if self.components.shop then
        self.components.shop:draw()
    end
end

function PlayState:keypressed(key, scancode, isrepeat)
    -- Let the input manager handle keypress first
    if self.input_manager and self.input_manager:keypressed(key, scancode, isrepeat) then
        return true
    end
    
    -- Fallback to direct handling for specific keys
    if key == "g" then
        -- Toggle grid visibility
        if self.components.modular_grid then
            self.components.modular_grid:toggle()
            return true
        end
    elseif key == "i" then
        -- Toggle inventory
        if self.components.inventory then
            self.components.inventory:toggle()
            return true
        end
    end
    
    return false
end

function PlayState:mousepressed(x, y, button)
    -- ONLY use input manager to handle mouse events
    -- Never directly call component handlers
    if self.input_manager then
        return self.input_manager:mousepressed(x, y, button)
    end
    return false
end

function PlayState:mousereleased(x, y, button)
    -- ONLY use input manager to handle mouse events
    -- Never directly call component handlers
    if self.input_manager then
        return self.input_manager:mousereleased(x, y, button)
    end
    return false
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
