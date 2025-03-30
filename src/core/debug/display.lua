local love = require("love")

local Display = {}

-- Default display settings
Display.is_enabled = true
Display.messages = {}
Display.max_messages = 20
Display.padding = 10
Display.line_height = 20
Display.background_alpha = 0.7
Display.background_color = {0.1, 0.1, 0.1}
Display.text_color = {1, 1, 1}
Display.title_color = {1, 0.8, 0.2}
Display.level_colors = {
    INFO = {0.2, 0.8, 1, 1},
    WARNING = {1, 0.8, 0.2, 1},
    ERROR = {1, 0.2, 0.2, 1},
    DEBUG = {0.8, 0.8, 0.8, 1}
}

-- Add a message to the on-screen display
function Display.add_message(message, level)
    level = level or "DEBUG"
    
    -- Add new message at the end
    table.insert(Display.messages, {
        text = message,
        level = level,
        time = os.time()
    })
    
    -- Remove oldest messages if we have too many
    while #Display.messages > Display.max_messages do
        table.remove(Display.messages, 1)
    end
end

-- Toggle the debug display
function Display.toggle()
    Display.is_enabled = not Display.is_enabled
    return Display.is_enabled
end

-- Clear all messages
function Display.clear()
    Display.messages = {}
end

-- Draw the debug display
function Display.draw()
    if not Display.is_enabled or #Display.messages == 0 then
        return
    end
    
    -- Save current graphics state
    local r, g, b, a = love.graphics.getColor()
    local font = love.graphics.getFont()
    
    -- Draw background
    love.graphics.setColor(
        Display.background_color[1],
        Display.background_color[2],
        Display.background_color[3],
        Display.background_alpha
    )
    
    -- Calculate background dimensions
    local screen_width = love.graphics.getWidth()
    local panel_width = math.min(screen_width - 40, 800)
    local panel_height = (Display.line_height * (#Display.messages + 1)) + (Display.padding * 2)
    local panel_x = 20
    local panel_y = 20
    
    -- Draw panel background
    love.graphics.rectangle("fill", panel_x, panel_y, panel_width, panel_height)
    
    -- Draw header
    love.graphics.setColor(Display.title_color)
    local message_count = #Display.messages
    love.graphics.print("DEBUG OUTPUT (" .. message_count .. " messages)", 
                       panel_x + Display.padding, 
                       panel_y + Display.padding)
    
    -- Draw messages
    for i, msg in ipairs(Display.messages) do
        local y_pos = panel_y + Display.padding + (i * Display.line_height)
        
        -- Set message color based on level
        local color = Display.level_colors[msg.level] or Display.text_color
        love.graphics.setColor(color)
        
        -- Draw the message
        love.graphics.print(msg.text, panel_x + Display.padding, y_pos)
    end
    
    -- Restore graphics state
    love.graphics.setColor(r, g, b, a)
    love.graphics.setFont(font)
end

return Display 