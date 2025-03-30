-- Import dependencies
local love = require("love")
local Logger = require("src.core.debug.logger")
local Display = require("src.core.debug.display")

-- Debug module
local Debug = {}

-- Constants
local LOG_LEVELS = {
  INFO = 1,
  WARNING = 2,
  ERROR = 3,
  DEBUG = 4
}

-- Track last messages to prevent repeated identical log spam
local last_message = {
  text = "",
  level = "",
  count = 0,
  timestamp = 0
}

-- Debug state (forwarded from Display module)
Debug.is_enabled = Display.is_enabled
Debug.messages = Display.messages
Debug.max_messages = Display.max_messages

---@class Debug
---@field log table<string, string>
---@field is_enabled boolean
---@field log_level number
---@field flag_file_logging boolean
---@field filtered_messages table<string, boolean>
---@field log_directory string
---@field warning fun(self: Debug, message: string)
---@field info fun(self: Debug, message: string)
---@field error fun(self: Debug, message: string)
---@field debug fun(self: Debug, message: string)
---@field get_logs fun(self: Debug)
---@field save_logs fun(self: Debug, path: string)
---@field clear fun(self: Debug)
---@return Debug
function Debug:new()
    local o = {
        log = {},
        is_enabled = true,
        log_level = LOG_LEVELS.DEBUG,
        flag_file_logging = true,
        log_directory = nil,
        filtered_messages = {}, -- Messages to filter out
        max_logs = 1000, -- Maximum log entries to keep
        duplicate_log_throttle = 1.0 -- Time in seconds before showing repeated logs
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Initialize the log directory
function Debug:init_log_directory()
    if not self.log_directory then
        self.log_directory = Logger.get_default_log_dir()
        return Logger.ensure_directory_exists(self.log_directory)
    end
    return true
end

-- Add a log entry to the log history with duplicate prevention
function Debug:add_log(level_name, message)
  -- Ensure filtered_messages is initialized
  if self.filtered_messages == nil then
    self.filtered_messages = {}
  end

  -- Check if this message is filtered
  if self.filtered_messages[message] then
    return
  end
  
  -- Check for duplicate log spam
  local current_time = os.time()
  if message == last_message.text and level_name == last_message.level then
    last_message.count = last_message.count + 1
    
    -- Only log duplicates periodically, to reduce spam
    local throttle_time = self.duplicate_log_throttle or 1.0
    if current_time - last_message.timestamp < throttle_time then
      return -- Skip logging this duplicate for now
    end
    
    -- Update the message to show the count
    if last_message.count > 1 then
      message = message .. " (repeated " .. last_message.count .. " times)"
    end
  else
    -- New message, reset counter
    last_message.text = message
    last_message.level = level_name
    last_message.count = 1
  end
  
  -- Update timestamp
  last_message.timestamp = current_time
  
  -- Format message with timestamp
  local formatted_message = Logger.format_with_timestamp(level_name, message)
  
  -- Initialize log array if not already done
  if not self.log then
    self.log = {}
  end
  
  -- Add to in-memory log array
  table.insert(self.log, formatted_message)
  
  -- Trim logs if we have too many
  if #self.log > (self.max_logs or 1000) then
    table.remove(self.log, 1)
  end
  
  -- Add to on-screen display
  Display.add_message(message, level_name)
  
  -- Write to file if enabled
  if self.flag_file_logging then
    self:init_log_directory()
    local success, err = Logger.write_to_file(self.log_directory, formatted_message)
    if not success then
      print("Warning: Failed to write to log file: " .. tostring(err))
      self.flag_file_logging = false
    end
  end
  
  -- Direct console output for debug level
  if level_name == "DEBUG" then
    print("[DEBUG] " .. message)
  end
end

-- Add a warning message to the log
function Debug:warning(message)
  self:add_log("WARNING", message)
end

-- Add an info message to the log
function Debug:info(message)
  self:add_log("INFO", message)
end

-- Add an error message to the log
function Debug:error(message)
  self:add_log("ERROR", message)
end

-- Add a debug message to the log
function Debug:debug(debugger, message)
  -- Allow usage like: Debug.debug(Debug, "message") for global instance
  -- or self:debug("message") for instance method
  if type(debugger) == "table" and type(message) == "nil" then
    -- Called as instance method, only one argument
    message = debugger
    self:add_log("DEBUG", message)
  elseif type(debugger) == "table" and type(message) == "string" then
    -- Called as static method with Debug as first parameter
    debugger:add_log("DEBUG", message)
  else
    -- Fallback
    self:add_log("DEBUG", tostring(debugger) .. " " .. tostring(message))
  end
end

-- Get all logs
function Debug:get_logs()
  return self.log
end

-- Save logs to a file
function Debug:save_logs(path)
  if not path then
    -- Use default path
    if not self.log_directory then
      self:init_log_directory()
    end
    path = self.log_directory .. "/debug_export_" .. os.date("%Y%m%d_%H%M%S") .. ".log"
  end
  
  local success, err = Logger.save_logs(self.log, path)
  if not success then
    self:error("Failed to save logs: " .. tostring(err))
    return false
  end
  
  self:info("Logs saved to: " .. path)
  return true
end

-- Clear all logs
function Debug:clear()
  if self and self.log then
    self.log = {}
  end
  Display.clear()
  return true
end

-- Static version of clear for global usage
function Debug.clear_logs()
  Display.clear()
  return true
end

-- Toggle debug visibility
function Debug:toggle()
  self.is_enabled = Display.toggle()
  print("Debug mode " .. (self.is_enabled and "enabled" or "disabled"))
  return self.is_enabled
end

-- Draw debug information
function Debug:draw()
  Display.draw()
end

-- Create global instance for direct access
local function initialize_global_instance()
  if not _G.DEBUG then
    _G.DEBUG = Debug:new()
    _G.DEBUG:init_log_directory()
  end
  return _G.DEBUG
end

-- Initialize and return the global instance
local global_instance = initialize_global_instance()
setmetatable(Debug, {__index = global_instance})

return Debug 