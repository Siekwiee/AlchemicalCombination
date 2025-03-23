local love = require("love")
local GameState = require("src.gamestate.init")

-- Global variables
local gameState
local debugMessages = {}
local MAX_DEBUG_MESSAGES = 10

-- Initialize game
function love.load()
    -- Set default filter for crisp pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Initialize the game state
    gameState = GameState:new()
end

-- Update game state
function love.update(dt)
    -- Update game state
    if gameState.update then
        gameState:update(dt)
    end
end

-- Draw game
function love.draw()
    -- Clear the screen
    love.graphics.clear(0.1, 0.1, 0.1)
    
    -- Draw game state
    if gameState.draw then
        gameState:draw()
    end
    
    -- Draw FPS counter in top left
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
    
    -- Draw debug messages
    drawDebug()
end

-- Handle key events
function love.keypressed(key, scancode, isrepeat)
    -- Pass keyboard events to the game state
    if gameState.keypressed then
        gameState:keypressed(key, scancode, isrepeat)
    end
end

-- Handle mouse clicks
function love.mousepressed(x, y, button)
    -- Pass mouse events to the game state
    if gameState.mousepressed then
        gameState:mousepressed(x, y, button)
    end
end

-- Handle mouse releases
function love.mousereleased(x, y, button)
    -- Pass mouse events to the game state
    if gameState.mousereleased then
        gameState:mousereleased(x, y, button)
    end
end

-- Handle window resize
function love.resize(w, h)
    -- Menu will automatically adjust to new window size
end

-- Clean up resources
function love.quit()
    return false
end

-- Replace print with a custom function
local originalPrint = print
function print(...)
    -- Call the original print function
    originalPrint(...)
    
    -- Format the message
    local message = ""
    local args = {...}
    for i, v in ipairs(args) do
        message = message .. tostring(v) .. " "
    end
    
    -- Add to debug messages
    table.insert(debugMessages, 1, message)
    
    -- Trim old messages
    while #debugMessages > MAX_DEBUG_MESSAGES do
        table.remove(debugMessages)
    end
end

-- Then draw the debug messages in your draw function
function drawDebug()
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setNewFont(12)
    
    for i, message in ipairs(debugMessages) do
        love.graphics.print(message, 10, love.graphics.getHeight() - 20*i)
    end
end
