local Logger = {}

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
function Logger.ensure_directory_exists(log_directory)
    -- Check if directory exists and is writable, create if it doesn't
    if not directory_exists_and_writable(log_directory) then
        if not create_directory(log_directory) then
            return false
        end
    end
    return true
end

-- Get default log directory
function Logger.get_default_log_dir(path)
    -- Get OS-appropriate save directory
    local default_save_directory
    if not path then
        default_save_directory = os.getenv("HOME") and (os.getenv("HOME") .. "/.local/share") or "."
        default_save_directory = default_save_directory .. "/alchemical_combinations"
    else
        default_save_directory = path
    end
    
    return default_save_directory .. "/log/debug"
end

-- Format message with timestamp and level
function Logger.format_with_timestamp(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    return string.format("[%s][%s] %s", timestamp, level, message)
end

-- Write log to file with better error handling
function Logger.write_to_file(log_directory, formatted_message)
    if not log_directory or not Logger.ensure_directory_exists(log_directory) then
        return false, "Invalid log directory"
    end
    
    local file_path = log_directory .. "/debug.log"
    local success, err = pcall(function()
        local file = io.open(file_path, "a")
        if file then
            file:write(formatted_message .. "\n")
            file:close()
        end
    end)
    
    return success, err
end

-- Save logs to a specific file
function Logger.save_logs(logs, path)
    local success, err = pcall(function()
        local file = io.open(path, "w")
        if file then
            for _, log_entry in ipairs(logs) do
                file:write(log_entry .. "\n")
            end
            file:close()
            return true
        end
        return false
    end)
    
    return success, err
end

return Logger 