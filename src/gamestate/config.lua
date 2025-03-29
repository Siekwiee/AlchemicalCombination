local Config = {}
Config.__index = Config

-- Default configuration values
local default_config = {
    classicDragControls = false,  -- false = left click drag, true = right click drag
    debugEnabled = false,
    debugLogLevel = "info",
    soundEnabled = true,
    musicEnabled = true,
    volume = 1.0,
}

-- Current configuration values
local config = {}

-- Initialize configuration with default values
function Config:init()
    -- Copy default values
    for key, value in pairs(default_config) do
        config[key] = value
    end
    
    -- Try to load saved configuration
    self:load()
end

-- Get a configuration value
---@param key string The configuration key to get
---@return any The configuration value, or nil if not found
function Config:get(key)
    return config[key]
end

-- Set a configuration value
---@param key string The configuration key to set
---@param value any The value to set
function Config:set(key, value)
    config[key] = value
    -- Could add validation here
    
    -- Save configuration after changes
    self:save()
end

-- Reset configuration to defaults
function Config:reset()
    config = {}
    for key, value in pairs(default_config) do
        config[key] = value
    end
    self:save()
end

-- Load configuration from file
function Config:load()
    local success, data = pcall(function()
        return love.filesystem.read("config.txt")
    end)
    
    if success and data then
        local success, loaded = pcall(function()
            return love.data.decode("string", "base64", data)
        end)
        
        if success and loaded then
            local success, decoded = pcall(function()
                return love.data.unpack("table", loaded)
            end)
            
            if success and decoded then
                -- Merge loaded config with defaults
                for key, value in pairs(decoded) do
                    config[key] = value
                end
            end
        end
    end
end

-- Save configuration to file
function Config:save()
    local success, data = pcall(function()
        return love.data.pack("string", "table", config)
    end)
    
    if success and data then
        local encoded = love.data.encode("string", "base64", data)
        love.filesystem.write("config.txt", encoded)
    end
end

-- Initialize with defaults
Config:init()

return Config 