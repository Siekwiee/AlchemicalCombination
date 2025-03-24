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
---@param path? string
---@return string
local function ensure_log_directory_exists(self, path)
  if not path and not self.log_directory then
    self:add_default_log_dir()
  end
  if not path then
    path = self.log_directory
  end
  if not love.filesystem.exists(path) then
    self:add_default_log_dir()
  end
  local result = "Log directory: " .. path
  return result
end

local function add_default_log_dir(self)
  local default_save_directory = love.filesystem.getSaveDirectory()
  local default_log_directory = default_save_directory .. "/log/debug"
  local log_directory = love.filesystem.createDirectory(default_log_directory)
  self.log_directory = log_directory
end
-- Format message with timestamp and level

local function add_timestamp_to_message(level, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local message_with_timestamp = string.format("[%s][%s] %s", timestamp, level, message)
  return message_with_timestamp
end

-- Write log to file
local function write_to_file(self, formatted_message)

end

-- Add a log entry to the log history
local function add_log(level_name, message, level_value)

end

-- Public API

function Debug.init(default_log_level, flag_file_logging)
  local debug = Debug:new()
  debug._log_level = default_log_level or LOG_LEVELS.DEBUG
  debug.flag_file_logging = flag_file_logging or true
end

function Debug.info(message)
  return _add_log("INFO", message, LOG_LEVELS.INFO)
end

function Debug.warning(message)
  return _add_log("WARNING", message, LOG_LEVELS.WARNING)
end

function Debug.error(message)
  return _add_log("ERROR", message, LOG_LEVELS.ERROR)
end

function Debug.debug(message)
  return _add_log("DEBUG", message, LOG_LEVELS.DEBUG)
end

function Debug.get_logs()
  return _logs
end

function Debug.clear()
  _logs = {}
end

function Debug.set_log_level(level)
  _log_level = level
end

function Debug.set_file_logging(enabled)
  _file_logging = enabled
end

function Debug.set_max_logs(max)
  _max_logs = max
end

return Debug 