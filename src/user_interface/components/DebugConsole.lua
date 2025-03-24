local DebugConsole = {}

-- Default settings
local _settings = {
  position = "bottomleft", -- Options: topleft, topright, bottomleft, bottomright
  width = 400,
  height = 200,
  font_size = 12,
  background_alpha = 0.7,
  padding = 5,
  visible = true,
  max_visible_lines = 15
}

-- Private variables
local _font = nil
local _debug = nil -- Will store the Debug module reference

-- Initialize the console
function DebugConsole.init(debug_module)
  _debug = debug_module
  _font = love.graphics.newFont(_settings.font_size)
  
  return DebugConsole
end

-- Calculate position based on setting
local function _get_position()
  local x, y = 0, 0
  local window_width, window_height = love.graphics.getDimensions()
  
  if _settings.position == "topright" then
    x = window_width - _settings.width
    y = 0
  elseif _settings.position == "bottomleft" then
    x = 0
    y = window_height - _settings.height
  elseif _settings.position == "bottomright" then
    x = window_width - _settings.width
    y = window_height - _settings.height
  end
  
  return x, y
end

-- Draw the console
function DebugConsole.draw()
  if not _debug or not _settings.visible then
    return
  end
  
  local logs = _debug.get_logs()
  if #logs == 0 then 
    return
  end
  
  -- Save current graphics state
  love.graphics.push("all")
  
  local x, y = _get_position()
  
  -- Draw background
  love.graphics.setColor(0, 0, 0, _settings.background_alpha)
  love.graphics.rectangle("fill", x, y, _settings.width, _settings.height)
  
  -- Draw border
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.rectangle("line", x, y, _settings.width, _settings.height)
  
  -- Set font
  love.graphics.setFont(_font)
  
  -- Draw logs
  local line_height = _font:getHeight() * 1.2
  local max_lines = math.min(_settings.max_visible_lines, #logs)
  
  for i = 1, max_lines do
    local log = logs[i]
    
    -- Determine color based on log type
    if string.find(log, "%[ERROR%]") then
      love.graphics.setColor(1, 0.3, 0.3, 1)
    elseif string.find(log, "%[WARNING%]") then
      love.graphics.setColor(1, 1, 0.3, 1)
    elseif string.find(log, "%[DEBUG%]") then
      love.graphics.setColor(0.5, 0.8, 1, 1)
    else
      love.graphics.setColor(1, 1, 1, 1)
    end
    
    -- Draw text with clipping to avoid overflow
    love.graphics.printf(
      log, 
      x + _settings.padding, 
      y + _settings.padding + (i-1) * line_height,
      _settings.width - (2 * _settings.padding),
      "left"
    )
  end
  
  -- If we have more logs than we can display, show a message
  if #logs > max_lines then
    love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
    love.graphics.printf(
      "+" .. (#logs - max_lines) .. " more...",
      x + _settings.padding,
      y + _settings.height - line_height - _settings.padding,
      _settings.width - (2 * _settings.padding),
      "right"
    )
  end
  
  -- Restore graphics state
  love.graphics.pop()
end

-- Update console (for animations or future input handling)
function DebugConsole.update(dt)
  -- Nothing to update for now, but keeping the function for future expansion
end

-- Toggle console visibility
function DebugConsole.toggle()
  _settings.visible = not _settings.visible
end

-- Configuration functions
function DebugConsole.set_position(position)
  _settings.position = position
end

function DebugConsole.set_size(width, height)
  _settings.width = width
  _settings.height = height
end

function DebugConsole.set_font_size(size)
  _settings.font_size = size
  _font = love.graphics.newFont(size)
end

function DebugConsole.set_background_alpha(alpha)
  _settings.background_alpha = alpha
end

function DebugConsole.set_max_visible_lines(lines)
  _settings.max_visible_lines = lines
end

function DebugConsole.set_visible(visible)
  _settings.visible = visible
end

return DebugConsole 