function love.conf(t)
    -- Identity
    t.identity = "unnamed_idlegame01"            -- Save directory name
    t.version = "11.4"                           -- LÖVE version

    -- Window configuration
    t.window.title = "Alchemy Factory"         -- Window title
    t.window.width = 1920                        -- Window width (changed from 800)
    t.window.height = 1080                       -- Window height (changed from 600)
    t.window.resizable = true                    -- Make window resizable
    t.window.vsync = true                        -- Enable vertical sync for smooth rendering
    t.window.minwidth = 800                      -- Minimum window width
    t.window.minheight = 600                     -- Minimum window height
    
    -- Modules configuration
    t.modules.audio = true                       -- Enable the audio module
    t.modules.data = true                        -- Enable the data module
    t.modules.event = true                       -- Enable the event module
    t.modules.graphics = true                    -- Enable the graphics module
    t.modules.keyboard = true                    -- Enable the keyboard module
    t.modules.math = true                        -- Enable the math module
    t.modules.mouse = true                       -- Enable the mouse module
    t.modules.sound = true                       -- Enable the sound module
    t.modules.system = true                      -- Enable the system module
    t.modules.timer = true                       -- Enable the timer module
    t.modules.window = true                      -- Enable the window module
end
