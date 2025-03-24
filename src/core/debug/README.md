# Debug System

A comprehensive debug system for the ALchemical Combinations game.

## Features

- On-screen debug console (toggle with F3)
- File logging to log/debug/ directory
- Multiple log levels (INFO, WARNING, ERROR, DEBUG)
- Customizable appearance

## Usage

### Basic Logging

```lua
-- Import the debug module
local Debug = require("src.core.debug")

-- Log messages with different severity levels
Debug.info("Player entered new level")
Debug.warning("Resource is running low")
Debug.error("Failed to load asset")
Debug.debug("Variables: x=" .. x .. ", y=" .. y)
```

### Console Configuration

```lua
-- Import the debug console
local DebugConsole = require("src.ui.components.DebugConsole")

-- Configure the console appearance
DebugConsole.set_position("bottomleft") -- Options: topleft, topright, bottomleft, bottomright
DebugConsole.set_size(500, 200) -- Width, height
DebugConsole.set_font_size(14)
DebugConsole.set_background_alpha(0.8) -- 0.0 to 1.0
DebugConsole.set_max_visible_lines(20)
```

### Debug Configuration

```lua
-- Configure the debug system
Debug.set_enabled(true) -- Enable/disable all logging
Debug.set_file_logging(true) -- Enable/disable file logging
Debug.set_max_logs(100) -- Maximum logs to keep in memory
```

## Log Levels

1. INFO - General information
2. WARNING - Potential issues that don't break the game
3. ERROR - Serious issues that may affect gameplay
4. DEBUG - Detailed information for development purposes

## Integration Notes

The debug system automatically creates a log directory in the LÖVE save directory.
Logs are organized by date in the format "debug_YYYYMMDD.log".

## Keyboard Shortcuts

- F3: Toggle debug console visibility
- ESC: Quit game (with debug log entry)
