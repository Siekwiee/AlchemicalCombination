--This is the love conf.lua file for the game
local love = require("love")

function love.conf(t)
    t.title = "ALchemical Combinations"
    t.version = "11.5"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = false
end