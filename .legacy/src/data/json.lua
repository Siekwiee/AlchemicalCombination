--[[
A simple JSON parser
]]

local json = {}

local function skipWhitespace(str, index)
    while index <= #str do
        local c = str:sub(index, index)
        if c ~= ' ' and c ~= '\t' and c ~= '\n' and c ~= '\r' then
            break
        end
        index = index + 1
    end
    return index
end

local function parseString(str, index)
    if str:sub(index, index) ~= '"' then
        error("Expected string at index " .. index)
    end
    
    local value = ""
    index = index + 1
    
    while index <= #str do
        local c = str:sub(index, index)
        if c == '"' then
            return value, index + 1
        elseif c == '\\' then
            index = index + 1
            c = str:sub(index, index)
            if c == 'n' then value = value .. '\n'
            elseif c == 'r' then value = value .. '\r'
            elseif c == 't' then value = value .. '\t'
            else value = value .. c
            end
        else
            value = value .. c
        end
        index = index + 1
    end
    error("Unterminated string starting at index " .. index)
end

local function parseNumber(str, index)
    local value = ""
    while index <= #str do
        local c = str:sub(index, index)
        if c:match("[0-9%.%-]") then
            value = value .. c
            index = index + 1
        else
            break
        end
    end
    return tonumber(value), index
end

local function parseArray(str, index)
    if str:sub(index, index) ~= '[' then
        error("Expected array at index " .. index)
    end
    
    local array = {}
    index = index + 1
    
    while index <= #str do
        index = skipWhitespace(str, index)
        
        if str:sub(index, index) == ']' then
            return array, index + 1
        end
        
        local value
        value, index = json.parseValue(str, index)
        table.insert(array, value)
        
        index = skipWhitespace(str, index)
        local c = str:sub(index, index)
        if c == ']' then
            return array, index + 1
        elseif c == ',' then
            index = index + 1
        else
            error("Expected ',' or ']' in array at index " .. index)
        end
    end
    error("Unterminated array starting at index " .. index)
end

local function parseObject(str, index)
    if str:sub(index, index) ~= '{' then
        error("Expected object at index " .. index)
    end
    
    local obj = {}
    index = index + 1
    
    while index <= #str do
        index = skipWhitespace(str, index)
        
        if str:sub(index, index) == '}' then
            return obj, index + 1
        end
        
        -- Parse key
        local key
        key, index = parseString(str, index)
        
        -- Skip whitespace and colon
        index = skipWhitespace(str, index)
        if str:sub(index, index) ~= ':' then
            error("Expected ':' at index " .. index)
        end
        index = index + 1
        
        -- Parse value
        local value
        value, index = json.parseValue(str, index)
        obj[key] = value
        
        index = skipWhitespace(str, index)
        local c = str:sub(index, index)
        if c == '}' then
            return obj, index + 1
        elseif c == ',' then
            index = index + 1
        else
            error("Expected ',' or '}' in object at index " .. index)
        end
    end
    error("Unterminated object starting at index " .. index)
end

function json.parseValue(str, index)
    index = skipWhitespace(str, index)
    local c = str:sub(index, index)
    
    if c == '"' then
        return parseString(str, index)
    elseif c == '[' then
        return parseArray(str, index)
    elseif c == '{' then
        return parseObject(str, index)
    elseif c:match("[0-9%.%-]") then
        return parseNumber(str, index)
    elseif str:sub(index, index + 3) == "true" then
        return true, index + 4
    elseif str:sub(index, index + 4) == "false" then
        return false, index + 5
    elseif str:sub(index, index + 3) == "null" then
        return nil, index + 4
    else
        error("Unexpected character at index " .. index .. ": " .. c)
    end
end

function json.decode(str)
    if type(str) ~= "string" then
        error("Expected string argument, got " .. type(str))
    end
    
    local success, result = pcall(function()
        local value, index = json.parseValue(str, 1)
        index = skipWhitespace(str, index)
        if index <= #str then
            error("Trailing characters at index " .. index)
        end
        return value
    end)
    
    if not success then
        error("JSON decode error: " .. result)
    end
    
    return result
end

-- Encode Lua value to JSON
local function encodeValue(val)
    local valType = type(val)
    
    if val == nil then
        return "null"
    elseif valType == "number" then
        return tostring(val)
    elseif valType == "boolean" then
        return val and "true" or "false"
    elseif valType == "string" then
        return '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
    elseif valType == "table" then
        -- Check if it's an array (consecutive numeric keys)
        local isArray = true
        local maxIndex = 0
        
        for k, v in pairs(val) do
            if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                isArray = false
                break
            end
            maxIndex = math.max(maxIndex, k)
        end
        
        local result
        
        if isArray and maxIndex > 0 then
            -- It's an array
            result = "["
            for i=1, maxIndex do
                if i > 1 then
                    result = result .. ","
                end
                result = result .. encodeValue(val[i])
            end
            result = result .. "]"
        else
            -- It's an object
            result = "{"
            local first = true
            for k, v in pairs(val) do
                if not first then
                    result = result .. ","
                end
                first = false
                result = result .. '"' .. tostring(k) .. '":' .. encodeValue(v)
            end
            result = result .. "}"
        end
        
        return result
    else
        error("Cannot encode value of type " .. valType)
    end
end

function json.encode(val)
    local success, result = pcall(encodeValue, val)
    
    if not success then
        error("JSON encode error: " .. result)
    end
    
    return result
end

return json 