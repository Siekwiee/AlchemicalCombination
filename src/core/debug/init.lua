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

-- Helper function to check if a directory exists
local function directory_exists(path)
  local file = io.open(path .. "/.dirtest", "w")
  if file then
    file:close()
    os.remove(path .. "/.dirtest")
    return true
  else
    return false
  end
end

-- Helper function to create a directory
local function create_directory(path)
  -- Use OS-specific commands to create directory
  local success
  if package.config:sub(1,1) == '\\' then  -- Windows
    -- Use Windows command
    success = os.execute('mkdir "' .. path:gsub('/', '\\') .. '" > NUL 2>&1')
  else  -- Unix-like
    -- Use Unix command with -p to create parent directories
    success = os.execute('mkdir -p "' .. path .. '" > /dev/null 2>&1')
  end
  return success
end

-- Ensure log directory exists
function Debug:ensure_log_directory_exists()
  if not self.log_directory then
    self:add_default_log_dir()
  end
  
  -- Check if directory exists, create if it doesn't
  if not directory_exists(self.log_directory) then
    create_directory(self.log_directory)
  end
end

---@param path? string
function Debug:add_default_log_dir(path)
  local default_save_directory
  if not path then
    -- Get OS-appropriate save directory
    if package.config:sub(1,1) == '\\' then  -- Windows
      default_save_directory = os.getenv("APPDATA") or "."
    else  -- Unix-like
      default_save_directory = os.getenv("HOME") and (os.getenv("HOME") .. "/.config") or "."
    end
    default_save_directory = default_save_directory .. "/alchemical_combinations"
  else
    default_save_directory = path
  end
  
  local default_log_directory = default_save_directory .. "/log/debug"
  
  -- Create the directory path
  create_directory(default_log_directory)
  
  if default_log_directory ~= nil then
    self.log_directory = default_log_directory
  else 
    self.log_directory = "unwantedDirectory/log/debug"
  end
end

-- Format message with timestamp and level
function Debug:add_timestamp_to_message(level, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local message_with_timestamp = string.format("[%s][%s] %s", timestamp, level, message)
  return message_with_timestamp
end

-- Write log to file
---@param formatted_message string
function Debug:write_to_file(formatted_message)
  if not self.log_directory then
    self:add_default_log_dir()
  end
  
  local file_path = self.log_directory .. "/debug.log"
  
  -- Try to append to file first
  local file, err = io.open(file_path, "a")
  if file then
    file:write(formatted_message .. "\n")
    file:close()
  else
    -- If append fails (likely because file doesn't exist yet), try to write instead
    file, err = io.open(file_path, "w")
    if file then
      file:write(formatted_message .. "\n")
      file:close()
    else
      -- Don't error out, just add a warning log in memory
      self:add_log("WARNING", "Failed to write to log file: " .. tostring(err))
    end
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

-- Public API
---@param flag_file_logging boolean
---@param default_log_level string
---@return Debug
function Debug.init(self, flag_file_logging, default_log_level)
  local debug = Debug:new()
  self.log = {} -- Initialize log array
  self:add_default_log_dir()
  self.flag_file_logging = flag_file_logging or false
  self.log_level = LOG_LEVELS[default_log_level or "INFO"] or LOG_LEVELS.INFO
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