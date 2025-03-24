---@class Debug
---@field enabled boolean Whether debug mode is enabled
---@field logLevel string Current log level ("debug", "info", "warn", "error")
---@field logs table[] Array of log entries
---@field maxLogs number Maximum number of logs to keep
---@field initialized boolean Whether the debug system has been initialized
---@field logToFile boolean Whether logs should be written to a file
---@field logFilePath string Path to the log file
local Debug = {
    -- Debug settings
    enabled = false,
    logLevel = "info",  -- "debug", "info", "warn", "error"
    
    -- Log history
    logs = {},
    maxLogs = 100,
    
    -- File logging
    logToFile = true,
    logFilePath = "debug_log.txt",
    
    -- State tracking
    initialized = false
}

---@type table<string, number>
-- Log levels
local LOG_LEVELS = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4
}

-- Get numerical value for log level
---@param level string The log level name
---@return number The numeric value of the log level
local function getLevelValue(level)
    return LOG_LEVELS[level] or 1
end

-- Initialize debug system
---@param options? table Optional configuration options
---@return Debug The initialized debug object
function Debug:init(options)
    -- Apply options if provided
    if options then
        if type(options.enabled) == "boolean" then
            self.enabled = options.enabled
        end
        
        if options.logLevel and LOG_LEVELS[options.logLevel] then
            self.logLevel = options.logLevel
        end
        
        if type(options.maxLogs) == "number" then
            self.maxLogs = math.max(10, math.floor(options.maxLogs))
        end
        
        if type(options.logToFile) == "boolean" then
            self.logToFile = options.logToFile
        end
        
        if type(options.logFilePath) == "string" then
            self.logFilePath = options.logFilePath
        end
    else
        -- Default configuration
        self.enabled = true
    end
    
    -- Clear logs
    self.logs = {}
    
    -- Initialize log file if enabled
    if self.logToFile then
        local success, message = self:initLogFile()
        if not success then
            print("Warning: Failed to initialize log file: " .. (message or "Unknown error"))
            self.logToFile = false
        end
    end
    
    -- Mark as initialized
    self.initialized = true
    
    -- Log initialization
    if self.enabled then
        self:info("Debug", "Debug system initialized", {
            level = self.logLevel,
            maxLogs = self.maxLogs,
            logToFile = self.logToFile,
            logFilePath = self.logFilePath
        })
    end
    
    return self
end

-- Initialize log file
---@return boolean success, string|nil errorMessage
function Debug:initLogFile()
    if not self.logToFile then return true end
    
    local success, message
    
    -- Create log file with header
    local file, errorMsg = io.open(self.logFilePath, "w")
    if not file then
        return false, "Could not open log file: " .. (errorMsg or "Unknown error")
    end
    
    -- Write header
    file:write("=== DEBUG LOG STARTED AT " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n\n")
    file:close()
    
    return true
end

-- Serialize data for logging
---@param data any The data to serialize
---@return string The serialized data
function Debug:serializeData(data)
    if data == nil then
        return "nil"
    elseif type(data) == "string" or type(data) == "number" or type(data) == "boolean" then
        return self:valueToString(data)
    else
        return self:valueToString(data)
    end
end

-- Safely convert any value to string representation
---@param value any The value to convert to string
---@param depth number Current recursion depth
---@param maxDepth number Maximum recursion depth
---@return string The string representation
function Debug:valueToString(value, depth, maxDepth)
    depth = depth or 0
    maxDepth = maxDepth or 2
    
    if value == nil then
        return "nil"
    elseif type(value) == "string" then
        return '"' .. value .. '"'
    elseif type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    elseif type(value) == "table" then
        if depth >= maxDepth then
            return "{...}"
        end
        
        local result = "{"
        local first = true
        for k, v in pairs(value) do
            if not first then result = result .. ", " end
            result = result .. tostring(k) .. "=" .. self:valueToString(v, depth + 1, maxDepth)
            first = false
            
            -- Limit very large tables
            if #result > 250 then
                result = result .. ", ..."
                break
            end
        end
        return result .. "}"
    elseif type(value) == "function" then
        return "function()"
    elseif type(value) == "userdata" then
        return "userdata"
    elseif type(value) == "thread" then
        return "thread"
    else
        return tostring(value)
    end
end

-- Write log to file
---@param entry table The log entry to write
---@return boolean success Whether the log was written
function Debug:writeLogToFile(entry)
    if not self.logToFile or not entry then return false end
    
    -- Open file in append mode
    local file, errorMsg = io.open(self.logFilePath, "a")
    if not file then
        print("Warning: Could not open log file: " .. (errorMsg or "Unknown error"))
        return false
    end
    
    -- Format timestamp
    local timestamp = os.date("%H:%M:%S", entry.timestamp)
    
    -- Format log message with timestamp, level, module
    local logLine = string.format("[%s][%s][%s] %s", 
                   timestamp, entry.level:upper(), entry.module, entry.message)
    
    -- Add data if present
    if entry.data ~= nil then
        logLine = logLine .. " " .. self:serializeData(entry.data)
    end
    
    -- Write and close
    file:write(logLine .. "\n")
    file:close()
    
    return true
end

-- Add a log entry
---@param level string Log level ("debug", "info", "warn", "error")
---@param module string Module name that created the log
---@param message string Log message
---@param data any Additional data to log (optional)
---@return table|nil The created log entry or nil if not logged
function Debug:log(level, module, message, data)
    -- Check if debug system is initialized
    if not self.initialized then
        print("WARNING: Debug system used before initialization")
        return nil
    end
    
    -- Validate parameters
    if not level or type(level) ~= "string" or not LOG_LEVELS[level] then
        level = "info"
    end
    
    -- Default level is info
    local logLevel = level
    local moduleName = module or "unknown"
    local logMessage = message or ""
    
    -- Only log if debug is enabled and log level is high enough
    if not self.enabled or getLevelValue(logLevel) < getLevelValue(self.logLevel) then
        return nil
    end
    
    -- Create log entry
    ---@type table
    local entry = {
        timestamp = os.time(),
        level = logLevel,
        module = moduleName,
        message = logMessage,
        data = data
    }
    
    -- Print to console immediately
    local formattedMessage = string.format("[%s][%s] %s", logLevel:upper(), moduleName, logMessage)
    if data ~= nil then
        formattedMessage = formattedMessage .. " " .. self:serializeData(data)
    end
    print(formattedMessage)
    
    -- Write to log file if enabled
    if self.logToFile then
        self:writeLogToFile(entry)
    end
    
    -- Add to logs
    table.insert(self.logs, 1, entry)
    
    -- Trim logs if needed
    if #self.logs > self.maxLogs then
        table.remove(self.logs)
    end
    
    return entry
end

-- Debug level logging
---@param module string Module name
---@param message string Log message
---@param data any Additional data (optional)
---@return table|nil The created log entry or nil if not logged
function Debug:debug(module, message, data)
    return self:log("debug", module, message, data)
end

-- Info level logging
---@param module string Module name
---@param message string Log message
---@param data any Additional data (optional)
---@return table|nil The created log entry or nil if not logged
function Debug:info(module, message, data)
    return self:log("info", module, message, data)
end

-- Warning level logging
---@param module string Module name
---@param message string Log message
---@param data any Additional data (optional)
---@return table|nil The created log entry or nil if not logged
function Debug:warn(module, message, data)
    return self:log("warn", module, message, data)
end

-- Error level logging
---@param module string Module name
---@param message string Log message
---@param data any Additional data (optional)
---@return table|nil The created log entry or nil if not logged
function Debug:error(module, message, data)
    return self:log("error", module, message, data)
end

-- Set log level
---@param level string The log level to set
---@return boolean Whether the level was valid and set successfully
function Debug:setLogLevel(level)
    if LOG_LEVELS[level] then
        self.logLevel = level
        return true
    end
    return false
end

-- Enable/disable debug
---@param enabled boolean Whether debug should be enabled
function Debug:setEnabled(enabled)
    self.enabled = enabled and true or false
end

-- Get all logs
---@return table[] Array of log entries
function Debug:getLogs()
    return self.logs
end

-- Clear logs
function Debug:clearLogs()
    self.logs = {}
end

-- Draw debug information on screen
function Debug:draw()
    if not self.enabled then
        return
    end
    
    -- Save current graphics state
    love.graphics.push()
    
    -- Draw debug status with background for better visibility
    local screenWidth, screenHeight = love.graphics.getDimensions()
    
    -- Draw header background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 400, 30)
    
    -- Draw header text
    love.graphics.setColor(1, 1, 0, 1) -- Bright yellow for header
    love.graphics.print("DEBUG MODE ENABLED | F12: Toggle | F11: Cycle log level | Current: " .. 
                        string.upper(self.logLevel), 10, 10)
    
    -- Draw logs with background panel
    local panelHeight = math.min(350, 50 + #self.logs * 40) -- Adjust panel height based on log count
    local panelWidth = screenWidth * 0.9
    local panelX = screenWidth * 0.05
    local panelY = screenHeight - panelHeight - 10
    
    -- Draw log panel background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight)
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight)
    
    -- Title for log panel with log count
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(string.format("LOG HISTORY (%d entries, showing most recent at top)", 
                                     #self.logs), panelX + 10, panelY + 5)
    
    -- Draw line under title
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.line(panelX + 10, panelY + 25, panelX + panelWidth - 10, panelY + 25)
    
    -- Show logs (up to 8 most recent entries with data)
    local logY = panelY + 30
    local logCount = math.min(8, #self.logs)
    
    if logCount == 0 then
        -- Show message when no logs are available
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.print("No log entries available yet. Perform actions to generate logs.", 
                           panelX + 15, logY + 20)
    end
    
    for i = 1, logCount do
        local log = self.logs[i]
        if log and log.level and log.module and log.message then
            -- Color based on log level
            if log.level == "debug" then
                love.graphics.setColor(0.6, 0.6, 1, 1)     -- Blue for debug
            elseif log.level == "info" then
                love.graphics.setColor(0.6, 1, 0.6, 1)     -- Green for info
            elseif log.level == "warn" then
                love.graphics.setColor(1, 1, 0.6, 1)       -- Yellow for warnings
            elseif log.level == "error" then
                love.graphics.setColor(1, 0.6, 0.6, 1)     -- Red for errors
            else
                love.graphics.setColor(1, 1, 1, 1)         -- White for unknown
            end
            
            -- Format log header with timestamp
            local timestamp = os.date("%H:%M:%S", log.timestamp)
            local logHeader = string.format("[%s][%s][%s] %s", 
                             timestamp, log.level:upper(), log.module, log.message)
            love.graphics.print(logHeader, panelX + 15, logY)
            
            -- Handle data display
            if log.data ~= nil then
                -- Format data with proper indentation
                local dataStr = self:serializeData(log.data)
                love.graphics.setColor(0.9, 0.9, 0.9, 0.9) -- Slightly dimmer for data
                love.graphics.print("  → " .. dataStr, panelX + 25, logY + 20)
            end
            
            -- Move down for next log entry
            logY = logY + (log.data ~= nil and 40 or 25)
            
            -- Draw separator line
            love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            love.graphics.line(panelX + 15, logY - 5, panelX + panelWidth - 15, logY - 5)
        end
    end
    
    -- Draw "how to close" message at bottom
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.print("Press F12 to hide debug overlay", 
                        panelX + panelWidth - 200, panelY + panelHeight - 20)
    
    -- Restore graphics state
    love.graphics.pop()
end

return Debug 