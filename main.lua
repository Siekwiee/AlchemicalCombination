--This is ALchemical Combinations a game made with löve2d in lua

local love = require("love")

-- Load modules
local Debug = require("src.core.debug")
local DebugConsole = require("src.user_interface.components.DebugConsole")
local UserInput = require("src.user_input.UserInput")

-- Global references
local debug_console = nil
local user_input = nil

function love.load()
  -- Initialize debug system
  DebugConsole.init(Debug)
  user_input = UserInput.init(DebugConsole)
  
  -- Log game startup
  Debug.info("Game started - ALchemical Combinations")
  Debug.debug("Screen resolution: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
  Debug.debug("LÖVE version: " .. love.getVersion())
  
  -- Example logs for testing
  Debug.info("Debug system initialized")
  Debug.warning("This is a warning test message")
  Debug.error("This is an error test message")
  Debug.debug("Press F3 to toggle debug console")
end

function love.update(dt)
  -- Update systems
  DebugConsole.update(dt)
  
  -- Debug performance info
  if love.timer.getFPS() < 30 then
    Debug.warning("Low FPS: " .. love.timer.getFPS())
  end
end

function love.draw()
  -- Draw game elements here
  
  -- Draw debug console (should be last to overlay everything)
  DebugConsole.draw()
end

-- Input handling
function love.keypressed(key, scancode, isrepeat)
  user_input.key_pressed(key)
  
  -- Debug shortcuts
  if key == "escape" then
    Debug.info("Game exiting...")
    love.event.quit()
  end
end

-- Error handling
function love.errorhandler(msg)
  Debug.error("FATAL ERROR: " .. tostring(msg))
  
  -- Let default error handler run after logging
  return false
end

