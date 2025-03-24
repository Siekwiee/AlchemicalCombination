local UserInput = {}

-- Internal state
local _key_callbacks = {}
local _debug_console = nil

-- Initialize with debug console reference
function UserInput.init(debug_console)
  _debug_console = debug_console
  
  -- Register default debug shortcuts
  UserInput.register_key_pressed("f3", function()
    if _debug_console then
      _debug_console.toggle()
    end
  end)
  
  return UserInput
end

-- Register a callback for when a key is pressed
function UserInput.register_key_pressed(key, callback)
  if not _key_callbacks[key] then
    _key_callbacks[key] = {}
  end
  
  table.insert(_key_callbacks[key], callback)
end

-- Handle key press events
function UserInput.key_pressed(key)
  if _key_callbacks[key] then
    for _, callback in ipairs(_key_callbacks[key]) do
      callback()
    end
  end
end

-- Get debug console reference
function UserInput.get_debug_console()
  return _debug_console
end

return UserInput 