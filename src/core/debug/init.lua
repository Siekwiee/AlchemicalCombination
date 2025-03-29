local love = require("love")

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

-- Global instance for safety
local global_instance = nil

-- Debug state
Debug.is_enabled = true
Debug.messages = {}
Debug.max_messages = 20

---@class Debug
---@field log table<string, string>
---@field is_enabled boolean
---@field log_level number
---@field flag_file_logging boolean
---@field filtered_messages table<string, boolean>
---@field ensure_log_directory_exists fun(path: string)
---@field format_message_with_timestamp fun(level: string, message: string)
---@field write_to_file fun(formatted_message: string)
---@field add_log fun(level_name: string, message: string, level_value: number)
---@field init fun(default_log_level: number, flag_file_logging: boolean)
---@field log_directory string
---@field add_default_log_dir fun()
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

-- Helper function to check if a directory exists and is writable
local function directory_exists_and_writable(path)
    local test_file = path .. "/.test_write"
    local file = io.open(test_file, "w")
    if file then
        file:close()
        os.remove(test_file)
        return true
    end
    return false
end

-- Helper function to create a directory with proper permissions
local function create_directory(path)
    -- Use Unix command with -p to create parent directories and set permissions
    local success = os.execute('mkdir -p "' .. path .. '" && chmod 755 "' .. path .. '"')
    if success then
        -- Verify we can write to it
        return directory_exists_and_writable(path)
    end
    return false
end

-- Ensure log directory exists and is writable
function Debug:ensure_log_directory_exists()
    if not self.log_directory then
        self:add_default_log_dir()
    end
    
    -- Check if directory exists and is writable, create if it doesn't
    if not directory_exists_and_writable(self.log_directory) then
        if not create_directory(self.log_directory) then
            print("Warning: Could not create or write to log directory: " .. self.log_directory)
            self.flag_file_logging = false
            return false
        end
    end
    return true
end

function Debug:add_default_log_dir(path)
    -- Get OS-appropriate save directory
    local default_save_directory
    if not path then
        default_save_directory = os.getenv("HOME") and (os.getenv("HOME") .. "/.local/share") or "."
        default_save_directory = default_save_directory .. "/alchemical_combinations"
    else
        default_save_directory = path
    end
    
    self.log_directory = default_save_directory .. "/log/debug"
    return self:ensure_log_directory_exists()
end

-- Format message with timestamp and level
function Debug:add_timestamp_to_message(level, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local message_with_timestamp = string.format("[%s][%s] %s", timestamp, level, message)
  return message_with_timestamp
end

-- Write log to file with better error handling
function Debug:write_to_file(formatted_message)
    if not self.flag_file_logging then return end
    
    if not self.log_directory or not self:ensure_log_directory_exists() then
        return
    end
    
    local file_path = self.log_directory .. "/debug.log"
    local success, err = pcall(function()
        local file = io.open(file_path, "a")
        if file then
            file:write(formatted_message .. "\n")
            file:close()
        end
    end)
    
    if not success then
        print("Warning: Failed to write to log file: " .. tostring(err))
        self.flag_file_logging = false
    end
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
  
  local formatted_message = self:add_timestamp_to_message(level_name, message)
  
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
  
  -- Write to file if enabled
  if self.flag_file_logging then
    -- Use pcall to prevent errors from file operations from crashing the game
    pcall(function()
      self:write_to_file(formatted_message)
    end)
  end
end

-- Initialize debug system
function Debug:init(flag_file_logging, default_log_level)
    -- Use existing global instance if available
    if global_instance then
        return global_instance
    end
    
    local debug = Debug:new()
    debug.flag_file_logging = flag_file_logging or false
    debug.log_level = LOG_LEVELS[default_log_level or "INFO"] or LOG_LEVELS.INFO
    debug:add_default_log_dir()
    
    -- Make sure filtered_messages is initialized
    if not debug.filtered_messages then
        debug.filtered_messages = {}
    end
    
    -- Add common messages to filter out to reduce spam
    debug:add_filtered_message("handle_mouse_pressed")
    debug:add_filtered_message("handle_mouse_released")
    debug:add_filtered_message("handle_mouse_moved_playing")
    
    -- Save global reference to prevent multiple instances
    global_instance = debug
    
    return debug
end

-- Add a message to filter out (won't be logged)
function Debug:add_filtered_message(message)
  if not self.filtered_messages then
    self.filtered_messages = {}
  end
  self.filtered_messages[message] = true
end

-- Remove a message from the filter list
function Debug:remove_filtered_message(message)
  if not self.filtered_messages then
    self.filtered_messages = {}
    return
  end
  self.filtered_messages[message] = nil
end

---@param message string
function Debug.info(self, message)
  self:add_log("INFO", message)
end

---@param message string
function Debug.warning(self, message)
  self:add_log("WARNING", message)
end

---@param message string
function Debug.error(self, message)
  self:add_log("ERROR", message)
end

---@param message string
function Debug.debug(self, message)
  if not Debug.is_enabled then
    return
  end
  
  -- Print to console first for immediate feedback
  print("[DEBUG] " .. message)
  
  -- Add message to history
  table.insert(Debug.messages, 1, message)
  
  -- Trim message history
  while #Debug.messages > Debug.max_messages do
    table.remove(Debug.messages)
  end
end

---@return table<string, string>
function Debug.get_logs(self)
  return self.log
end

---@param path? string
function Debug.save_logs(self, path)
  if not path then
    local file = io.open(self.log_directory .. "/logs_export.txt", "w")
    if file then
      for _, log_entry in ipairs(self:get_logs()) do
        file:write(log_entry .. "\n")
      end
      file:close()
    end
  else
    self:add_default_log_dir(path)
    local file = io.open(self.log_directory .. "/logs_export.txt", "w")
    if file then
      for _, log_entry in ipairs(self:get_logs()) do
        file:write(log_entry .. "\n")
      end
      file:close()
    end
  end
end

function Debug.clear()
  Debug:ensure_log_directory_exists()
  local file = io.open(Debug.log_directory .. "/debug.log", "w")
  if file then
    file:write("")
    file:close()
  end
  Debug:add_log("INFO", "Cleared logs")
end

function Debug.set_log_level(self, level)
  self.log_level = LOG_LEVELS[level]
end

function Debug.set_file_logging(self, enabled)
  self.flag_file_logging = enabled
end

function Debug.set_max_logs(self, max)
  self.max_logs = max
end

---Logs a value with a description
---@param self any The Debug module
---@param description string Description of the value
---@param value any The value to log
function Debug.debugValue(self, description, value)
  if not Debug.is_enabled then
    return
  end
  
  local valueString = Debug.valueToString(value)
  Debug.debug(self, description .. ": " .. valueString)
end

---Converts a value to a string representation
---@param value any The value to convert
---@return string The string representation
function Debug.valueToString(value)
  local valueType = type(value)
  
  if valueType == "nil" then
    return "nil"
  elseif valueType == "number" or valueType == "string" or valueType == "boolean" then
    return tostring(value)
  elseif valueType == "table" then
    return Debug.tableToString(value)
  elseif valueType == "function" then
    return "function"
  else
    return tostring(value)
  end
end

---Converts a table to a string representation
---@param t table The table to convert
---@param depth number Optional recursion depth
---@return string The string representation
function Debug.tableToString(t, depth)
  depth = depth or 0
  local maxDepth = 2
  
  if depth > maxDepth then
    return "{...}"
  end
  
  local result = "{"
  local first = true
  
  for k, v in pairs(t) do
    if not first then
      result = result .. ", "
    end
    first = false
    
    -- Convert key
    if type(k) == "string" then
      result = result .. k
    else
      result = result .. "[" .. tostring(k) .. "]"
    end
    
    result = result .. "="
    
    -- Convert value based on type
    if type(v) == "table" then
      result = result .. Debug.tableToString(v, depth + 1)
    elseif type(v) == "string" then
      result = result .. '"' .. v .. '"'
    else
      result = result .. tostring(v)
    end
  end
  
  result = result .. "}"
  return result
end

---Clears the debug message history
function Debug.clear()
  Debug.messages = {}
end

---Toggles debug mode
function Debug.toggle()
  Debug.is_enabled = not Debug.is_enabled
  print("Debug mode " .. (Debug.is_enabled and "enabled" or "disabled"))
end

---Draws the debug overlay
function Debug.draw()
  if not Debug.is_enabled then
    return
  end
  
  -- Get message count
  local message_count = #Debug.messages
  if message_count == 0 then
    -- Add a default message when no messages exist yet
    table.insert(Debug.messages, "Debug enabled - no messages yet")
    message_count = 1
  end
  
  local love = require("love")
  local r, g, b, a = love.graphics.getColor()
  
  -- Draw background
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 10, 10, 500, math.min(20 * message_count + 30, 400))
  
  -- Draw border
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.rectangle("line", 10, 10, 500, math.min(20 * message_count + 30, 400))
  
  -- Draw title
  love.graphics.setColor(1, 1, 0, 1)
  love.graphics.print("DEBUG OUTPUT (" .. message_count .. " messages)", 20, 20)
  
  -- Show an indicator that debug is working
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.circle("fill", 490, 20, 5)
  
  -- Draw messages (limit to prevent overflow)
  love.graphics.setColor(1, 1, 1, 1)
  local max_visible = math.min(message_count, 18)
  for i = 1, max_visible do
    local y_pos = 20 + i * 20
    if y_pos < 400 then  -- Only draw messages that fit
      love.graphics.print(Debug.messages[i], 20, y_pos)
    end
  end
  
  -- Restore color
  love.graphics.setColor(r, g, b, a)
end

return Debug 