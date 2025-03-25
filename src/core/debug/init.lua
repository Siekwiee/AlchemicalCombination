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
---@field warning fun(message: string)
---@return Debug
function Debug:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Internal state
local log = {}
local is_enabled = true
local log_level = LOG_LEVELS.DEBUG
local flag_file_logging = true

-- Ensure log directory exists
function Debug:ensure_log_directory_exists(self)
  if not self.log_directory then
    self:add_default_log_dir()
  end
  if not love.filesystem.exists(self.log_directory) then
    love.filesystem.createDirectory(self.log_directory)
  end
end

---@param path? string
function Debug:add_default_log_dir(self, path)
  local default_save_directory
  if not path then
    default_save_directory = love.filesystem.getSaveDirectory()
  else
    default_save_directory = path
  end
  local default_log_directory = default_save_directory .. "/log/debug"
  love.filesystem.createDirectory(default_log_directory)
  self.log_directory = default_log_directory
end

-- Format message with timestamp and level

function Debug:add_timestamp_to_message(level, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local message_with_timestamp = string.format("[%s][%s] %s", timestamp, level, message)
  return message_with_timestamp
end

-- Write log to file
---@param formatted_message string
function Debug:write_to_file(self, formatted_message)
  if not self.log_directory then
    self:add_default_log_dir()
  end
  
  local file_path = self.log_directory .. "/debug.log"
  local success, message = love.filesystem.append(file_path, formatted_message .. "\n")
  
  if not success then
    -- If append fails (likely because file doesn't exist yet), try to write instead
    success, message = love.filesystem.write(file_path, formatted_message .. "\n")
    if not success then
      -- Don't error out, just add a warning log in memory
      self:add_log("WARNING", "Failed to write to log file: " .. tostring(message))
    end
  end
end

-- Add a log entry to the log history
function Debug:add_log(self, log_level, message)
  local formatted_message = self:add_timestamp_to_message(log_level, message)
  
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

-- Public API
---@param flag_file_logging boolean
---@param default_log_level string
---@return Debug
function Debug.init(flag_file_logging, default_log_level)
  local debug = Debug:new()
  debug.log = {} -- Initialize log array
  debug:add_default_log_dir()
  debug.flag_file_logging = flag_file_logging or false
  debug.log_level = LOG_LEVELS[default_log_level or "INFO"]
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
    love.filesystem.write(self.log_directory, self:get_logs())
  else
    self:add_default_log_dir(path)
    love.filesystem.write(self.log_directory, self:get_logs())
  end
end

function Debug.clear(self)
  self.log = {}
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