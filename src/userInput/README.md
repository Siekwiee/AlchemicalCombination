# Input System

This directory contains a modular, extensible input system for handling keyboard, mouse, and touch input in a scalable way.

## Architecture

The input system is divided into several components:

### Core Components

- `InputManager`: Main entry point that receives Love2D input events and forwards them to the appropriate handlers.
- `InputState`: Tracks the current state of input devices (key presses, mouse position, etc.).
- `InputBindings`: Maps game actions to specific keys or buttons.

### Handlers

- `InputHandler`: Base class for all input handlers.
- `GridHandler`: Specialized handler for grid interactions.
- `UIHandler`: Specialized handler for UI interactions.
- `InventoryHandler`: Specialized handler for inventory interactions.
- `StateHandlerFactory`: Creates appropriate state handlers based on game state.

### State Handlers

- `PlayStateHandler`: Handles input for the play state.
- `MenuStateHandler`: Handles input for the menu state.

### Utilities

- `InputDetection`: Utility functions for detecting input (point in rect, etc.).
- `InputActions`: Maps input to game actions with parameters.

## Usage

### Basic Setup

```lua
local InputManager = require("src.userInput.InputManager")

-- Create input manager
local input_manager = InputManager:new(game_state)

-- In Love2D callbacks
function love.keypressed(key, scancode, isrepeat)
  input_manager:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button)
  input_manager:mousepressed(x, y, button)
end

-- etc.

-- Update in game loop
function love.update(dt)
  input_manager:update(dt)
end
```

### Custom Keybindings

```lua
-- Create custom bindings
local custom_bindings = {
  keys = {
    inventory_toggle = "tab",
    crafting_open = "e",
    -- other key bindings
  },
  buttons = {
    -- mouse button bindings
  }
}

-- Set bindings
input_manager:set_bindings(custom_bindings)
```

### Custom Handlers

```lua
-- Create custom handler
local MyHandler = setmetatable({}, { __index = InputHandler })
MyHandler.__index = MyHandler

function MyHandler:new(game_state)
  local self = setmetatable(InputHandler:new(game_state), self)
  return self
end

function MyHandler:handle_mouse_pressed(x, y, button)
  -- Custom handling logic
  return handled -- true if handled, false otherwise
end

-- Register with input manager
input_manager:register_handler("my_handler", MyHandler:new(game_state))
```

## Events

The input system provides the following event callbacks that can be implemented by handlers:

- `handle_key_pressed(key, scancode, isrepeat)`
- `handle_key_released(key, scancode)`
- `handle_mouse_pressed(x, y, button)`
- `handle_mouse_released(x, y, button)`
- `handle_mouse_moved(x, y, dx, dy)`
- `handle_wheel_moved(x, y)`
- `update(dt)`

## Priority

Input handlers are processed in the following order:

1. UI handlers (highest priority)
2. State-specific handlers
3. Grid/inventory handlers
4. Default handlers 