local love = require("love")
local GameState = require("src.gamestate")

-- Initialize game
function love.load()
    -- Set default filter for crisp pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Initialize game state
    GameState:init()
end

-- Update game state
function love.update(dt)
    GameState:update(dt)
end

-- Draw game
function love.draw()
    -- Clear the screen
    love.graphics.clear(0.1, 0.1, 0.1)
    
    -- Draw current game state
    GameState:draw()
    
    -- Draw FPS counter in debug mode
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, love.graphics.getHeight() - 30)
end

-- Handle key events
function love.keypressed(key)
    GameState:handleKeyPress(key)
end

-- Handle window resize
function love.resize(w, h)
    -- Menu will automatically adjust to new window size
end

-- Clean up resources
function love.quit()
    return false
end
