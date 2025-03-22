local love = require("love")
local UI = require("src.ui")

local MainMenu = {
    buttons = {},
    selectedButton = 1,
    buttonPadding = 10
}

-- Constructor method with improved inheritance
function MainMenu:new(o)
    o = o or {
        buttons = {},
        selectedButton = 1,
        buttonPadding = self.buttonPadding
    }
    
    -- Explicitly copy all methods to ensure proper inheritance
    o.init = self.init
    o.update = self.update
    o.draw = self.draw
    o.handleKeyPress = self.handleKeyPress
    
    return o
end

function MainMenu:init()
    -- Initialize UI
    UI:init()
    
    -- Clear buttons array in case of reinitialization
    self.buttons = {}
    
    -- Create buttons
    local buttonConfigs = {
        {text = "Start Game", action = "start_game"},
        {text = "Options", action = "options"},
        {text = "Exit", action = "exit"}
    }
    
    -- Calculate positions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    local buttonHeight = 50
    local totalHeight = #buttonConfigs * (buttonHeight + self.buttonPadding)
    local startY = (windowHeight - totalHeight) / 2
    
    -- Create button instances
    for i, config in ipairs(buttonConfigs) do
        local button = UI.Button:new({
            text = config.text,
            action = config.action,
            height = buttonHeight,
            y = startY + (i-1) * (buttonHeight + self.buttonPadding)
        })
        -- Center the button horizontally
        button.x = (windowWidth - button.width) / 2
        table.insert(self.buttons, button)
    end
end

function MainMenu:update(dt)
    -- Update button positions on window resize
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Safety check
    if #self.buttons == 0 then
        return
    end
    
    local totalHeight = #self.buttons * (self.buttons[1].height + self.buttonPadding)
    local startY = (windowHeight - totalHeight) / 2
    
    for i, button in ipairs(self.buttons) do
        button.x = (windowWidth - button.width) / 2
        button.y = startY + (i-1) * (button.height + self.buttonPadding)
    end
end

function MainMenu:draw()
    -- Safety check
    if #self.buttons == 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Menu not initialized properly", 10, 10)
        return
    end
    
    -- Set the font
    love.graphics.setFont(UI.fonts.large)
    
    -- Draw title
    local title = "Unnamed Idle Game"
    local titleX, titleY = UI:centerText(title, self.buttons[1].y - 100, UI.fonts.large)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(title, titleX, titleY)
    
    -- Draw buttons
    for i, button in ipairs(self.buttons) do
        button:draw(i == self.selectedButton)
    end
end

function MainMenu:handleKeyPress(key)
    if key == "up" then
        self.selectedButton = self.selectedButton - 1
        if self.selectedButton < 1 then
            self.selectedButton = #self.buttons
        end
    elseif key == "down" then
        self.selectedButton = self.selectedButton + 1
        if self.selectedButton > #self.buttons then
            self.selectedButton = 1
        end
    elseif key == "return" or key == "space" then
        return self.buttons[self.selectedButton].action
    end
    return nil
end

return MainMenu