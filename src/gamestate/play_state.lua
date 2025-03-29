-- Imports
local Debug = require("src.core.debug.init")
local love = require("love")
local Renderer = require("src.renderer.init")
local UIModularGrid = require("src.userInterface.components.modular_grid.init")
local InputManager = require("src.userInput.Manager")

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
    Debug.debug(Debug, "PlayState:init - Initializing play state")
    
    -- Initialize components
    self.components.debug = Debug
    
    -- Initialize input manager
    self.input_manager = InputManager:new(self)
    
    -- Create a modular grid in the center of the screen
    local screen_width, screen_height = love.graphics.getDimensions()
    local grid_width, grid_height = 300, 300
    local grid_x = (screen_width - grid_width) / 2
    local grid_y = (screen_height - grid_height) / 2
    
    Debug.debug(Debug, "PlayState:init - Creating modular grid at " .. grid_x .. ", " .. grid_y)
    
    self.components.modular_grid = UIModularGrid:new({
        x = grid_x,
        y = grid_y,
        rows = 4,
        cols = 4,
        cell_width = 64,
        cell_height = 64,
        spacing = 8,
        title = "Alchemical Grid"
    })
    
    if not self.components.modular_grid then
        Debug.debug(Debug, "PlayState:init - ERROR: Failed to create modular grid")
    elseif not self.components.modular_grid.core then
        Debug.debug(Debug, "PlayState:init - ERROR: Modular grid has no core")
    elseif not self.components.modular_grid.core.draw then 
        Debug.debug(Debug, "PlayState:init - ERROR: Modular grid core has no draw function")
    else
        Debug.debug(Debug, "PlayState:init - Successfully created modular grid")
    end
    
    -- Add some sample items for testing
    self:add_sample_items()
end

function PlayState:add_sample_items()
    -- Add some sample items to the grid
    self.components.modular_grid:add_item(1, 1, {
        type = "water",
        name = "Water",
        level = 1
    })
    
    self.components.modular_grid:add_item(1, 4, {
        type = "fire",
        name = "Fire",
        level = 1
    })
    
    self.components.modular_grid:add_item(4, 1, {
        type = "earth",
        name = "Earth",
        level = 1
    })
    
    self.components.modular_grid:add_item(4, 4, {
        type = "air",
        name = "Air",
        level = 1
    })
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
end

function PlayState:draw()
    Debug.debug(Debug, "PlayState:draw - Starting draw")
    
    -- Initialize renderer
    self.renderer = Renderer:new()
    self.renderer:draw(self.state_name, self)
    
    -- Draw modular grid directly, bypassing the UI manager if needed
    if self.components.modular_grid then
        Debug.debug(Debug, "PlayState:draw - Drawing modular grid directly")
        
        -- Ensure modular grid has core component
        if not self.components.modular_grid.core then
            Debug.debug(Debug, "PlayState:draw - ERROR: Modular grid has no core")
            return
        end
        
        -- Try to draw the grid directly without going through the UI layer
        if type(self.components.modular_grid.core.draw) == "function" then
            self.components.modular_grid.core:draw()
        else
            Debug.debug(Debug, "PlayState:draw - ERROR: Modular grid core.draw is not a function")
        end
    else
        Debug.debug(Debug, "PlayState:draw - ERROR: No modular grid to draw")
    end
end

function PlayState:keypressed(key, scancode, isrepeat)
    -- Handle key press events
    if key == "g" then
        -- Toggle grid visibility
        if self.components.modular_grid then
            self.components.modular_grid:toggle()
        end
    end
end

function PlayState:mousepressed(x, y, button)
    -- Forward to modular grid first
    if self.components.modular_grid and self.components.modular_grid:handle_mouse_pressed(x, y, button) then
        return
    end
    
    -- Handle other mouse press events
end

function PlayState:mousereleased(x, y, button)
    -- Forward to modular grid first
    if self.components.modular_grid and self.components.modular_grid:handle_mouse_released(x, y, button) then
        return
    end
    
    -- Handle other mouse release events
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
