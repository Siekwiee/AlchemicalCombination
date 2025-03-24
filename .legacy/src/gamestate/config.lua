local love = require("love")
local json = require("src.data.json")

-- Game configuration module for user settings
local Config = {
    -- Default settings
    settings = {
        classicDragControls = false, -- When true, tabs open with right-click and drag with left-click
        debugEnabled = true,         -- When true, debug mode is enabled by default
        debugLogLevel = "debug"      -- Default debug log level
    }
}

-- Local path for saving/loading
local configPath = "config.json"

-- Load settings from file
function Config:load()
    if love.filesystem.getInfo(configPath) then
        local contents = love.filesystem.read(configPath)
        if contents then
            local success, data = pcall(function() return json.decode(contents) end)
            if success and data and type(data) == "table" then
                -- Update settings with saved values
                for key, value in pairs(data) do
                    self.settings[key] = value
                end
                print("Settings loaded from " .. configPath)
                return true
            else
                print("Error parsing config: " .. (data or "unknown error"))
            end
        end
    end
    print("No saved settings found, using defaults")
    return false
end

-- Save settings to file
function Config:save()
    local jsonData = json.encode(self.settings)
    local success, message = love.filesystem.write(configPath, jsonData)
    if success then
        print("Settings saved to " .. configPath)
        return true
    else
        print("Failed to save settings: " .. (message or "unknown error"))
        return false
    end
end

-- Get a setting value
function Config:get(key)
    return self.settings[key]
end

-- Set a setting value and save
function Config:set(key, value)
    self.settings[key] = value
    self:save()
end

-- Toggle a boolean setting and save
function Config:toggle(key)
    if type(self.settings[key]) == "boolean" then
        self.settings[key] = not self.settings[key]
        self:save()
        return self.settings[key]
    end
    return nil
end

-- Initialize configuration (call on startup)
function Config:init()
    -- Try to load existing configuration
    self:load()
    -- Save to ensure config file exists
    self:save()
end

return Config 