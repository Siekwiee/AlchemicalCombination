local love = require("love")

local Debug = {}

-- Constants
local LOG_LEVELS = {
  INFO = 1,
  WARNING = 2,
  ERROR = 3,
  DEBUG = 4
}

---@class Debug
---@field log table<string, string>
---@field is_enabled boolean
---@field log_level number
---@field flag_file_logging boolean
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
        log_directory = nil
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

-- Add a log entry to the log history
function Debug:add_log(level_name, message)
  local formatted_message = self:add_timestamp_to_message(level_name, message)
  
  -- Initialize log array if not already done
  if not self.log then
    self.log = {}
  end
  
  -- Add to in-memory log array
  table.insert(self.log, formatted_message)
  
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
    local debug = Debug:new()
    debug.flag_file_logging = flag_file_logging or false
    debug.log_level = LOG_LEVELS[default_log_level or "INFO"] or LOG_LEVELS.INFO
    debug:add_default_log_dir()
    return debug
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
  self:add_log("DEBUG", message)
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

return Debug 