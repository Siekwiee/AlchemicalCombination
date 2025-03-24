local love = require("love")
local UI = require("src.user_interface.init")
local Config = require("src.gamestate.config")

local SettingsMenu = {
    keybinds = {
        {key = "Up/Down Arrows", description = "Navigate menu options"},
        {key = "Enter/Space", description = "Select menu option"},
        {key = "Escape", description = "Return to previous screen"},
        {key = "Up/Down", description = "Navigate menu items"}, 
    },
    selectedOption = 0,
    backButton = nil,
    controlsToggle = nil
}

function SettingsMenu:new(o)
    o = o or {
        selectedOption = 0,
        backButton = nil,
        controlsToggle = nil,
        -- Deep copy the keybinds table to the new instance
        keybinds = {}
    }
    
    -- Copy keybinds data
    for i, keybind in ipairs(self.keybinds) do
        o.keybinds[i] = {
            key = keybind.key,
            description = keybind.description
        }
    end
    
    -- Explicitly copy all methods
    o.init = self.init
    o.update = self.update
    o.draw = self.draw
    o.handleKeyPress = self.handleKeyPress
    o.handleMousePress = self.handleMousePress
    o.handleMouseRelease = self.handleMouseRelease
    
    return o
end

function SettingsMenu:init()
    -- Initialize UI
    UI:init()
    
    -- Create back button
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    self.backButton = UI.Button:new({
        text = "Back to Main Menu",
        action = "back_to_menu",
        width = 200,
        height = 50,
        x = (windowWidth - 200) / 2,
        y = windowHeight - 100
    })
    
    -- Create drag controls toggle checkbox
    self.controlsToggle = UI.Checkbox:new({
        text = "Classic Drag Controls",
        width = 300,
        height = 40,
        x = (windowWidth - 300) / 2,
        y = windowHeight - 200,
        isChecked = Config:get("classicDragControls")
    })
end

function SettingsMenu:update(dt)
    -- Update back button position on window resize
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    self.backButton.x = (windowWidth - self.backButton.width) / 2
    self.backButton.y = windowHeight - 100
    
    -- Update toggle checkbox position
    if self.controlsToggle then
        self.controlsToggle.x = (windowWidth - self.controlsToggle.width) / 2
        self.controlsToggle.y = windowHeight - 200
    end
end

function SettingsMenu:draw()
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()
    
    -- Draw title
    love.graphics.setFont(UI.fonts.large)
    local title = "Settings"
    local titleX, titleY = UI:centerText(title, 50, UI.fonts.large)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(title, titleX, titleY)
    
    -- Draw keybinds section title
    love.graphics.setFont(UI.fonts.normal)
    local keybindsTitle = "Keybinds"
    local keybindsTitleX, keybindsTitleY = UI:centerText(keybindsTitle, 100, UI.fonts.normal)
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print(keybindsTitle, keybindsTitleX, keybindsTitleY)
    
    -- Draw keybinds table
    love.graphics.setFont(UI.fonts.normal)
    local startY = 140
    local padding = 20
    local columnPadding = 50
    
    -- Draw header
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print("KEY", windowWidth/2 - 150, startY)
    love.graphics.print("DESCRIPTION", windowWidth/2, startY)
    
    -- Draw divider
    love.graphics.setColor(0.5, 0.5, 0.8)
    love.graphics.line(
        windowWidth/4, startY + padding*1.5,
        windowWidth*3/4, startY + padding*1.5
    )
    
    -- Safety check for keybinds
    if not self.keybinds then
        self.keybinds = SettingsMenu.keybinds
        print("Warning: SettingsMenu had nil keybinds, restored from defaults")
    end
    
    -- Draw keybind rows
    love.graphics.setColor(1, 1, 1)
    for i, bind in ipairs(self.keybinds) do
        local rowY = startY + padding*2 + (i-1) * padding*1.5
        love.graphics.print(bind.key, windowWidth/2 - 150, rowY)
        love.graphics.print(bind.description, windowWidth/2, rowY)
    end
    
    -- Draw controls section title
    local controlsTitle = "Controls"
    local controlsTitleX, controlsTitleY = UI:centerText(controlsTitle, windowHeight - 260, UI.fonts.normal)
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.print(controlsTitle, controlsTitleX, controlsTitleY)
    
    -- Draw horizontal divider
    love.graphics.setColor(0.5, 0.5, 0.8)
    love.graphics.line(
        windowWidth/4, windowHeight - 240,
        windowWidth*3/4, windowHeight - 240
    )
    
    -- Draw description
    love.graphics.setColor(0.9, 0.9, 0.9)
    local description = "Enable classic mode to use left-click for drag and right-click for opening panels"
    local descX, descY = UI:centerText(description, windowHeight - 230, UI.fonts.small)
    love.graphics.setFont(UI.fonts.small)
    love.graphics.print(description, descX, descY)
    
    -- Draw controls toggle
    love.graphics.setFont(UI.fonts.normal)
    if self.controlsToggle then
        self.controlsToggle:draw(self.selectedOption == 2)
    end
    
    -- Draw back button
    self.backButton:draw(self.selectedOption == 1)
end

function SettingsMenu:handleKeyPress(key)
    if key == "escape" or key == "return" or key == "space" then
        return "back_to_menu"
    elseif key == "up" or key == "down" then
        -- Toggle between back button and controls toggle
        if self.selectedOption == 0 or self.selectedOption == 1 then
            self.selectedOption = 2
        else
            self.selectedOption = 1
        end
    end
    return nil
end

function SettingsMenu:handleMousePress(x, y, button)
    -- Only handle left mouse button
    if button ~= 1 then return nil end
    
    -- Check if back button was clicked
    if x >= self.backButton.x and x < self.backButton.x + self.backButton.width and
       y >= self.backButton.y and y < self.backButton.y + self.backButton.height then
        self.selectedOption = 1
        return nil
    end
    
    -- Check if controls toggle was clicked
    if self.controlsToggle and self.controlsToggle:isPointInside(x, y) then
        self.selectedOption = 2
        return nil
    end
    
    return nil
end

function SettingsMenu:handleMouseRelease(x, y, button)
    -- Only handle left mouse button
    if button ~= 1 then return nil end
    
    -- Check if back button was released
    if x >= self.backButton.x and x < self.backButton.x + self.backButton.width and
       y >= self.backButton.y and y < self.backButton.y + self.backButton.height and
       self.selectedOption == 1 then
        return "back_to_menu"
    end
    
    -- Check if controls toggle was released
    if self.controlsToggle and self.controlsToggle:isPointInside(x, y) and self.selectedOption == 2 then
        -- Toggle the setting
        self.controlsToggle:toggle()
        Config:set("classicDragControls", self.controlsToggle.isChecked)
        return nil
    end
    
    return nil
end

return SettingsMenu 